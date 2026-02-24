/// ─── Cache Service ──────────────────────────────────────────────────────────
/// Simple in-memory caching service with TTL (Time To Live)
/// Prevents redundant API calls for frequently accessed data
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache entry with value and expiration
class _CacheEntry<T> {
  final T value;
  final DateTime expiresAt;

  _CacheEntry(this.value, this.expiresAt);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Simple cache service with in-memory and optional persistent storage
class CacheService {
  // ─── Singleton ──────────────────────────────────────────────────────────
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  // In-memory cache
  final Map<String, _CacheEntry<dynamic>> _cache = {};

  // Default TTL: 5 minutes
  static const Duration defaultTTL = Duration(minutes: 5);

  // ─── Core methods ───────────────────────────────────────────────────────

  /// Store a value in cache with optional TTL
  void set<T>(String key, T value, {Duration ttl = defaultTTL}) {
    final expiresAt = DateTime.now().add(ttl);
    _cache[key] = _CacheEntry<T>(value, expiresAt);
    debugPrint('✅ Cache SET: $key (expires in ${ttl.inMinutes}m)');
  }

  /// Get a value from cache, returns null if expired or not found
  T? get<T>(String key) {
    final entry = _cache[key];

    if (entry == null) {
      debugPrint('❌ Cache MISS: $key (not found)');
      return null;
    }

    if (entry.isExpired) {
      _cache.remove(key);
      debugPrint('⏰ Cache MISS: $key (expired)');
      return null;
    }

    debugPrint('✅ Cache HIT: $key');
    return entry.value as T;
  }

  /// Check if a key exists and is not expired
  bool has(String key) {
    final entry = _cache[key];
    if (entry == null) return false;
    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }
    return true;
  }

  /// Remove a specific key from cache
  void remove(String key) {
    _cache.remove(key);
    debugPrint('🗑️ Cache REMOVE: $key');
  }

  /// Clear all cache
  void clear() {
    _cache.clear();
    debugPrint('🗑️ Cache CLEAR: all entries');
  }

  /// Clear expired entries
  void clearExpired() {
    _cache.removeWhere((key, entry) => entry.isExpired);
    debugPrint('🗑️ Cache CLEAR: expired entries');
  }

  /// Clear all cache entries related to questions
  void clearQuestionsCache() {
    _cache.removeWhere((key, entry) => key.contains('questions_'));
    debugPrint('🗑️ Cache CLEAR: all question entries');
  }

  /// Clear cache for a specific skill, area, or section
  void clearQuestionsCacheFor({int? skillId, int? areaId, int? sectionId}) {
    if (skillId != null) {
      remove(CacheKeys.questionsForSkill(skillId));
    }
    if (areaId != null) {
      remove(CacheKeys.questionsForArea(areaId));
    }
    if (sectionId != null) {
      remove(CacheKeys.questionsForSection(sectionId));
    }
    debugPrint(
      '🗑️ Cache CLEAR: questions for skill=$skillId, area=$areaId, section=$sectionId',
    );
  }

  // ─── Persistent cache (SharedPreferences) ───────────────────────────────

  /// Save to persistent storage (JSON serializable data only)
  Future<void> setPersistent(
    String key,
    Map<String, dynamic> value, {
    Duration ttl = defaultTTL,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final expiresAt = DateTime.now().add(ttl).millisecondsSinceEpoch;

    final data = {'value': value, 'expiresAt': expiresAt};

    await prefs.setString(key, jsonEncode(data));
    debugPrint('💾 Persistent cache SET: $key');
  }

  /// Get from persistent storage
  Future<Map<String, dynamic>?> getPersistent(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(key);

    if (jsonStr == null) {
      debugPrint('❌ Persistent cache MISS: $key (not found)');
      return null;
    }

    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final expiresAt = data['expiresAt'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now > expiresAt) {
        await prefs.remove(key);
        debugPrint('⏰ Persistent cache MISS: $key (expired)');
        return null;
      }

      debugPrint('✅ Persistent cache HIT: $key');
      return data['value'] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ Persistent cache ERROR: $key - $e');
      await prefs.remove(key);
      return null;
    }
  }

  /// Remove from persistent storage
  Future<void> removePersistent(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    debugPrint('🗑️ Persistent cache REMOVE: $key');
  }

  /// Clear all persistent cache with a specific prefix
  Future<void> clearPersistentByPrefix(String prefix) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(prefix)).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
    debugPrint('🗑️ Persistent cache CLEAR: $prefix* (${keys.length} keys)');
  }

  // ─── Helper: Get or Set pattern ─────────────────────────────────────────

  /// Get from cache or fetch using provided function
  Future<T> getOrFetch<T>({
    required String key,
    required Future<T> Function() fetch,
    Duration ttl = defaultTTL,
    bool usePersistent = false,
  }) async {
    // Try in-memory cache first
    final cached = get<T>(key);
    if (cached != null) return cached;

    // Try persistent cache if enabled
    if (usePersistent) {
      final persistent = await getPersistent(key);
      if (persistent != null) {
        // Store in memory for faster access
        set(key, persistent as T, ttl: ttl);
        return persistent as T;
      }
    }

    // Fetch from source
    debugPrint('🔄 Cache FETCH: $key');
    final value = await fetch();

    // Store in cache
    set(key, value, ttl: ttl);

    // Store in persistent if enabled and JSON serializable
    if (usePersistent && value is Map<String, dynamic>) {
      await setPersistent(key, value, ttl: ttl);
    }

    return value;
  }
}

/// Predefined cache keys for the app
class CacheKeys {
  // Exam hierarchy
  static String examHierarchy(int examId) => 'exam_hierarchy_$examId';

  // Sections
  static String sections(int examId) => 'sections_$examId';

  // Areas
  static String areas(int sectionId) => 'areas_section_$sectionId';

  // Skills
  static String skills(int areaId) => 'skills_area_$areaId';

  // Questions
  static String questionsForSkill(int skillId) => 'questions_skill_$skillId';
  static String questionsForArea(int areaId) => 'questions_area_$areaId';
  static String questionsForSection(int sectionId) =>
      'questions_section_$sectionId';

  // User profile
  static const String userProfile = 'user_profile';

  // Stats
  static const String userStats = 'user_stats';
}
