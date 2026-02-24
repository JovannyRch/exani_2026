import 'package:flutter/material.dart';
import 'package:exani/models/option.dart';
import 'package:exani/screens/exam_screen.dart';
import 'package:exani/services/sound_service.dart';
import 'package:exani/services/supabase_service.dart';
import 'package:exani/theme/app_theme.dart';
import 'package:exani/widgets/app_loader.dart';
import 'package:exani/widgets/duo_button.dart';

/// Pantalla de configuración de Quiz Rápido.
/// Permite al usuario elegir número de preguntas, tema y tiempo límite.
class QuizSetupScreen extends StatefulWidget {
  final String examId;
  final String examName;

  const QuizSetupScreen({
    super.key,
    required this.examId,
    required this.examName,
  });

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  // Selected options
  int _selectedQuestions = 10;
  bool _isRandomTopic = true;
  bool _hasTimeLimit = false;
  int _selectedSectionId = 0;

  // Data from Supabase
  List<Map<String, dynamic>> _sections = [];
  bool _isLoading = true;

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
    _loadSections();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadSections() async {
    try {
      final examId = int.tryParse(widget.examId) ?? 1;
      final sectionsData = await SupabaseService().getSectionsHierarchy(examId);

      if (mounted) {
        setState(() {
          _sections = sectionsData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _startQuiz() async {
    SoundService().playTap();

    AppLoading.show(context, message: 'Preparando quiz...', dismissible: false);

    try {
      final examId = int.tryParse(widget.examId) ?? 1;

      // Fetch questions based on config
      List<Question> questions;

      if (_isRandomTopic) {
        // Get random questions from all sections
        final allQuestions = <Question>[];
        for (final section in _sections) {
          final sectionQuestions = await SupabaseService()
              .getQuestionsBySection(
                sectionId: section['id'] as int,
                limit: 50,
              );
          allQuestions.addAll(
            sectionQuestions.map((q) => Question.fromSupabase(q)),
          );
        }

        // Shuffle and take requested number
        allQuestions.shuffle();
        questions = allQuestions.take(_selectedQuestions).toList();
      } else {
        // Get questions from specific section
        final questionData = await SupabaseService().getQuestionsBySection(
          sectionId: _selectedSectionId,
          limit: _selectedQuestions,
        );
        questions = questionData.map((q) => Question.fromSupabase(q)).toList();
      }

      if (context.mounted) AppLoading.hide(context);

      if (questions.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No hay suficientes preguntas disponibles'),
              backgroundColor: AppColors.red,
            ),
          );
        }
        return;
      }

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => ExamScreen(
                  allQuestions: questions,
                  examId: examId,
                  totalQuestions: _selectedQuestions,
                  durationMinutes: _hasTimeLimit ? _selectedQuestions : 0,
                ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppLoading.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () {
            SoundService().playTap();
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Quiz Rápido',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : FadeTransition(
                opacity: _fadeAnimation,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.flash_on_rounded,
                                  size: 60,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '¡Sesión rápida!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Personaliza tu quiz al estilo Duolingo',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Number of questions
                                _buildSectionTitle('Número de preguntas'),
                                const SizedBox(height: 12),
                                _buildQuestionSelector(),

                                const SizedBox(height: 24),

                                // Topic selection
                                _buildSectionTitle('Tema'),
                                const SizedBox(height: 12),
                                _buildTopicSelector(),

                                const SizedBox(height: 24),

                                // Time limit
                                _buildSectionTitle('Cronómetro'),
                                const SizedBox(height: 12),
                                _buildTimeSwitch(),
                              ],
                            ),
                          ),
                        ),

                        // Start button
                        DuoButton(
                          text: 'Iniciar Quiz',
                          icon: Icons.play_arrow_rounded,
                          onPressed: _startQuiz,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildQuestionSelector() {
    return Row(
      children:
          [5, 10, 15].map((count) {
            final isSelected = _selectedQuestions == count;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () {
                    SoundService().playTap();
                    setState(() => _selectedQuestions = count);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                              : [],
                    ),
                    child: Text(
                      '$count',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color:
                            isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildTopicSelector() {
    return Column(
      children: [
        // Random topic
        GestureDetector(
          onTap: () {
            SoundService().playTap();
            setState(() => _isRandomTopic = true);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isRandomTopic ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isRandomTopic ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shuffle_rounded,
                  color:
                      _isRandomTopic ? Colors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Aleatorio (mezclado)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          _isRandomTopic ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (_isRandomTopic)
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Specific section
        GestureDetector(
          onTap: () {
            SoundService().playTap();
            setState(() => _isRandomTopic = false);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: !_isRandomTopic ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: !_isRandomTopic ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.topic_rounded,
                  color:
                      !_isRandomTopic ? Colors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tema específico',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          !_isRandomTopic
                              ? Colors.white
                              : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (!_isRandomTopic)
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
              ],
            ),
          ),
        ),

        // Section dropdown (if specific topic selected)
        if (!_isRandomTopic && _sections.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<int>(
              value:
                  _selectedSectionId == 0
                      ? _sections.first['id'] as int
                      : _selectedSectionId,
              isExpanded: true,
              underline: const SizedBox(),
              items:
                  _sections.map((section) {
                    return DropdownMenuItem<int>(
                      value: section['id'] as int,
                      child: Text(
                        section['name'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  SoundService().playTap();
                  setState(() => _selectedSectionId = value);
                }
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimeSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            _hasTimeLimit ? Icons.timer_rounded : Icons.timer_off_rounded,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contrarreloj',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _hasTimeLimit
                      ? '1 minuto por pregunta'
                      : 'Sin límite de tiempo',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _hasTimeLimit,
            activeColor: AppColors.primary,
            onChanged: (value) {
              SoundService().playTap();
              setState(() => _hasTimeLimit = value);
            },
          ),
        ],
      ),
    );
  }
}
