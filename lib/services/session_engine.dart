/// ─── Session Engine ─────────────────────────────────────────────────────────
/// Motor de sesión reusable para los 3 modos: diagnostic, practice, simulation.
///
/// Diagrama de estados:
///
///   [created] ──start()──▸ [inProgress] ──answer()──▸ [inProgress]
///                              │                           │
///                         pause()│                    (last question)
///                              ▼                           │
///                          [paused]                        ▼
///                              │                    [completed]
///                         resume()│
///                              ▼
///                         [inProgress]
///
///   Cualquier estado ──abandon()──▸ [abandoned]
///
/// Uso:
///   final engine = SessionEngine(repository: repo);
///   await engine.start(config);       // crea sesión + selecciona preguntas
///   await engine.answer('b');          // responde pregunta actual
///   // ... repite answer() por cada pregunta
///   // Se completa automáticamente al responder la última
///
library;

import 'package:flutter/foundation.dart';
import 'package:exani/models/session.dart';
import 'package:exani/models/option.dart';
import 'package:exani/services/session_repository.dart';
import 'package:exani/services/question_selector.dart';

/// Notificador del estado de la sesión.
/// Los widgets escuchan esto para re-renderizar.
class SessionEngine extends ChangeNotifier {
  final SessionRepository _repository;
  final QuestionSelector _selector;

  SessionEngine({
    required SessionRepository repository,
    QuestionSelector? selector,
  }) : _repository = repository,
       _selector = selector ?? QuestionSelector();

  // ─── Estado observable ──────────────────────────────────────────────────

  Session? _session;
  List<Question> _questions = [];
  bool _isLoading = false;
  String? _error;

  /// Cronómetro de la pregunta actual
  final Stopwatch _questionStopwatch = Stopwatch();

  // ─── Getters ────────────────────────────────────────────────────────────

  /// Sesión actual (null si no se ha iniciado)
  Session? get session => _session;

  /// Preguntas cargadas para esta sesión
  List<Question> get questions => _questions;

  /// True mientras carga/procesa
  bool get isLoading => _isLoading;

  /// Error si algo falló
  String? get error => _error;

  /// La pregunta Question completa actual (para renderizar)
  Question? get currentQuestion {
    final sq = _session?.currentQuestion;
    if (sq == null) return null;
    try {
      return _questions.firstWhere((q) => q.id == sq.questionId);
    } catch (_) {
      return null;
    }
  }

  /// Índice actual (0-based)
  int get currentIndex => _session?.currentIndex ?? 0;

  /// Progreso 0.0 - 1.0
  double get progress => _session?.progress ?? 0;

  /// Número total de preguntas
  int get totalQuestions => _session?.totalQuestions ?? 0;

  /// Respuestas correctas hasta ahora
  int get correctCount => _session?.correctCount ?? 0;

  /// Precisión actual (%)
  double get accuracy => _session?.accuracy ?? 0;

  /// Tiempo total acumulado en ms
  int get totalTimeMs => _session?.totalTimeMs ?? 0;

  /// ¿Sesión completada?
  bool get isComplete => _session?.status == SessionStatus.completed;

  /// ¿Sesión en progreso?
  bool get isInProgress => _session?.status == SessionStatus.inProgress;

  /// Config snapshot
  SessionConfig? get config => _session?.config;

  // ═══════════════════════════════════════════════════════════════════════
  // ACCIONES
  // ═══════════════════════════════════════════════════════════════════════

  /// ── START ──────────────────────────────────────────────────────────────
  /// Crea una nueva sesión y selecciona preguntas según el modo.
  Future<void> start(SessionConfig config) async {
    _setLoading(true);

    try {
      // 1. Seleccionar preguntas según modo
      final questionIds = await _selectQuestions(config);

      if (questionIds.isEmpty) {
        _setError('No hay preguntas disponibles para esta configuración.');
        return;
      }

      // 2. Cargar las preguntas completas
      _questions = await _repository.getQuestionsByIds(questionIds);

      // 3. Crear session questions en orden
      final sessionQuestions = <SessionQuestion>[];
      for (var i = 0; i < questionIds.length; i++) {
        sessionQuestions.add(
          SessionQuestion(questionId: questionIds[i], order: i + 1),
        );
      }

      // 4. Crear sesión
      _session = Session(
        config: config,
        status: SessionStatus.inProgress,
        questions: sessionQuestions,
        startedAt: DateTime.now(),
      );

      // 5. Persistir sesión
      final sessionId = await _repository.createSession(_session!);
      _session = _session!.copyWith(
        id: sessionId,
        status: SessionStatus.inProgress,
      );

      // 6. Arrancar cronómetro de la primera pregunta
      _questionStopwatch
        ..reset()
        ..start();

      _setLoading(false);
    } catch (e) {
      _setError('Error al iniciar sesión: $e');
    }
  }

  /// ── RESUME ─────────────────────────────────────────────────────────────
  /// Reanuda una sesión existente (pausada o incompleta).
  Future<void> resume(int sessionId) async {
    _setLoading(true);

    try {
      final session = await _repository.getSession(sessionId);
      if (session == null) {
        _setError('Sesión no encontrada.');
        return;
      }

      _session = session.copyWith(status: SessionStatus.inProgress);
      await _repository.updateSessionStatus(
        sessionId,
        SessionStatus.inProgress,
      );

      // Cargar preguntas
      final ids = session.questions.map((q) => q.questionId).toList();
      _questions = await _repository.getQuestionsByIds(ids);

      // Reanudar cronómetro
      _questionStopwatch
        ..reset()
        ..start();

      _setLoading(false);
    } catch (e) {
      _setError('Error al reanudar sesión: $e');
    }
  }

  /// ── ANSWER ─────────────────────────────────────────────────────────────
  /// Registra la respuesta del usuario para la pregunta actual.
  /// Retorna true si fue correcta.
  Future<bool> answer(String chosenKey) async {
    if (_session == null || isComplete) return false;

    final sq = _session!.currentQuestion;
    if (sq == null) return false;

    // Detener cronómetro
    _questionStopwatch.stop();
    final timeMs = _questionStopwatch.elapsedMilliseconds;

    // Encontrar pregunta y verificar respuesta
    final question = currentQuestion;
    if (question == null) return false;

    // La clave correcta se determina comparando el id de la opción correcta
    // con el key elegido. En el modelo Question actual, correctOptionId es int.
    // Para el motor, mapeamos: opción en posición 0 → 'a', 1 → 'b', etc.
    final correctKey = _getCorrectKey(question);
    final isCorrect = chosenKey == correctKey;

    // Actualizar pregunta en la lista
    final updatedSq = sq.answer(
      chosenKey: chosenKey,
      isCorrect: isCorrect,
      timeMs: timeMs,
    );

    final updatedQuestions = List<SessionQuestion>.from(_session!.questions);
    final idx = updatedQuestions.indexWhere(
      (q) => q.questionId == sq.questionId,
    );
    if (idx >= 0) updatedQuestions[idx] = updatedSq;

    _session = _session!.copyWith(questions: updatedQuestions);

    // Persistir respuesta
    if (_session!.id != null) {
      await _repository.saveAnswer(
        sessionId: _session!.id!,
        questionId: sq.questionId,
        chosenKey: chosenKey,
        isCorrect: isCorrect,
        timeMs: timeMs,
        mode: _session!.config.mode,
      );
    }

    // ¿Fue la última pregunta?
    if (_session!.isComplete) {
      await _complete();
    } else {
      // Reset cronómetro para siguiente pregunta
      _questionStopwatch
        ..reset()
        ..start();
    }

    notifyListeners();
    return isCorrect;
  }

  /// ── PAUSE ──────────────────────────────────────────────────────────────
  Future<void> pause() async {
    if (_session == null || !isInProgress) return;

    _questionStopwatch.stop();
    _session = _session!.copyWith(status: SessionStatus.paused);

    if (_session!.id != null) {
      await _repository.updateSessionStatus(
        _session!.id!,
        SessionStatus.paused,
      );
    }

    notifyListeners();
  }

  /// ── ABANDON ────────────────────────────────────────────────────────────
  Future<void> abandon() async {
    if (_session == null) return;

    _questionStopwatch.stop();
    _session = _session!.copyWith(
      status: SessionStatus.abandoned,
      endedAt: DateTime.now(),
    );

    if (_session!.id != null) {
      await _repository.updateSessionStatus(
        _session!.id!,
        SessionStatus.abandoned,
      );
    }

    notifyListeners();
  }

  /// ── RETRY ──────────────────────────────────────────────────────────────
  /// Reinicia con la misma configuración (nueva sesión).
  Future<void> retry() async {
    final cfg = _session?.config;
    if (cfg == null) return;
    await start(cfg);
  }

  /// ── RESET ──────────────────────────────────────────────────────────────
  /// Limpia todo el estado del engine.
  void reset() {
    _session = null;
    _questions = [];
    _isLoading = false;
    _error = null;
    _questionStopwatch.stop();
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PRIVADOS
  // ═══════════════════════════════════════════════════════════════════════

  /// Selecciona preguntas según el modo de la sesión
  Future<List<int>> _selectQuestions(SessionConfig config) async {
    switch (config.mode) {
      case SessionMode.diagnostic:
        return _selectDiagnostic(config);
      case SessionMode.practice:
        return _selectPractice(config);
      case SessionMode.simulation:
        return _selectSimulation(config);
    }
  }

  /// Diagnóstico: muestreo uniforme por skill
  Future<List<int>> _selectDiagnostic(SessionConfig config) async {
    final bySkill = await _repository.getQuestionsBySkill(
      examId: config.examId,
    );
    return _selector.selectForDiagnostic(
      questionsBySkill: bySkill,
      count: config.numQuestions,
    );
  }

  /// Práctica: algoritmo adaptativo (falladas > débiles > nuevas > repaso)
  Future<List<int>> _selectPractice(SessionConfig config) async {
    // 1. Pool de preguntas disponibles
    final availableIds = await _repository.getAvailableQuestionIds(
      examId: config.examId,
      sectionId: config.sectionId,
      areaId: config.areaId,
      skillId: config.skillId,
    );

    if (availableIds.isEmpty) return [];

    // 2. Stats del usuario
    final questionStats = await _repository.getUserQuestionStats(availableIds);
    final skillStats = await _repository.getUserSkillStats(config.examId);
    final skillMap = await _repository.getQuestionSkillMap(availableIds);

    // 3. Selección adaptativa
    return _selector.select(
      availableIds: availableIds,
      questionStats: questionStats,
      skillStats: skillStats,
      questionSkillMap: skillMap,
      count: config.numQuestions,
    );
  }

  /// Simulacro: respetar cuotas oficiales por sección
  Future<List<int>> _selectSimulation(SessionConfig config) async {
    final quotas = await _repository.getSectionQuotas(
      examId: config.examId,
      moduleIds: config.moduleIds,
    );
    final bySection = await _repository.getQuestionsBySection(
      examId: config.examId,
      moduleIds: config.moduleIds,
    );
    return _selector.selectForSimulation(
      sectionQuotas: quotas,
      questionsBySection: bySection,
    );
  }

  /// Marca la sesión como completada
  Future<void> _complete() async {
    _session = _session!.copyWith(
      status: SessionStatus.completed,
      endedAt: DateTime.now(),
    );

    if (_session!.id != null) {
      await _repository.completeSession(
        sessionId: _session!.id!,
        totalQuestions: _session!.totalQuestions,
        correctAnswers: _session!.correctCount,
        accuracy: _session!.accuracy,
        totalTimeMs: _session!.totalTimeMs,
      );

      // Refresh stats for all skills touched in this session
      await _refreshTouchedSkillsStats();
    }
  }

  /// Actualiza las estadísticas de todas las skills tocadas en la sesión.
  Future<void> _refreshTouchedSkillsStats() async {
    // Collect unique skill IDs from all questions in this session
    final skillIds = <int>{};

    for (final question in _questions) {
      if (question.skillId != null) {
        skillIds.add(question.skillId!);
      }
    }

    // Refresh stats for each skill
    for (final skillId in skillIds) {
      try {
        await _repository.refreshSkillStats(skillId);
        debugPrint('✅ Refreshed stats for skill $skillId');
      } catch (e) {
        debugPrint('❌ Error refreshing stats for skill $skillId: $e');
      }
    }

    if (skillIds.isNotEmpty) {
      debugPrint('📊 Refreshed stats for ${skillIds.length} skills');
    }
  }

  /// Mapea correctOptionId del modelo Question a la clave 'a'/'b'/'c'/'d'
  String _getCorrectKey(Question question) {
    final idx = question.options.indexWhere(
      (o) => o.id == question.correctOptionId,
    );
    if (idx < 0) return 'a'; // fallback
    return String.fromCharCode(97 + idx); // 0→'a', 1→'b', 2→'c', 3→'d'
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    _error = null;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _questionStopwatch.stop();
    super.dispose();
  }
}
