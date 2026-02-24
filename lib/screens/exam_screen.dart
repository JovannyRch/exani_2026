import 'package:exani/const/const.dart';
import 'package:exani/models/option.dart';
import 'package:exani/widgets/content_image.dart';
import 'package:exani/models/exam_result.dart';
import 'package:exani/screens/review_screen.dart';
import 'package:exani/services/admob_service.dart';
import 'package:exani/services/database_service.dart';
import 'package:exani/services/notification_service.dart';
import 'package:exani/services/purchase_service.dart';
import 'package:exani/services/sound_service.dart';
import 'package:exani/services/supabase_service.dart';
import 'package:exani/theme/app_theme.dart';
import 'package:exani/widgets/ad_banner_widget.dart';
import 'package:exani/widgets/duo_button.dart';
import 'package:exani/widgets/latex_text.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class QuestionWithOptions {
  final Question question;
  final List<Option> options;

  QuestionWithOptions({required this.question, required this.options});
}

class ExamScreen extends StatefulWidget {
  final List<Question> allQuestions;
  final int examId;
  final int totalQuestions;
  final int durationMinutes;

  const ExamScreen({
    super.key,
    required this.allQuestions,
    required this.examId,
    required this.totalQuestions,
    required this.durationMinutes,
  });

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  List<QuestionWithOptions> examQuestions = [];
  Map<int, int> answers = {};
  int currentIndex = 0;

  Timer? timer;
  late int secondsRemaining;
  late int passingScore;
  late bool hasTimeLimit;

  // Cronómetro para rastrear tiempo real transcurrido
  late DateTime startTime;
  int elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();

    // Registrar el inicio del examen
    startTime = DateTime.now();

    // Inicializar valores dinámicos del examen
    hasTimeLimit = widget.durationMinutes > 0;
    secondsRemaining = widget.durationMinutes * 60;
    passingScore =
        (widget.totalQuestions * EXAM_PASSING_PERCENTAGE / 100).ceil();

    List<Question> qs = List.from(widget.allQuestions)..shuffle();
    qs = qs.take(widget.totalQuestions).toList();

    examQuestions =
        qs
            .map(
              (q) => QuestionWithOptions(
                question: q,
                options: q.getShuffledOptions(maxOptions: 3),
              ),
            )
            .toList();

    // Solo iniciar timer si hay límite de tiempo
    if (hasTimeLimit) {
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (secondsRemaining == 0) {
          _finishExam();
        } else {
          setState(() => secondsRemaining--);
        }
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _selectAnswer(int questionId, int optionId) {
    setState(() {
      answers[questionId] = optionId;
    });
  }

  void _finishExam() {
    timer?.cancel();

    // Calcular tiempo real transcurrido
    final endTime = DateTime.now();
    final timeSpent = endTime.difference(startTime).inSeconds;

    int totalCorrect = 0;
    for (var q in examQuestions) {
      if (answers[q.question.id] == q.question.correctOptionId) {
        totalCorrect++;
      }
    }

    // Calcular puntos ganados
    final int pointsEarned = _calculatePoints(
      totalQuestions: examQuestions.length,
      correctAnswers: totalCorrect,
      avgTimeSeconds:
          examQuestions.isNotEmpty
              ? (timeSpent / examQuestions.length).round()
              : 0,
    );

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder:
            (_, __, ___) => ResultsScreen(
              totalCorrect: totalCorrect,
              totalQuestions: examQuestions.length,
              timeSpentSeconds: timeSpent,
              examQuestions: examQuestions,
              answers: Map.from(answers),
              passingScore: passingScore,
              pointsEarned: pointsEarned,
              examId: widget.examId,
            ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  /// Calcula puntos según fórmula: base_points × accuracy × speed_bonus
  int _calculatePoints({
    required int totalQuestions,
    required int correctAnswers,
    required int avgTimeSeconds,
  }) {
    if (totalQuestions == 0) return 0;

    // Accuracy (0-1)
    final accuracy = correctAnswers / totalQuestions;

    // Base points: numQuestions × 10 × accuracy
    final basePoints = totalQuestions * 10 * accuracy;

    // Speed multiplier
    double speedBonus = 0;
    if (avgTimeSeconds < 30) {
      speedBonus = basePoints * 0.20; // +20%
    } else if (avgTimeSeconds < 45) {
      speedBonus = basePoints * 0.10; // +10%
    } else if (avgTimeSeconds < 60) {
      speedBonus = basePoints * 0.05; // +5%
    }

    return (basePoints + speedBonus).round();
  }

  String _formatTime(int seconds) {
    int min = seconds ~/ 60;
    int sec = seconds % 60;
    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.orange),
                SizedBox(width: 10),
                Text(
                  '¿Salir del examen?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            content: Text(
              'Perderás todo tu progreso actual.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  timer?.cancel();
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Salir',
                  style: TextStyle(color: AppColors.red),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = examQuestions[currentIndex].question;
    final options = examQuestions[currentIndex].options;
    final progress = (currentIndex + 1) / examQuestions.length;
    final bool isLastQuestion = currentIndex == examQuestions.length - 1;
    final bool hasAnswered = answers.containsKey(currentQ.id);
    final bool isTimeLow = secondsRemaining < 60;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _showExitDialog,
        ),
        title: Row(
          children: [
            Expanded(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                builder:
                    (context, value, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 14,
                        backgroundColor: AppColors.progressTrack,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary,
                        ),
                      ),
                    ),
              ),
            ),
          ],
        ),
        actions: [
          if (hasTimeLimit)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color:
                    isTimeLow
                        ? AppColors.red.withValues(alpha: 0.12)
                        : AppColors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 18,
                    color: isTimeLow ? AppColors.red : AppColors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(secondsRemaining),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isTimeLow ? AppColors.red : AppColors.orange,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Step dots (question progress indicators)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(examQuestions.length, (i) {
                final bool isCurrent = i == currentIndex;
                final bool isAnswered = answers.containsKey(
                  examQuestions[i].question.id,
                );
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isCurrent ? 28 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color:
                        isCurrent
                            ? AppColors.secondary
                            : isAnswered
                            ? AppColors.primary
                            : AppColors.progressTrack,
                    borderRadius: BorderRadius.circular(5),
                  ),
                );
              }),
            ),
          ),

          // Question content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: SingleChildScrollView(
                key: ValueKey(currentIndex),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pregunta ${currentIndex + 1} de ${examQuestions.length}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    LatexText(
                      currentQ.text,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),

                    // Imágenes del enunciado (si existen)
                    if (currentQ.hasImages) ...[
                      const SizedBox(height: 16),
                      ContentImageGallery(
                        images: currentQ.allStemImages,
                        imageHeight: 180,
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Option tiles
                    ...options.map((o) {
                      final bool isSelected = answers[currentQ.id] == o.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _OptionTile(
                          text: o.text.replaceAll('[br]', '\n'),
                          imagePath: o.imagePath,
                          isSelected: isSelected,
                          onTap: () => _selectAnswer(currentQ.id, o.id),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          // Bottom navigation
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.cardBorder, width: 2),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  if (currentIndex > 0)
                    Expanded(
                      child: DuoButton(
                        text: 'Anterior',
                        outlined: true,
                        color: AppColors.secondary,
                        onPressed: () => setState(() => currentIndex--),
                      ),
                    )
                  else
                    const Expanded(child: SizedBox()),
                  const SizedBox(width: 12),
                  Expanded(
                    child:
                        isLastQuestion
                            ? DuoButton(
                              text: 'Finalizar',
                              color: AppColors.primary,
                              icon: Icons.check_rounded,
                              onPressed: _finishExam,
                            )
                            : DuoButton(
                              text: 'Siguiente',
                              color:
                                  hasAnswered
                                      ? AppColors.primary
                                      : AppColors.cardBorder,
                              onPressed: () => setState(() => currentIndex++),
                            ),
                  ),
                ],
              ),
            ),
          ),
          const AdBannerWidget(),
        ],
      ),
    );
  }
}

// ─── Option Tile with 3D press & selection effect ───────────────────────────

class _OptionTile extends StatefulWidget {
  final String text;
  final String? imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.text,
    this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<_OptionTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final Color borderColor =
        widget.isSelected ? AppColors.secondary : AppColors.cardBorder;
    final Color bgColor =
        widget.isSelected
            ? AppColors.secondary.withValues(alpha: 0.08)
            : AppColors.surface;
    final Color bottomColor =
        widget.isSelected
            ? AppColors.darken(AppColors.secondary, 0.15)
            : AppColors.darken(AppColors.cardBorder, 0.08);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        SoundService().playTap();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: EdgeInsets.only(top: _isPressed ? 3 : 0),
        padding: EdgeInsets.only(bottom: _isPressed ? 0 : 3),
        decoration: BoxDecoration(
          color: bottomColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              // Radio indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      widget.isSelected
                          ? AppColors.secondary
                          : Colors.transparent,
                  border: Border.all(
                    color:
                        widget.isSelected
                            ? AppColors.secondary
                            : AppColors.textLight,
                    width: 2.5,
                  ),
                ),
                child:
                    widget.isSelected
                        ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        )
                        : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: OptionContent(
                  text: widget.text,
                  imagePath: widget.imagePath,
                  imageHeight: 70,
                  textStyle: TextStyle(
                    fontSize: 15,
                    color:
                        widget.isSelected
                            ? AppColors.background
                            : AppColors.textPrimary,
                    fontWeight:
                        widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// RESULTS SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class ResultsScreen extends StatefulWidget {
  final int totalCorrect;
  final int totalQuestions;
  final int timeSpentSeconds;
  final List<QuestionWithOptions> examQuestions;
  final Map<int, int> answers;
  final int passingScore;
  final int pointsEarned;
  final int examId;

  const ResultsScreen({
    super.key,
    required this.totalCorrect,
    required this.totalQuestions,
    required this.timeSpentSeconds,
    required this.examQuestions,
    required this.answers,
    required this.passingScore,
    required this.examId,
    this.pointsEarned = 0,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with TickerProviderStateMixin {
  static const String _notificationPromptSeenKey = 'notification_prompt_seen';

  late AnimationController _scoreController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();

    final bool passed = widget.totalCorrect >= widget.passingScore;

    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _scoreController.forward();

    // Save result to database
    _saveResult();

    // Play sound after score animation starts
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        if (passed) {
          SoundService().playSuccess();
        } else {
          SoundService().playFail();
        }
      }
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _bounceController.forward();
        // Load interstitial ad after animations settle
        _loadInterstitialAd();
      }
    });
  }

  void _loadInterstitialAd() async {
    // Skip interstitial for Pro users
    if (PurchaseService().isProUser) return;
    _interstitialAd = await AdMobService.createInterstitialAd();
    // Show ad 2 seconds after results appear
    Future.delayed(const Duration(seconds: 2), () {
      if (_interstitialAd != null && mounted) {
        AdMobService.showInterstitialAd(_interstitialAd);
      }
    });
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _bounceController.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  Future<void> _saveResult() async {
    try {
      // 1. Guardar en SQLite local (para compatibilidad)
      final result = ExamResult(
        correctAnswers: widget.totalCorrect,
        totalQuestions: widget.totalQuestions,
        passed: widget.totalCorrect >= widget.passingScore,
        timeSpentSeconds: widget.timeSpentSeconds,
        date: DateTime.now(),
      );
      await DatabaseService().insertExamResult(result);

      // 2. Guardar en Supabase para el ranking
      await _saveToSupabase();

      // Auto-save failed questions to favorites
      final failedIds = <int>[];
      for (var q in widget.examQuestions) {
        final selectedId = widget.answers[q.question.id];
        if (selectedId == null || selectedId != q.question.correctOptionId) {
          failedIds.add(q.question.id);
        }
      }
      if (failedIds.isNotEmpty) {
        await DatabaseService().saveFailedQuestions(failedIds);
      }

      // Check and show notification prompt on first completed session
      await _checkAndShowNotificationPrompt();

      // Check and show review prompt if conditions are met
      await _checkAndShowReviewPrompt();
    } catch (e) {
      debugPrint('Error saving result: $e');
      // Fail silently — don't interrupt the results view
    }
  }

  Future<void> _saveToSupabase() async {
    try {
      final sb = SupabaseService();

      // Si el usuario no está logueado, crear sesión anónima automáticamente
      if (!sb.isLoggedIn) {
        debugPrint('🔑 Usuario no logueado, creando sesión anónima...');
        try {
          await sb.signInAnonymously();
          debugPrint('✅ Sesión anónima creada');
        } catch (e) {
          debugPrint('❌ Error creando sesión anónima: $e');
          return;
        }
      }

      debugPrint('💾 Guardando sesión en Supabase...');
      debugPrint('   User ID: ${sb.userId}');
      debugPrint('   Exam ID: ${widget.examId}');
      debugPrint('   Total questions: ${widget.totalQuestions}');
      debugPrint('   Correct: ${widget.totalCorrect}');
      debugPrint('   Time: ${widget.timeSpentSeconds}s');

      // Crear la sesión
      final sessionData =
          await sb.sessions
              .insert({
                'user_id': sb.userId,
                'exam_id': widget.examId,
                'mode': 'quickQuiz', // o el modo correspondiente
                'total_questions': widget.totalQuestions,
                'correct_answers': widget.totalCorrect,
                'accuracy': (widget.totalCorrect / widget.totalQuestions * 100),
                'total_time_ms': widget.timeSpentSeconds * 1000,
                'is_completed': true,
                'ended_at': DateTime.now().toIso8601String(),
              })
              .select('id')
              .single();

      final sessionId = sessionData['id'] as int;
      debugPrint('   Session ID: $sessionId');

      // Guardar las preguntas con sus respuestas
      final avgTimeMs =
          (widget.timeSpentSeconds * 1000 / widget.totalQuestions).round();
      final sessionQuestions = <Map<String, dynamic>>[];

      int order = 0;
      for (var qwo in widget.examQuestions) {
        final questionId = qwo.question.id;
        final selectedOptionId = widget.answers[questionId];
        final isCorrect = selectedOptionId == qwo.question.correctOptionId;

        // Determinar la letra de la opción seleccionada (a, b, c, d)
        String? chosenKey;
        if (selectedOptionId != null) {
          final optionIndex = qwo.options.indexWhere(
            (o) => o.id == selectedOptionId,
          );
          if (optionIndex != -1) {
            chosenKey = String.fromCharCode(97 + optionIndex); // 97 = 'a'
          }
        }

        sessionQuestions.add({
          'session_id': sessionId,
          'question_id': questionId,
          'question_order': order++,
          'chosen_key': chosenKey,
          'is_correct': selectedOptionId != null ? isCorrect : null,
          'time_ms': avgTimeMs, // Tiempo promedio por pregunta
          'answered_at': DateTime.now().toIso8601String(),
        });
      }

      if (sessionQuestions.isNotEmpty) {
        await sb.sessionQuestions.insert(sessionQuestions);
        debugPrint('   ✓ ${sessionQuestions.length} preguntas guardadas');
      }

      // Calcular puntos y actualizar leaderboard
      debugPrint('📊 Calculando puntos...');
      final pointsResult = await sb.client.rpc(
        'calculate_session_points',
        params: {'p_session_id': sessionId},
      );
      debugPrint('   ✓ Puntos calculados: $pointsResult');

      debugPrint('🏆 Actualizando leaderboard...');
      await sb.client.rpc('compute_weekly_leaderboard');
      debugPrint('   ✓ Leaderboard actualizado');

      debugPrint('✅ Session saved to Supabase: $sessionId');
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving to Supabase: $e');
      debugPrint('Stack trace: $stackTrace');
      // No interrumpir la experiencia del usuario
    }
  }

  Future<void> _checkAndShowReviewPrompt() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasRequestedReview = prefs.getBool('has_requested_review') ?? false;

      // Only show once per user
      if (hasRequestedReview) return;

      // Only show if user passed the exam
      final bool passed = widget.totalCorrect >= widget.passingScore;
      if (!passed) return;

      // Check if user has completed 3+ exams
      final stats = await DatabaseService().getAllStats();
      final totalExams = stats['totalExams'] as int? ?? 0;
      if (totalExams < 3) return;

      // All conditions met - request review
      final inAppReview = InAppReview.instance;

      // Check if review is available on this device
      if (await inAppReview.isAvailable()) {
        // Request the review (this may or may not show depending on OS rules)
        await inAppReview.requestReview();
        // Mark as requested so we don't ask again
        await prefs.setBool('has_requested_review', true);
      } else {
        // Fallback: open Play Store listing directly
        await inAppReview.openStoreListing();
        await prefs.setBool('has_requested_review', true);
      }
    } catch (e) {
      // Fail silently — don't interrupt the results view
    }
  }

  Future<void> _checkAndShowNotificationPrompt() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasShownPrompt = prefs.getBool(_notificationPromptSeenKey) ?? false;
      if (hasShownPrompt) return;

      final totalExams = await DatabaseService().getTotalExams();
      if (totalExams != 1) return;

      final notificationService = NotificationService();
      if (await notificationService.isReminderEnabled()) {
        await prefs.setBool(_notificationPromptSeenKey, true);
        return;
      }

      if (!mounted) return;

      final enableReminder = await showDialog<bool>(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Recordatorio de estudio'),
              content: const Text(
                '¿Quieres que te mandemos un recordatorio diario para seguir tu racha?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Ahora no'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Activar'),
                ),
              ],
            ),
      );

      await prefs.setBool(_notificationPromptSeenKey, true);

      if (enableReminder != true) return;

      final granted = await notificationService.requestPermissions();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permiso de notificaciones no concedido'),
            ),
          );
        }
        return;
      }

      final hour = await notificationService.getReminderHour();
      final minute = await notificationService.getReminderMinute();
      await notificationService.scheduleDailyReminder(hour, minute);

      if (!mounted) return;
      final minuteText = minute.toString().padLeft(2, '0');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Recordatorio activo todos los días a las ${hour.toString().padLeft(2, '0')}:$minuteText',
          ),
        ),
      );
    } catch (e) {
      // Fail silently — don't interrupt the results view
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool passed = widget.totalCorrect >= widget.passingScore;
    final double percentage = widget.totalCorrect / widget.totalQuestions;
    final Color accentColor = passed ? AppColors.primary : AppColors.red;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Animated score circle
              AnimatedBuilder(
                animation: _scoreController,
                builder: (context, child) {
                  final animatedValue = _scoreController.value * percentage;
                  return SizedBox(
                    width: 180,
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: CircularProgressIndicator(
                            value: animatedValue,
                            strokeWidth: 14,
                            backgroundColor: AppColors.progressTrack,
                            valueColor: AlwaysStoppedAnimation(accentColor),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(animatedValue * 100).round()}%',
                              style: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                            Text(
                              '${widget.totalCorrect}/${widget.totalQuestions}',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 36),

              // Result text with bounce
              ScaleTransition(
                scale: _bounceAnimation,
                child: Column(
                  children: [
                    Icon(
                      passed
                          ? Icons.emoji_events_rounded
                          : Icons.sentiment_dissatisfied_rounded,
                      size: 60,
                      color: accentColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      passed ? '¡Felicidades! 🎉' : 'Sigue practicando 💪',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      passed
                          ? 'Aprobaste el examen de práctica.\n¡Estás listo para el examen real!'
                          : 'Necesitas al menos 6 respuestas correctas\npara aprobar. ¡Tú puedes!',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.pointsEarned > 0) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.stars_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Puntos Ganados',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '+${widget.pointsEarned}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Share button
              DuoButton(
                text: 'Compartir resultado',
                color: AppColors.purple,
                icon: Icons.share_rounded,
                onPressed: () {
                  SoundService().playTap();
                  final score =
                      '${widget.totalCorrect}/${widget.totalQuestions}';
                  final pct = '${(percentage * 100).round()}%';
                  final emoji = passed ? '✅' : '💪';
                  final status = passed ? '¡Aprobé' : 'Obtuve $pct en';
                  final text =
                      '$status mi examen de preparación $score $emoji 🎓\n\n'
                      'Prepárate para tu examen de manejo con esta app:\n'
                      '$PLAYSTORE_APP_ID';
                  SharePlus.instance.share(ShareParams(text: text));
                },
              ),
              const SizedBox(height: 12),

              // Review button
              DuoButton(
                text: 'Revisar respuestas',
                color: AppColors.secondary,
                icon: Icons.rate_review_rounded,
                onPressed: () {
                  SoundService().playTap();
                  final reviewItems =
                      widget.examQuestions.map((qwo) {
                        return ReviewItem(
                          question: qwo.question,
                          options: qwo.options,
                          selectedOptionId: widget.answers[qwo.question.id],
                        );
                      }).toList();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ReviewScreen(
                            items: reviewItems,
                            totalCorrect: widget.totalCorrect,
                          ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Back button
              DuoButton(
                text: 'Volver al inicio',
                color: accentColor,
                icon: Icons.home_rounded,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
