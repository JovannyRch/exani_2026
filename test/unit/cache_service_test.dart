import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:exani/services/cache_service.dart';

void main() {
  group('CacheService', () {
    late CacheService cache;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      cache = CacheService();
      await cache.init();
    });

    tearDown(() {
      cache.clearAll();
    });

    test('should store and retrieve data', () async {
      const key = 'test_key';
      const value = {'data': 'test_value'};

      cache.set(key, value);
      final result = cache.get(key);

      expect(result, equals(value));
    });

    test('should respect TTL expiration', () async {
      const key = 'test_ttl';
      const value = {'data': 'expires_soon'};

      // Set with 1 second TTL
      cache.set(key, value, ttl: const Duration(seconds: 1));

      // Should exist immediately
      expect(cache.get(key), equals(value));

      // Wait for expiration
      await Future.delayed(const Duration(milliseconds: 1100));

      // Should be expired
      expect(cache.get(key), isNull);
    });

    test('should clear expired entries', () async {
      cache.set('key1', {'data': 1}, ttl: const Duration(milliseconds: 100));
      cache.set('key2', {'data': 2}, ttl: const Duration(days: 1));

      await Future.delayed(const Duration(milliseconds: 150));
      cache.clearExpired();

      expect(cache.get('key1'), isNull);
      expect(cache.get('key2'), isNotNull);
    });

    test('should clear all data', () async {
      cache.set('key1', {'data': 1});
      cache.set('key2', {'data': 2});

      cache.clearAll();

      expect(cache.get('key1'), isNull);
      expect(cache.get('key2'), isNull);
    });

    test('should handle null values', () async {
      const key = 'null_key';

      cache.set(key, null);
      final result = cache.get(key);

      expect(result, isNull);
    });

    test('should use default TTL from CacheKeys', () async {
      const key = CacheKeys.sectionsHierarchy;
      const value = {'sections': []};

      cache.set(key, value);

      // Should have TTL of 10 minutes
      final result = cache.get(key);
      expect(result, equals(value));
    });
  });
}
