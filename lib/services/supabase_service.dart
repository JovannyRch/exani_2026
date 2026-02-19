/// ─── Supabase Service ────────────────────────────────────────────────────────
/// Singleton que centraliza el acceso a Supabase.
/// - Inicialización con URL + anon key desde const.dart
/// - Shortcuts para auth, client, tablas frecuentes
/// - Helpers para el user actual
library;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:exani/services/cache_service.dart';
/* import 'package:exani/const/const.dart'; */

class SupabaseService {
  // ─── Singleton ──────────────────────────────────────────────────────────
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _initialized = false;

  // ─── Inicialización ─────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;

    await Supabase.initialize(
      url: 'https://quicsqnemgdvzmldalcq.supabase.co',
      anonKey: 'sb_publishable_AUvnD8jXNN5HoCzUHf0i-g_ziZ7Lp3L',
    );

    _initialized = true;
    debugPrint('✅ Supabase initialized');
  }

  // ─── Shortcuts ──────────────────────────────────────────────────────────

  SupabaseClient get client => Supabase.instance.client;
  GoTrueClient get auth => client.auth;

  /// Usuario actual o null si no está logueado.
  User? get currentUser => auth.currentUser;

  /// ID del usuario actual (lanza si no hay sesión).
  String get userId {
    final user = currentUser;
    if (user == null) throw Exception('No hay sesión activa');
    return user.id;
  }

  /// ¿Tiene sesión activa?
  bool get isLoggedIn => currentUser != null;

  /// Stream de cambios de autenticación.
  Stream<AuthState> get authStateChanges => auth.onAuthStateChange;

  // ─── Auth helpers ───────────────────────────────────────────────────────

  /// Sign up con email + password.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    return await auth.signUp(
      email: email,
      password: password,
      data: displayName != null ? {'name': displayName} : null,
    );
  }

  /// Sign in con email + password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await auth.signInWithPassword(email: email, password: password);
  }

  /// Sign in anónimo (para probar sin registro).
  Future<AuthResponse> signInAnonymously() async {
    return await auth.signInAnonymously();
  }

  /// Cerrar sesión.
  Future<void> signOut() async {
    await auth.signOut();
  }

  // ─── Table shortcuts ───────────────────────────────────────────────────

  /// Tabla de perfiles de usuario.
  SupabaseQueryBuilder get profiles => client.from('profiles');

  /// Tabla de exámenes.
  SupabaseQueryBuilder get exams => client.from('exams');

  /// Tabla de secciones.
  SupabaseQueryBuilder get sections => client.from('sections');

  /// Tabla de áreas.
  SupabaseQueryBuilder get areas => client.from('areas');

  /// Tabla de skills.
  SupabaseQueryBuilder get skills => client.from('skills');

  /// Tabla de preguntas.
  SupabaseQueryBuilder get questions => client.from('questions');

  /// Tabla de question_sets.
  SupabaseQueryBuilder get questionSets => client.from('question_sets');

  /// Tabla de sesiones.
  SupabaseQueryBuilder get sessions => client.from('sessions');

  /// Tabla de session_questions.
  SupabaseQueryBuilder get sessionQuestions => client.from('session_questions');

  /// Tabla de attempts.
  SupabaseQueryBuilder get attempts => client.from('attempts');

  /// Tabla de user_skill_stats.
  SupabaseQueryBuilder get userSkillStats => client.from('user_skill_stats');

  /// Tabla de user_area_stats.
  SupabaseQueryBuilder get userAreaStats => client.from('user_area_stats');

  /// Tabla de user_exam_stats.
  SupabaseQueryBuilder get userExamStats => client.from('user_exam_stats');

  /// Tabla de favoritos.
  SupabaseQueryBuilder get favorites => client.from('user_favorites');

  /// Tabla de leaderboard semanal.
  SupabaseQueryBuilder get leaderboard => client.from('leaderboards_weekly');

  /// Tabla de sync queue (offline).
  SupabaseQueryBuilder get syncQueue => client.from('sync_queue');

  // ─── RPC (funciones de servidor) ────────────────────────────────────────

  /// Llama una función RPC de Supabase.
  Future<dynamic> rpc(String functionName, {Map<String, dynamic>? params}) {
    return client.rpc(functionName, params: params ?? {});
  }

  // ─── Profile helpers ────────────────────────────────────────────────────

  /// Obtiene el perfil del usuario actual.
  Future<Map<String, dynamic>?> getMyProfile() async {
    if (!isLoggedIn) return null;
    final data = await profiles.select().eq('id', userId).maybeSingle();
    return data;
  }

  /// Actualiza campos del perfil.
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    await profiles.update(updates).eq('id', userId);
  }

  /// Guarda la selección de examen + fecha + módulos del onboarding.
  Future<void> saveOnboardingData({
    required int examId,
    DateTime? examDate,
    List<int> moduleIds = const [],
  }) async {
    await profiles
        .update({
          'exam_id': examId,
          'exam_date': examDate?.toIso8601String().substring(0, 10),
          'modules_json': moduleIds,
          'onboarding_done': true,
        })
        .eq('id', userId);
  }

  // ─── Content helpers ────────────────────────────────────────────────────

  /// Obtiene la jerarquía completa: sections → areas → skills para un examen.
  /// Retorna lista de secciones con sus áreas y skills anidados.
  /// Usa cache para evitar llamadas redundantes (TTL: 10 minutos).
  Future<List<Map<String, dynamic>>> getSectionsHierarchy(int examId) async {
    final cacheKey = CacheKeys.examHierarchy(examId);

    // Try to get from cache first
    final cached = CacheService().get<List<Map<String, dynamic>>>(cacheKey);
    if (cached != null) {
      return cached;
    }

    // Fetch from Supabase
    debugPrint('🔄 Fetching sections hierarchy for exam $examId...');

    // 1. Obtener secciones
    final sectionsData = await sections
        .select()
        .eq('exam_id', examId)
        .eq('is_active', true)
        .order('sort_order');

    final List<Map<String, dynamic>> result = [];

    for (final section in sectionsData) {
      final sectionId = section['id'] as int;

      // 2. Obtener áreas de esta sección
      final areasData = await areas
          .select()
          .eq('section_id', sectionId)
          .eq('is_active', true)
          .order('sort_order');

      final List<Map<String, dynamic>> areasWithSkills = [];

      for (final area in areasData) {
        final areaId = area['id'] as int;

        // 3. Obtener skills de esta área
        final skillsData = await skills
            .select()
            .eq('area_id', areaId)
            .eq('is_active', true)
            .order('sort_order');

        areasWithSkills.add({...area, 'skills': skillsData});
      }

      result.add({...section, 'areas': areasWithSkills});
    }

    // Cache the result for 10 minutes
    CacheService().set(cacheKey, result, ttl: const Duration(minutes: 10));

    return result;
  }

  /// Cuenta preguntas disponibles para una skill específica.
  /// Usa cache para evitar conteos redundantes (TTL: 5 minutos).
  Future<int> countQuestionsForSkill(int skillId) async {
    final cacheKey = 'count_${CacheKeys.questionsForSkill(skillId)}';

    // Try cache first
    final cached = CacheService().get<int>(cacheKey);
    if (cached != null) return cached;

    // Fetch from database
    final response = await client
        .from('questions')
        .select('id')
        .eq('skill_id', skillId)
        .eq('is_active', true);

    final count = (response as List).length;

    // Cache for 5 minutes
    CacheService().set(cacheKey, count, ttl: const Duration(minutes: 5));

    return count;
  }

  /// Cuenta preguntas disponibles para un área (suma de todas sus skills).
  /// Usa cache para evitar conteos redundantes (TTL: 5 minutos).
  Future<int> countQuestionsForArea(int areaId) async {
    final cacheKey = 'count_${CacheKeys.questionsForArea(areaId)}';

    // Try cache first
    final cached = CacheService().get<int>(cacheKey);
    if (cached != null) return cached;

    // Get all skill IDs for this area
    final skillsData = await skills
        .select('id')
        .eq('area_id', areaId)
        .eq('is_active', true);

    if (skillsData.isEmpty) return 0;

    final skillIds = skillsData.map((s) => s['id'] as int).toList();

    final response = await client
        .from('questions')
        .select('id')
        .inFilter('skill_id', skillIds)
        .eq('is_active', true);

    final count = (response as List).length;

    // Cache for 5 minutes
    CacheService().set(cacheKey, count, ttl: const Duration(minutes: 5));

    return count;
  }

  // ─── Questions fetching ─────────────────────────────────────────────────

  /// Obtiene preguntas por skill_id desde la BD activa.
  /// Usa cache para mejorar performance (TTL: 2 minutos).
  Future<List<Map<String, dynamic>>> getQuestionsBySkill({
    required int skillId,
    int? limit,
  }) async {
    final cacheKey = '${CacheKeys.questionsForSkill(skillId)}_limit_$limit';

    // Try cache first
    final cached = CacheService().get<List<Map<String, dynamic>>>(cacheKey);
    if (cached != null) return cached;

    // Fetch from database
    var query = questions
        .select()
        .eq('skill_id', skillId)
        .eq('is_active', true)
        .order('id');

    if (limit != null) {
      query = query.limit(limit);
    }

    final result = await query;

    // Cache for 2 minutes (shorter TTL for questions)
    CacheService().set(cacheKey, result, ttl: const Duration(minutes: 2));

    return result;
  }

  /// Obtiene preguntas por área (todas las skills del área).
  /// Usa cache para mejorar performance (TTL: 2 minutos).
  Future<List<Map<String, dynamic>>> getQuestionsByArea({
    required int areaId,
    int? limit,
  }) async {
    final cacheKey = '${CacheKeys.questionsForArea(areaId)}_limit_$limit';

    // Try cache first
    final cached = CacheService().get<List<Map<String, dynamic>>>(cacheKey);
    if (cached != null) return cached;

    // Get all skill IDs for this area
    final skillsData = await skills
        .select('id')
        .eq('area_id', areaId)
        .eq('is_active', true);

    if (skillsData.isEmpty) return [];

    final skillIds = skillsData.map((s) => s['id'] as int).toList();

    var query = questions
        .select()
        .inFilter('skill_id', skillIds)
        .eq('is_active', true)
        .order('id');

    if (limit != null) {
      query = query.limit(limit);
    }

    final result = await query;

    // Cache for 2 minutes
    CacheService().set(cacheKey, result, ttl: const Duration(minutes: 2));

    return result;
  }

  /// Obtiene preguntas por sección (todas las áreas de la sección).
  /// Usa cache para mejorar performance (TTL: 2 minutos).
  Future<List<Map<String, dynamic>>> getQuestionsBySection({
    required int sectionId,
    int? limit,
  }) async {
    final cacheKey = '${CacheKeys.questionsForSection(sectionId)}_limit_$limit';

    // Try cache first
    final cached = CacheService().get<List<Map<String, dynamic>>>(cacheKey);
    if (cached != null) return cached;

    // Get all areas for this section
    final areasData = await areas
        .select('id')
        .eq('section_id', sectionId)
        .eq('is_active', true);

    if (areasData.isEmpty) return [];

    final areaIds = areasData.map((a) => a['id'] as int).toList();

    // Get all skills for these areas
    final skillsData = await skills
        .select('id')
        .inFilter('area_id', areaIds)
        .eq('is_active', true);

    if (skillsData.isEmpty) return [];

    final skillIds = skillsData.map((s) => s['id'] as int).toList();

    var query = questions
        .select()
        .inFilter('skill_id', skillIds)
        .eq('is_active', true)
        .order('id');

    if (limit != null) {
      query = query.limit(limit);
    }

    final result = await query;

    // Cache for 2 minutes
    CacheService().set(cacheKey, result, ttl: const Duration(minutes: 2));

    return result;
  }

  // ─── User Stats helpers ─────────────────────────────────────────────────

  /// Obtiene el área más débil del usuario (menor accuracy con al menos 5 intentos).
  /// Retorna el nombre del área o null si no hay datos suficientes.
  /// Usa cache con TTL de 1 minuto.
  Future<String?> getWeakestAreaName({required int examId}) async {
    if (!isLoggedIn) return null;

    final cacheKey = 'weakest_area_${userId}_$examId';

    // Try cache first
    final cached = CacheService().get<String>(cacheKey);
    if (cached != null) return cached;

    try {
      // Get all areas for this exam with their stats
      final data = await client
          .from('user_area_stats')
          .select(
            'area_id, accuracy, total_attempts, areas!inner(name, section_id, sections!inner(exam_id))',
          )
          .eq('user_id', userId)
          .gte('total_attempts', 5) // At least 5 attempts to be considered
          .order('accuracy', ascending: true)
          .limit(1);

      if (data.isEmpty) return null;

      // Filter by exam_id (done in memory since we need nested data)
      final filtered =
          data.where((row) {
            final areas = row['areas'] as Map<String, dynamic>?;
            if (areas == null) return false;
            final sections = areas['sections'] as Map<String, dynamic>?;
            if (sections == null) return false;
            return sections['exam_id'] == examId;
          }).toList();

      if (filtered.isEmpty) return null;

      final weakestArea = filtered.first;
      final areaData = weakestArea['areas'] as Map<String, dynamic>;
      final areaName = areaData['name'] as String;

      // Cache for 1 minute
      CacheService().set(cacheKey, areaName, ttl: const Duration(minutes: 1));

      debugPrint(
        '📊 Weakest area for user: $areaName (${weakestArea['accuracy']}% accuracy)',
      );

      return areaName;
    } catch (e) {
      debugPrint('❌ Error getting weakest area: $e');
      return null;
    }
  }

  /// Obtiene la configuración activa de un examen.
  /// Retorna las reglas (total questions, duration, sections) desde exam_configs.
  Future<Map<String, dynamic>?> getExamConfig(int examId) async {
    try {
      final data =
          await client
              .from('exam_configs')
              .select('rules_json')
              .eq('exam_id', examId)
              .eq('is_active', true)
              .maybeSingle();

      if (data == null) return null;

      return data['rules_json'] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ Error getting exam config: $e');
      return null;
    }
  }
}
