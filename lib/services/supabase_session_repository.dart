/// ─── Supabase Session Repository ─────────────────────────────────────────────
/// Implementación concreta de SessionRepository usando Supabase.
/// Mapea las tablas de postgres a los DTOs de Dart.
library;

import 'package:exani/models/option.dart';
import 'package:exani/models/session.dart';
import 'package:exani/services/question_selector.dart';
import 'package:exani/services/session_repository.dart';
import 'package:exani/services/supabase_service.dart';

class SupabaseSessionRepository implements SessionRepository {
  final _sb = SupabaseService();

  // ─── Sesiones ───────────────────────────────────────────────────────────

  @override
  Future<int> createSession(Session session) async {
    final data =
        await _sb.sessions
            .insert({
              'user_id': _sb.userId,
              'exam_id': session.config.examId,
              'mode': session.config.mode.code,
              'config_snapshot_json': session.config.toJson(),
              'section_id': session.config.sectionId,
              'area_id': session.config.areaId,
              'skill_id': session.config.skillId,
              'total_questions': session.totalQuestions,
              'is_completed': false,
            })
            .select('id')
            .single();

    final sessionId = data['id'] as int;

    // Insertar session_questions (orden)
    if (session.questions.isNotEmpty) {
      final rows =
          session.questions
              .map(
                (sq) => {
                  'session_id': sessionId,
                  'question_id': sq.questionId,
                  'question_order': sq.order,
                },
              )
              .toList();

      await _sb.sessionQuestions.insert(rows);
    }

    return sessionId;
  }

  @override
  Future<void> updateSessionStatus(int sessionId, SessionStatus status) async {
    final updates = <String, dynamic>{
      'is_completed': status == SessionStatus.completed,
    };
    if (status == SessionStatus.completed ||
        status == SessionStatus.abandoned) {
      updates['ended_at'] = DateTime.now().toIso8601String();
    }
    await _sb.sessions.update(updates).eq('id', sessionId);
  }

  @override
  Future<void> completeSession({
    required int sessionId,
    required int totalQuestions,
    required int correctAnswers,
    required double accuracy,
    required int totalTimeMs,
  }) async {
    await _sb.sessions
        .update({
          'total_questions': totalQuestions,
          'correct_answers': correctAnswers,
          'accuracy': accuracy,
          'total_time_ms': totalTimeMs,
          'is_completed': true,
          'ended_at': DateTime.now().toIso8601String(),
        })
        .eq('id', sessionId);
  }

  @override
  Future<Session?> getSession(int sessionId) async {
    final data = await _sb.sessions.select().eq('id', sessionId).maybeSingle();
    if (data == null) return null;

    // Cargar session_questions
    final sqData = await _sb.sessionQuestions
        .select()
        .eq('session_id', sessionId)
        .order('question_order');

    final questions =
        sqData
            .map<SessionQuestion>(
              (row) => SessionQuestion(
                questionId: row['question_id'] as int,
                order: row['question_order'] as int,
                chosenKey: row['chosen_key'] as String?,
                isCorrect: row['is_correct'] as bool?,
                timeMs: row['time_ms'] as int?,
                answeredAt:
                    row['answered_at'] != null
                        ? DateTime.parse(row['answered_at'] as String)
                        : null,
              ),
            )
            .toList();

    return Session(
      id: data['id'] as int,
      userId: data['user_id'] as String?,
      config: SessionConfig(
        examId: data['exam_id'] as int,
        mode: SessionMode.values.firstWhere(
          (m) => m.code == data['mode'],
          orElse: () => SessionMode.practice,
        ),
        sectionId: data['section_id'] as int?,
        areaId: data['area_id'] as int?,
        skillId: data['skill_id'] as int?,
        numQuestions: data['total_questions'] as int? ?? questions.length,
      ),
      status:
          (data['is_completed'] as bool? ?? false)
              ? SessionStatus.completed
              : SessionStatus.inProgress,
      questions: questions,
      startedAt: DateTime.parse(data['started_at'] as String),
      endedAt:
          data['ended_at'] != null
              ? DateTime.parse(data['ended_at'] as String)
              : null,
    );
  }

  @override
  Future<List<Session>> getIncompleteSessions(int examId) async {
    final data = await _sb.sessions
        .select()
        .eq('user_id', _sb.userId)
        .eq('exam_id', examId)
        .eq('is_completed', false)
        .order('created_at', ascending: false)
        .limit(10);

    final sessions = <Session>[];
    for (final row in data) {
      final session = await getSession(row['id'] as int);
      if (session != null) sessions.add(session);
    }
    return sessions;
  }

  // ─── Respuestas ─────────────────────────────────────────────────────────

  @override
  Future<void> saveAnswer({
    required int sessionId,
    required int questionId,
    required String chosenKey,
    required bool isCorrect,
    required int timeMs,
    required SessionMode mode,
  }) async {
    // Actualizar session_question
    await _sb.sessionQuestions
        .update({
          'chosen_key': chosenKey,
          'is_correct': isCorrect,
          'time_ms': timeMs,
          'answered_at': DateTime.now().toIso8601String(),
        })
        .eq('session_id', sessionId)
        .eq('question_id', questionId);

    // Insertar attempt (desnormalizado para queries rápidos)
    await _sb.attempts.insert({
      'user_id': _sb.userId,
      'question_id': questionId,
      'session_id': sessionId,
      'chosen_key': chosenKey,
      'is_correct': isCorrect,
      'time_ms': timeMs,
      'mode': mode.code,
    });

    // Actualizar skill stats en servidor
    final question =
        await _sb.questions.select('skill_id').eq('id', questionId).single();

    await _sb.rpc(
      'update_skill_stats',
      params: {'p_user_id': _sb.userId, 'p_skill_id': question['skill_id']},
    );
  }

  // ─── Preguntas (lectura) ────────────────────────────────────────────────

  @override
  Future<List<int>> getAvailableQuestionIds({
    required int examId,
    int? sectionId,
    int? areaId,
    int? skillId,
  }) async {
    // Si hay skill, filtrar directamente
    if (skillId != null) {
      final data = await _sb.questions
          .select('id')
          .eq('skill_id', skillId)
          .eq('is_active', true);
      return data.map<int>((r) => r['id'] as int).toList();
    }

    // Si hay area, obtener skills del area y luego preguntas
    if (areaId != null) {
      final skillData = await _sb.skills
          .select('id')
          .eq('area_id', areaId)
          .eq('is_active', true);
      final skillIds = skillData.map<int>((r) => r['id'] as int).toList();
      if (skillIds.isEmpty) return [];

      final data = await _sb.questions
          .select('id')
          .inFilter('skill_id', skillIds)
          .eq('is_active', true);
      return data.map<int>((r) => r['id'] as int).toList();
    }

    // Si hay section, obtener areas → skills → questions
    if (sectionId != null) {
      final areaData = await _sb.areas
          .select('id')
          .eq('section_id', sectionId)
          .eq('is_active', true);
      final areaIds = areaData.map<int>((r) => r['id'] as int).toList();
      if (areaIds.isEmpty) return [];

      final skillData = await _sb.skills
          .select('id')
          .inFilter('area_id', areaIds)
          .eq('is_active', true);
      final skillIds = skillData.map<int>((r) => r['id'] as int).toList();
      if (skillIds.isEmpty) return [];

      final data = await _sb.questions
          .select('id')
          .inFilter('skill_id', skillIds)
          .eq('is_active', true);
      return data.map<int>((r) => r['id'] as int).toList();
    }

    // Exam-wide: todas las preguntas del set activo
    final setData =
        await _sb.questionSets
            .select('id')
            .eq('exam_id', examId)
            .eq('is_active', true)
            .limit(1)
            .single();

    final data = await _sb.questions
        .select('id')
        .eq('set_id', setData['id'] as int)
        .eq('is_active', true);
    return data.map<int>((r) => r['id'] as int).toList();
  }

  @override
  Future<List<Question>> getQuestionsByIds(List<int> ids) async {
    if (ids.isEmpty) return [];

    final data = await _sb.questions.select().inFilter('id', ids);

    return data.map<Question>((row) => _mapQuestion(row)).toList();
  }

  @override
  Future<Map<int, int>> getQuestionSkillMap(List<int> questionIds) async {
    if (questionIds.isEmpty) return {};

    final data = await _sb.questions
        .select('id, skill_id')
        .inFilter('id', questionIds);

    return {for (final row in data) row['id'] as int: row['skill_id'] as int};
  }

  @override
  Future<Map<int, List<int>>> getQuestionsBySkill({
    required int examId,
    int? sectionId,
  }) async {
    final ids = await getAvailableQuestionIds(
      examId: examId,
      sectionId: sectionId,
    );
    final skillMap = await getQuestionSkillMap(ids);

    final result = <int, List<int>>{};
    for (final entry in skillMap.entries) {
      result.putIfAbsent(entry.value, () => []).add(entry.key);
    }
    return result;
  }

  @override
  Future<Map<int, List<int>>> getQuestionsBySection({
    required int examId,
    List<int>? moduleIds,
  }) async {
    // Obtener secciones del examen
    var query = _sb.sections
        .select('id')
        .eq('exam_id', examId)
        .eq('is_active', true);
    if (moduleIds != null && moduleIds.isNotEmpty) {
      query = query.inFilter('id', moduleIds);
    }
    final sectionData = await query;

    final result = <int, List<int>>{};
    for (final section in sectionData) {
      final sId = section['id'] as int;
      final qIds = await getAvailableQuestionIds(
        examId: examId,
        sectionId: sId,
      );
      result[sId] = qIds;
    }
    return result;
  }

  @override
  Future<Map<int, int>> getSectionQuotas({
    required int examId,
    List<int>? moduleIds,
  }) async {
    var query = _sb.sections
        .select('id, num_questions')
        .eq('exam_id', examId)
        .eq('is_active', true);
    if (moduleIds != null && moduleIds.isNotEmpty) {
      query = query.inFilter('id', moduleIds);
    }
    final data = await query;

    return {
      for (final row in data)
        row['id'] as int: row['num_questions'] as int? ?? 30,
    };
  }

  // ─── Stats del usuario ──────────────────────────────────────────────────

  @override
  Future<Map<int, QuestionAttemptStats>> getUserQuestionStats(
    List<int> questionIds,
  ) async {
    if (questionIds.isEmpty) return {};

    final data = await _sb.attempts
        .select('question_id, is_correct, time_ms, created_at')
        .eq('user_id', _sb.userId)
        .inFilter('question_id', questionIds)
        .order('created_at', ascending: false);

    final map = <int, QuestionAttemptStats>{};
    // Agrupar por question_id
    final grouped = <int, List<Map<String, dynamic>>>{};
    for (final row in data) {
      final qId = row['question_id'] as int;
      grouped.putIfAbsent(qId, () => []).add(row);
    }

    // Obtener skill_id para cada pregunta
    final skillMap = await getQuestionSkillMap(questionIds);

    for (final entry in grouped.entries) {
      final rows = entry.value;
      final totalAttempts = rows.length;
      final correctAttempts = rows.where((r) => r['is_correct'] == true).length;
      final lastRow = rows.first; // ya ordenado DESC

      map[entry.key] = QuestionAttemptStats(
        questionId: entry.key,
        skillId: skillMap[entry.key] ?? 0,
        totalAttempts: totalAttempts,
        correctAttempts: correctAttempts,
        lastAttemptAt: DateTime.parse(lastRow['created_at'] as String),
        lastWasCorrect: lastRow['is_correct'] as bool? ?? false,
      );
    }

    // Incluir las que nunca se han intentado
    for (final qId in questionIds) {
      if (!map.containsKey(qId)) {
        map[qId] = QuestionAttemptStats(
          questionId: qId,
          skillId: skillMap[qId] ?? 0,
        );
      }
    }

    return map;
  }

  @override
  Future<Map<int, SkillStats>> getUserSkillStats(int examId) async {
    final data = await _sb.userSkillStats
        .select('skill_id, accuracy, total_attempts, last_practiced_at')
        .eq('user_id', _sb.userId);

    return {
      for (final row in data)
        row['skill_id'] as int: SkillStats(
          skillId: row['skill_id'] as int,
          accuracy: (row['accuracy'] as num?)?.toDouble() ?? 0,
          totalAttempts: row['total_attempts'] as int? ?? 0,
          lastPracticedAt:
              row['last_practiced_at'] != null
                  ? DateTime.parse(row['last_practiced_at'] as String)
                  : null,
        ),
    };
  }

  @override
  Future<void> refreshSkillStats(int skillId) async {
    await _sb.rpc(
      'update_skill_stats',
      params: {'p_user_id': _sb.userId, 'p_skill_id': skillId},
    );
  }

  // ─── Mapping helpers ───────────────────────────────────────────────────

  /// Mapea una fila de la tabla questions a un Question dart.
  Question _mapQuestion(Map<String, dynamic> row) {
    final optionsJson = row['options_json'] as List<dynamic>? ?? [];
    final options =
        optionsJson.asMap().entries.map<Option>((entry) {
          final opt = entry.value as Map<String, dynamic>;
          return Option(
            id: entry.key,
            text: opt['text'] as String? ?? '',
            imagePath: opt['image'] as String?,
          );
        }).toList();

    // correctOptionId: mapear correct_key ('a','b','c','d') → índice
    final correctKey = row['correct_key'] as String? ?? 'a';
    final correctIndex = correctKey.codeUnitAt(0) - 'a'.codeUnitAt(0);

    final stemImagesJson = row['stem_images_json'] as List<dynamic>? ?? [];
    final explanationImagesJson =
        row['explanation_images_json'] as List<dynamic>? ?? [];

    final difficultyStr = row['difficulty'] as String? ?? 'medium';
    final difficulty = QuestionDifficulty.values.firstWhere(
      (d) => d.name == difficultyStr,
      orElse: () => QuestionDifficulty.medium,
    );

    final tagsJson = row['tags_json'] as List<dynamic>? ?? [];

    return Question(
      id: row['id'] as int,
      text: row['stem'] as String? ?? '',
      options: options,
      correctOptionId: correctIndex,
      category: QuestionCategory.senales, // TODO: mapear desde section/area
      skillId: row['skill_id'] as int?,
      imagePath: row['stem_image'] as String?,
      stemImages: stemImagesJson.cast<String>(),
      explanation: row['explanation'] as String?,
      explanationImages: explanationImagesJson.cast<String>(),
      difficulty: difficulty,
      tags: tagsJson.cast<String>(),
    );
  }
}
