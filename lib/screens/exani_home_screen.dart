import 'package:flutter/material.dart';
import 'package:exani/models/option.dart';
import 'package:exani/screens/guide_screen.dart';
import 'package:exani/screens/leaderboard_screen.dart';
import 'package:exani/screens/pdf_viewer_screen.dart';
import 'package:exani/screens/practice_setup_screen.dart';
import 'package:exani/screens/pro_screen.dart';
import 'package:exani/screens/quiz_setup_screen.dart';
import 'package:exani/screens/simulation_screen.dart';
import 'package:exani/services/database_service.dart';
import 'package:exani/services/purchase_service.dart';
import 'package:exani/services/sound_service.dart';
import 'package:exani/services/supabase_service.dart';
import 'package:exani/services/theme_service.dart';
import 'package:exani/theme/app_theme.dart';
import 'package:exani/widgets/ad_banner_widget.dart';
import 'package:exani/widgets/app_drawer.dart';
import 'package:exani/widgets/app_loader.dart';
import 'package:exani/widgets/duo_button.dart';

/// Pantalla 4 MVP — Home post-onboarding.
/// Dashboard EXANI con:  stats, Next Best Session, cards de acción, leaderboard preview
class ExaniHomeScreen extends StatefulWidget {
  final int examId;
  final String examName;
  final DateTime? examDate;
  final List<String> moduleIds;

  const ExaniHomeScreen({
    super.key,
    required this.examId,
    required this.examName,
    this.examDate,
    this.moduleIds = const [],
  });

  @override
  State<ExaniHomeScreen> createState() => _ExaniHomeScreenState();
}

class _ExaniHomeScreenState extends State<ExaniHomeScreen>
    with TickerProviderStateMixin, ThemeModeRebuildMixin<ExaniHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<AnimationController> _controllers;
  late final List<Animation<Offset>> _slideAnimations;
  late final List<Animation<double>> _fadeAnimations;

  int _totalSessions = 0;
  int _avgAccuracy = 0;
  int _streak = 0;
  String _weakAreaName = '';
  int? _myRank;
  int? _totalParticipants;
  int _weeklyPoints = 0;
  late int _activeExamId;
  late String _activeExamName;

  @override
  void initState() {
    super.initState();
    _activeExamId = widget.examId;
    _activeExamName = widget.examName;
    _loadStats();

    _controllers = List.generate(9, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500 + (index * 150)),
      );
    });

    _slideAnimations =
        _controllers.map((c) {
          return Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic));
        }).toList();

    _fadeAnimations =
        _controllers.map((c) {
          return Tween<double>(
            begin: 0,
            end: 1,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut));
        }).toList();

    for (var c in _controllers) {
      c.forward();
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await DatabaseService().getAllStats();

      // Get weakest area from Supabase user stats
      String? weakArea;
      int? myRank;
      int? totalParticipants;
      int weeklyPoints = 0;
      try {
        weakArea = await SupabaseService().getWeakestAreaName(
          examId: _activeExamId,
        );

        final rank = await _loadMyLeaderboardPosition();
        myRank = rank?.rank;
        totalParticipants = rank?.totalParticipants;
        weeklyPoints = rank?.totalPoints ?? 0;
      } catch (e) {
        // Ignore if not logged in or no data yet
      }

      if (mounted) {
        setState(() {
          _totalSessions = stats['totalExams'] as int;
          _avgAccuracy = (stats['bestScore'] as num).round();
          _streak = stats['streak'] as int;
          _weakAreaName = weakArea ?? '';
          _myRank = myRank;
          _totalParticipants = totalParticipants;
          _weeklyPoints = weeklyPoints;
        });
      }
    } catch (_) {}
  }

  Future<_LeaderboardPositionSnapshot?> _loadMyLeaderboardPosition() async {
    final sb = SupabaseService();
    if (!sb.isLoggedIn) return null;

    try {
      final weekStart = _currentWeekStart().toIso8601String().substring(0, 10);
      final raw = await sb.rpc(
        'get_my_leaderboard_position',
        params: {
          'p_user_id': sb.userId,
          'p_exam_id': _activeExamId,
          'p_week_start': weekStart,
        },
      );

      if (raw == null) return null;
      if (raw is List && raw.isNotEmpty) {
        return _LeaderboardPositionSnapshot.fromJson(
          raw.first as Map<String, dynamic>,
        );
      }
      if (raw is Map<String, dynamic>) {
        return _LeaderboardPositionSnapshot.fromJson(raw);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  DateTime _currentWeekStart() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  /// Maneja el cambio de examen activo desde el drawer
  Future<void> _onExamChanged(int newExamId) async {
    // Cargar nombre del examen desde la base de datos
    try {
      final examData =
          await SupabaseService().exams
              .select()
              .eq('id', newExamId)
              .maybeSingle();

      final examName = examData?['name'] as String? ?? 'EXANI';

      setState(() {
        _activeExamId = newExamId;
        _activeExamName = examName;
      });
    } catch (e) {
      setState(() => _activeExamId = newExamId);
    }

    await _loadStats();

    // Opcional: Mostrar mensaje de confirmación
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cambiado a $_activeExamName'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  /// Carga todas las preguntas disponibles para el examen desde Supabase
  Future<List<Question>> _loadAllQuestions() async {
    try {
      // Get all sections for this exam
      final sectionsData = await SupabaseService().getSectionsHierarchy(
        _activeExamId,
      );

      // Collect all questions from all sections
      final allQuestions = <Question>[];

      for (final sectionData in sectionsData) {
        final sectionId = sectionData['id'] as int;

        // Get questions for this section (limit per section to avoid too many)
        final questionsData = await SupabaseService().getQuestionsBySection(
          sectionId: sectionId,
          limit: 50, // Reasonable limit per section
        );

        // Convert to Question objects
        final questions =
            questionsData.map((q) => Question.fromSupabase(q)).toList();

        allQuestions.addAll(questions);
      }

      debugPrint('📚 Loaded ${allQuestions.length} questions for study guide');
      return allQuestions;
    } catch (e) {
      debugPrint('❌ Error loading questions: $e');
      return [];
    }
  }

  Route _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(onExamChanged: _onExamChanged),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _loadStats,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildAnimatedWidget(0, _buildStatsRow()),
                      const SizedBox(height: 20),

                      // ✨ QUICK QUIZ HERO - Destacado arriba de todo
                      _buildAnimatedWidget(1, _buildQuickQuizHero()),
                      const SizedBox(height: 20),

                      _buildAnimatedWidget(2, _buildLeaderboardSpotlight()),
                      const SizedBox(height: 14),
                      _buildAnimatedWidget(2, _buildNextSessionCTA()),
                      const SizedBox(height: 12),
                      _buildAnimatedWidget(
                        3,
                        _buildActionCard(
                          icon: Icons.school_rounded,
                          color: AppColors.secondary,
                          title: 'Práctica por tema',
                          subtitle: 'Elige sección → área → habilidad',
                          onTap:
                              () => Navigator.push(
                                context,
                                _slideRoute(
                                  PracticeSetupScreen(
                                    examId: _activeExamId.toString(),
                                  ),
                                ),
                              ).then((_) => _loadStats()),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildAnimatedWidget(
                        4,
                        _buildActionCard(
                          icon: Icons.timer_rounded,
                          color: AppColors.orange,
                          title: 'Simulacro completo',
                          subtitle:
                              'Examen cronometrado con condiciones reales',
                          onTap: () {
                            Navigator.push(
                              context,
                              _slideRoute(
                                SimulationScreen(
                                  examId: _activeExamId.toString(),
                                  examName: _activeExamName,
                                ),
                              ),
                            ).then((_) => _loadStats());
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildAnimatedWidget(
                        5,
                        _buildActionCard(
                          icon: Icons.picture_as_pdf_rounded,
                          color: AppColors.red,
                          title: 'Guía Oficial PDF',
                          subtitle: 'Descarga y consulta la guía completa',
                          onTap: () {
                            final pdfPath =
                                _activeExamId == 1
                                    ? 'assets/files/guia_exani_ii.pdf'
                                    : 'assets/files/guia_exani_i.pdf';

                            Navigator.push(
                              context,
                              _slideRoute(
                                PdfViewerScreen(
                                  pdfAssetPath: pdfPath,
                                  title: 'Guía $_activeExamName',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildAnimatedWidget(
                        6,
                        _buildActionCard(
                          icon: Icons.menu_book_rounded,
                          color: AppColors.purple,
                          title: 'Guía de estudio',
                          subtitle: 'Repasa las preguntas con sus respuestas',
                          onTap: () async {
                            // Show loading indicator
                            AppLoading.show(
                              context,
                              message: 'Cargando preguntas...',
                              dismissible: false,
                            );

                            // Load questions from Supabase
                            final questions = await _loadAllQuestions();

                            // Hide loading
                            if (context.mounted) AppLoading.hide(context);

                            // Check if we got questions
                            if (questions.isEmpty) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'No hay preguntas disponibles',
                                    ),
                                    backgroundColor: AppColors.red,
                                  ),
                                );
                              }
                              return;
                            }

                            // Navigate to guide screen
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                _slideRoute(
                                  GuideScreen(allQuestions: questions),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      ValueListenableBuilder<bool>(
                        valueListenable: PurchaseService().isPro,
                        builder: (context, isPro, _) {
                          return _buildAnimatedWidget(
                            7,
                            _buildProBanner(isPro),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            const AdBannerWidget(),
          ],
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final daysLeft = widget.examDate?.difference(DateTime.now()).inDays;

    return Row(
      children: [
        // Menu button
        GestureDetector(
          onTap: () {
            SoundService().playTap();
            _scaffoldKey.currentState?.openDrawer();
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Icon(
              Icons.menu_rounded,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _activeExamName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (daysLeft != null && daysLeft > 0) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        daysLeft <= 14
                            ? AppColors.red.withValues(alpha: 0.12)
                            : AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$daysLeft días para tu examen',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: daysLeft <= 14 ? AppColors.red : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ─── Stats Row ───────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatChip('🎯', '$_totalSessions', 'sesiones'),
        const SizedBox(width: 10),
        _buildStatChip('⭐', '$_avgAccuracy%', 'precisión'),
        const SizedBox(width: 10),
        _buildStatChip('🔥', '$_streak', 'racha'),
      ],
    );
  }

  Widget _buildStatChip(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Next Best Session CTA ───────────────────────────────────────────────

  // ─── Quick Quiz Hero Banner ─────────────────────────────────────────────

  Widget _buildQuickQuizHero() {
    return GestureDetector(
      onTap: () {
        SoundService().playTap();
        Navigator.push(
          context,
          _slideRoute(
            QuizSetupScreen(
              examId: _activeExamId.toString(),
              examName: _activeExamName,
            ),
          ),
        ).then((_) => _loadStats());
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
              AppColors.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Badge "Recomendado"
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⚡', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        'RECOMENDADO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withValues(alpha: 0.95),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Badge de tiempo
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '⏱️ 2-5 min',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Título principal
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.flash_on_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quiz Rápido',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'La forma más rápida de ganar puntos',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Features
            Row(
              children: [
                _buildQuickFeature(icon: '🎯', label: '5-15 preguntas'),
                const SizedBox(width: 12),
                _buildQuickFeature(icon: '🏆', label: 'Gana puntos'),
                const SizedBox(width: 12),
                _buildQuickFeature(icon: '🔥', label: 'Sin presión'),
              ],
            ),
            const SizedBox(height: 16),
            // CTA Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Comenzar Quiz',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFeature({required String icon, required String label}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Next Session CTA ────────────────────────────────────────────────────

  Widget _buildNextSessionCTA() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Siguiente sesión ideal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_weakAreaName.isNotEmpty)
            Text(
              'Refuerza "$_weakAreaName" — tu área con más oportunidad.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
          const SizedBox(height: 14),
          DuoButton(
            text: 'Comenzar práctica',
            color: AppColors.orange,
            icon: Icons.play_arrow_rounded,
            onPressed: () {
              // Navigate to practice setup for adaptive practice
              Navigator.push(
                context,
                _slideRoute(
                  PracticeSetupScreen(examId: _activeExamId.toString()),
                ),
              ).then((_) => _loadStats());
            },
          ),
        ],
      ),
    );
  }

  // ─── Action Card (3D press) ──────────────────────────────────────────────

  Widget _buildActionCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return _ActionCard3D(
      icon: icon,
      color: color,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
    );
  }

  // ─── Leaderboard Preview ─────────────────────────────────────────────────

  Widget _buildLeaderboardSpotlight() {
    final bool ranked = _myRank != null && (_totalParticipants ?? 0) > 0;
    final percentile =
        ranked ? ((_myRank! / _totalParticipants!) * 100).ceil() : null;

    return GestureDetector(
      onTap: () {
        SoundService().playTap();
        Navigator.push(
          context,
          _slideRoute(LeaderboardScreen(examId: _activeExamId.toString())),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient:
              ranked
                  ? LinearGradient(
                    colors: [
                      AppColors.orange.withValues(alpha: 0.18),
                      AppColors.primary.withValues(alpha: 0.12),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
          color: ranked ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                ranked
                    ? AppColors.orange.withValues(alpha: 0.5)
                    : AppColors.cardBorder,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.leaderboard_rounded,
                color: AppColors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ranked
                        ? 'Vas #$_myRank de $_totalParticipants'
                        : 'Sube al ranking semanal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ranked
                        ? 'Top $percentile% • $_weeklyPoints puntos esta semana'
                        : 'Completa más quiz rápidos para aparecer y escalar posiciones',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textLight,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Pro Banner ──────────────────────────────────────────────────────────

  Widget _buildProBanner(bool isPro) {
    return GestureDetector(
      onTap: () {
        SoundService().playTap();
        Navigator.push(context, _slideRoute(const ProScreen()));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isPro
                  ? Icons.check_circle_rounded
                  : Icons.workspace_premium_rounded,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPro ? 'Eres Pro ⭐' : 'Versión Pro',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    isPro
                        ? 'Disfruta la app sin anuncios'
                        : 'Sin anuncios · ${PurchaseService().pricePerPeriodString}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Animated wrapper ────────────────────────────────────────────────────

  Widget _buildAnimatedWidget(int index, Widget child) {
    return SlideTransition(
      position: _slideAnimations[index],
      child: FadeTransition(opacity: _fadeAnimations[index], child: child),
    );
  }
}

class _LeaderboardPositionSnapshot {
  final int rank;
  final int totalParticipants;
  final int totalPoints;

  const _LeaderboardPositionSnapshot({
    required this.rank,
    required this.totalParticipants,
    required this.totalPoints,
  });

  factory _LeaderboardPositionSnapshot.fromJson(Map<String, dynamic> json) {
    return _LeaderboardPositionSnapshot(
      rank: (json['rank'] as num).toInt(),
      totalParticipants: (json['total_participants'] as num?)?.toInt() ?? 0,
      totalPoints: (json['total_points'] as num?)?.toInt() ?? 0,
    );
  }
}

// ─── ActionCard con efecto 3D ───────────────────────────────────────────────

class _ActionCard3D extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard3D({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_ActionCard3D> createState() => _ActionCard3DState();
}

class _ActionCard3DState extends State<_ActionCard3D> {
  bool _isPressed = false;

  Color get _darkColor => AppColors.darken(widget.color, 0.18);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        SoundService().playTap();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        margin: EdgeInsets.only(top: _isPressed ? 3 : 0),
        padding: EdgeInsets.only(bottom: _isPressed ? 0 : 3),
        decoration: BoxDecoration(
          color: _darkColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon, color: widget.color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textLight,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
