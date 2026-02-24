/// ─── Session DTOs & Models ──────────────────────────────────────────────────
/// Modelos de datos para el motor de sesiones.
/// Independientes de Supabase/SQLite — se mapean en la capa repository.
library;

// ─── Enums ──────────────────────────────────────────────────────────────────

/// Modo de sesión
enum SessionMode {
  diagnostic('Diagnóstico'),
  practice('Práctica'),
  simulation('Simulacro'),
  quickQuiz('Quiz Rápido');

  final String label;
  const SessionMode(this.label);

  String get code =>
      name; // 'diagnostic', 'practice', 'simulation', 'quickQuiz'
}

/// Estado de la sesión
enum SessionStatus {
  /// Creada pero aún no iniciada
  created,

  /// En progreso
  inProgress,

  /// Pausada (puede reanudarse)
  paused,

  /// Finalizada normalmente
  completed,

  /// Abandonada por el usuario
  abandoned,
}

// ─── Config / Snapshot ──────────────────────────────────────────────────────

/// Configuración de una sesión al momento de crearse.
/// Se guarda como snapshot para reproducibilidad.
class SessionConfig {
  final int examId;
  final SessionMode mode;

  /// Sección objetivo (null = todas las del examen)
  final int? sectionId;

  /// Área objetivo (null = todas las de la sección)
  final int? areaId;

  /// Skill objetivo (null = todas las del área)
  final int? skillId;

  /// Número de preguntas a servir
  final int numQuestions;

  /// Tiempo límite en minutos (null = sin límite)
  final int? timeLimitMinutes;

  /// IDs de módulos seleccionados (solo EXANI-II simulation)
  final List<int> moduleIds;

  const SessionConfig({
    required this.examId,
    required this.mode,
    this.sectionId,
    this.areaId,
    this.skillId,
    required this.numQuestions,
    this.timeLimitMinutes,
    this.moduleIds = const [],
  });

  Map<String, dynamic> toJson() => {
    'exam_id': examId,
    'mode': mode.code,
    'section_id': sectionId,
    'area_id': areaId,
    'skill_id': skillId,
    'num_questions': numQuestions,
    'time_limit_minutes': timeLimitMinutes,
    'module_ids': moduleIds,
  };

  factory SessionConfig.fromJson(Map<String, dynamic> json) => SessionConfig(
    examId: json['exam_id'] as int,
    mode: SessionMode.values.firstWhere((m) => m.code == json['mode']),
    sectionId: json['section_id'] as int?,
    areaId: json['area_id'] as int?,
    skillId: json['skill_id'] as int?,
    numQuestions: json['num_questions'] as int,
    timeLimitMinutes: json['time_limit_minutes'] as int?,
    moduleIds: (json['module_ids'] as List?)?.cast<int>() ?? [],
  );

  /// Factory helpers para cada modo
  factory SessionConfig.diagnostic({
    required int examId,
    int numQuestions = 30,
  }) => SessionConfig(
    examId: examId,
    mode: SessionMode.diagnostic,
    numQuestions: numQuestions,
    timeLimitMinutes: null, // sin límite en diagnóstico
  );

  factory SessionConfig.practice({
    required int examId,
    int? sectionId,
    int? areaId,
    int? skillId,
    int numQuestions = 10,
  }) => SessionConfig(
    examId: examId,
    mode: SessionMode.practice,
    sectionId: sectionId,
    areaId: areaId,
    skillId: skillId,
    numQuestions: numQuestions,
    timeLimitMinutes: null, // sin límite en práctica
  );

  factory SessionConfig.simulation({
    required int examId,
    required int numQuestions,
    required int timeLimitMinutes,
    List<int> moduleIds = const [],
  }) => SessionConfig(
    examId: examId,
    mode: SessionMode.simulation,
    numQuestions: numQuestions,
    timeLimitMinutes: timeLimitMinutes,
    moduleIds: moduleIds,
  );

  factory SessionConfig.quickQuiz({
    required int examId,
    int? sectionId,
    int? areaId,
    int? skillId,
    int numQuestions = 10,
    int? timeLimitMinutes,
  }) => SessionConfig(
    examId: examId,
    mode: SessionMode.quickQuiz,
    sectionId: sectionId,
    areaId: areaId,
    skillId: skillId,
    numQuestions: numQuestions,
    timeLimitMinutes: timeLimitMinutes,
  );
}

// ─── Session ────────────────────────────────────────────────────────────────

/// Representa una sesión de estudio (diagnóstico, práctica o simulacro).
class Session {
  final int? id;
  final String? userId;
  final SessionConfig config;
  final SessionStatus status;
  final List<SessionQuestion> questions;
  final DateTime startedAt;
  final DateTime? endedAt;

  const Session({
    this.id,
    this.userId,
    required this.config,
    this.status = SessionStatus.created,
    this.questions = const [],
    required this.startedAt,
    this.endedAt,
  });

  // ─── Computed ───────────────────────────────────────────────────────────

  int get totalQuestions => questions.length;

  int get answeredCount => questions.where((q) => q.isAnswered).length;

  int get correctCount => questions.where((q) => q.isCorrect == true).length;

  int get remainingCount => totalQuestions - answeredCount;

  bool get isComplete => answeredCount == totalQuestions;

  double get accuracy =>
      answeredCount > 0 ? (correctCount / answeredCount) * 100 : 0;

  int get totalTimeMs => questions.fold(0, (sum, q) => sum + (q.timeMs ?? 0));

  /// Progreso 0.0 - 1.0
  double get progress =>
      totalQuestions > 0 ? answeredCount / totalQuestions : 0;

  /// Pregunta actual (la primera sin responder)
  SessionQuestion? get currentQuestion {
    final idx = questions.indexWhere((q) => !q.isAnswered);
    return idx >= 0 ? questions[idx] : null;
  }

  /// Índice de la pregunta actual (0-based)
  int get currentIndex {
    final idx = questions.indexWhere((q) => !q.isAnswered);
    return idx >= 0 ? idx : totalQuestions;
  }

  // ─── Copy helpers ───────────────────────────────────────────────────────

  Session copyWith({
    int? id,
    SessionStatus? status,
    List<SessionQuestion>? questions,
    DateTime? endedAt,
  }) => Session(
    id: id ?? this.id,
    userId: userId,
    config: config,
    status: status ?? this.status,
    questions: questions ?? this.questions,
    startedAt: startedAt,
    endedAt: endedAt ?? this.endedAt,
  );
}

// ─── SessionQuestion ────────────────────────────────────────────────────────

/// Una pregunta dentro de una sesión, con el resultado del intento.
class SessionQuestion {
  final int questionId;
  final int order;

  /// Clave elegida por el usuario ('a', 'b', 'c', ...)
  final String? chosenKey;

  /// Si acertó o no
  final bool? isCorrect;

  /// Tiempo en milisegundos que tardó en responder
  final int? timeMs;

  /// Momento en que respondió
  final DateTime? answeredAt;

  const SessionQuestion({
    required this.questionId,
    required this.order,
    this.chosenKey,
    this.isCorrect,
    this.timeMs,
    this.answeredAt,
  });

  bool get isAnswered => chosenKey != null;

  SessionQuestion answer({
    required String chosenKey,
    required bool isCorrect,
    required int timeMs,
  }) => SessionQuestion(
    questionId: questionId,
    order: order,
    chosenKey: chosenKey,
    isCorrect: isCorrect,
    timeMs: timeMs,
    answeredAt: DateTime.now(),
  );
}
