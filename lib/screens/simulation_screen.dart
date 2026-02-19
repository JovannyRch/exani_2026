import 'package:flutter/material.dart';
import 'package:exani/models/option.dart';
import 'package:exani/models/session.dart';
import 'package:exani/screens/exam_screen.dart';
import 'package:exani/services/sound_service.dart';
import 'package:exani/services/supabase_service.dart';
import 'package:exani/theme/app_theme.dart';
import 'package:exani/widgets/app_loader.dart';
import 'package:exani/widgets/duo_button.dart';

/// Pantalla 6 MVP — Pre-simulacro.
/// Muestra reglas y condiciones del simulacro antes de iniciarlo.
class SimulationScreen extends StatefulWidget {
  final String examId;
  final String examName;

  const SimulationScreen({
    super.key,
    required this.examId,
    required this.examName,
  });

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  // Simulacro config loaded from Supabase
  int _totalQuestions = 120;
  int _timeLimitMinutes = 180;
  int _sectionsCount = 4;
  bool _isLoadingConfig = true;
  SessionConfig? _sessionConfig;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
    _loadExamConfig();
  }

  Future<void> _loadExamConfig() async {
    try {
      final examId = int.tryParse(widget.examId) ?? 1;
      final config = await SupabaseService().getExamConfig(examId);

      if (config != null && mounted) {
        final sections = config['sections'] as List<dynamic>? ?? [];
        final totalDuration = config['total_duration_minutes'] as int? ?? 180;

        // Calculate total questions from all sections
        int totalQuestions = 0;
        for (final section in sections) {
          final sectionMap = section as Map<String, dynamic>;
          totalQuestions += (sectionMap['num_questions'] as int? ?? 0);
        }

        // Create SessionConfig for simulation
        _sessionConfig = SessionConfig.simulation(
          examId: examId,
          numQuestions: totalQuestions,
          timeLimitMinutes: totalDuration,
        );

        setState(() {
          _totalQuestions = totalQuestions;
          _timeLimitMinutes = totalDuration;
          _sectionsCount = sections.length;
          _isLoadingConfig = false;
        });
      } else {
        // Fallback to defaults
        setState(() => _isLoadingConfig = false);
      }
    } catch (e) {
      debugPrint('Error loading exam config: $e');
      setState(() => _isLoadingConfig = false);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _startSimulation() async {
    if (_sessionConfig == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error al cargar configuración del examen'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    SoundService().playTap();

    // Show loading indicator
    AppLoading.show(
      context,
      message: 'Preparando simulacro...',
      dismissible: false,
    );

    try {
      // Load questions from Supabase for all sections
      final examId = int.tryParse(widget.examId) ?? 1;
      final sectionsData = await SupabaseService().getSectionsHierarchy(examId);

      final allQuestions = <Question>[];

      // Load questions proportionally from each section according to exam config
      for (final sectionData in sectionsData) {
        final sectionId = sectionData['id'] as int;

        // Get questions for this section
        final questionsData = await SupabaseService().getQuestionsBySection(
          sectionId: sectionId,
          limit: 30, // Load a good sample from each section
        );

        final questions =
            questionsData.map((q) => Question.fromSupabase(q)).toList();

        allQuestions.addAll(questions);
      }

      // Shuffle and limit to configured number
      allQuestions.shuffle();
      final simulationQuestions =
          allQuestions.take(_sessionConfig!.numQuestions).toList();

      debugPrint('📝 Starting simulation with config:');
      debugPrint('   Questions loaded: ${simulationQuestions.length}');
      debugPrint('   Questions configured: ${_sessionConfig!.numQuestions}');
      debugPrint('   Time: ${_sessionConfig!.timeLimitMinutes} min');
      debugPrint('   Mode: ${_sessionConfig!.mode.label}');

      // Hide loading
      if (mounted) AppLoading.hide(context);

      // Check if we have enough questions
      if (simulationQuestions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No hay suficientes preguntas disponibles'),
              backgroundColor: AppColors.red,
            ),
          );
        }
        return;
      }

      // Navigate to exam screen with loaded questions
      // TODO: Replace ExamScreen with SessionEngine-based screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    ExamScreen(allQuestions: simulationQuestions),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              );
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error loading simulation questions: $e');

      // Hide loading
      if (mounted) AppLoading.hide(context);

      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar preguntas: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Simulacro',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child:
                    _isLoadingConfig
                        ? const AppLoader(message: 'Cargando configuración...')
                        : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                          child: Column(
                            children: [
                              // Icon
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.orange.withValues(
                                    alpha: 0.12,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.timer_rounded,
                                  color: AppColors.orange,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Simulacro ${widget.examName}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Reproduce las condiciones reales del examen.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Info cards
                              _InfoRow(
                                icon: Icons.quiz_rounded,
                                label: 'Reactivos',
                                value: '$_totalQuestions preguntas',
                              ),
                              const SizedBox(height: 10),
                              _InfoRow(
                                icon: Icons.timer_outlined,
                                label: 'Tiempo límite',
                                value:
                                    '${_timeLimitMinutes ~/ 60}h ${_timeLimitMinutes % 60}min',
                              ),
                              const SizedBox(height: 10),
                              _InfoRow(
                                icon: Icons.view_list_rounded,
                                label: 'Secciones',
                                value: '$_sectionsCount secciones',
                              ),
                              const SizedBox(height: 10),
                              _InfoRow(
                                icon: Icons.shuffle_rounded,
                                label: 'Orden',
                                value: 'Aleatorio',
                              ),
                              const SizedBox(height: 28),

                              // Rules
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.orange.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.orange.withValues(
                                      alpha: 0.25,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline_rounded,
                                          color: AppColors.orange,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Recomendaciones',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.orange,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    _BulletPoint(
                                      'Busca un lugar tranquilo y sin distracciones.',
                                    ),
                                    _BulletPoint(
                                      'No podrás pausar el cronómetro.',
                                    ),
                                    _BulletPoint(
                                      'Puedes regresar a preguntas anteriores.',
                                    ),
                                    _BulletPoint(
                                      'Tus resultados se guardarán al terminar.',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
              ),

              // CTA
              if (!_isLoadingConfig)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    children: [
                      DuoButton(
                        text: 'Iniciar simulacro',
                        color: AppColors.orange,
                        icon: Icons.play_arrow_rounded,
                        onPressed: _startSimulation,
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Volver',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Info Row ────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 22),
          const SizedBox(width: 14),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bullet Point ────────────────────────────────────────────────────────────

class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.textSecondary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
