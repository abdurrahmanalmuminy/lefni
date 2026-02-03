import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lefni/utils/logger.dart';

/// Service for local caching of frequently accessed data
class CacheService {
  static const String _cachePrefix = 'lefni_cache_';
  static const Duration _defaultTtl = Duration(hours: 1);

  /// Get cached data
  static Future<T?> get<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final cacheData = prefs.getString(cacheKey);
      
      if (cacheData == null) {
        return null;
      }

      final decoded = jsonDecode(cacheData) as Map<String, dynamic>;
      final timestamp = DateTime.parse(decoded['timestamp'] as String);
      final ttl = Duration(seconds: decoded['ttl'] as int? ?? _defaultTtl.inSeconds);
      
      // Check if cache is expired
      if (DateTime.now().difference(timestamp) > ttl) {
        await prefs.remove(cacheKey);
        return null;
      }

      return fromJson(decoded['data'] as Map<String, dynamic>);
    } catch (e) {
      AppLogger.warning('Failed to get cache: $key', e);
      return null;
    }
  }

  /// Set cached data
  static Future<void> set<T>(
    String key,
    T data,
    Map<String, dynamic> Function(T) toJson, {
    Duration? ttl,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final cacheData = {
        'data': toJson(data),
        'timestamp': DateTime.now().toIso8601String(),
        'ttl': (ttl ?? _defaultTtl).inSeconds,
      };
      
      await prefs.setString(cacheKey, jsonEncode(cacheData));
    } catch (e) {
      AppLogger.warning('Failed to set cache: $key', e);
    }
  }

  /// Remove cached data
  static Future<void> remove(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      await prefs.remove(cacheKey);
    } catch (e) {
      AppLogger.warning('Failed to remove cache: $key', e);
    }
  }

  /// Clear all cache
  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_cachePrefix));
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      AppLogger.warning('Failed to clear cache', e);
    }
  }

  /// Check if cache exists and is valid
  static Future<bool> exists(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final cacheData = prefs.getString(cacheKey);
      
      if (cacheData == null) {
        return false;
      }

      final decoded = jsonDecode(cacheData) as Map<String, dynamic>;
      final timestamp = DateTime.parse(decoded['timestamp'] as String);
      final ttl = Duration(seconds: decoded['ttl'] as int? ?? _defaultTtl.inSeconds);
      
      return DateTime.now().difference(timestamp) <= ttl;
    } catch (e) {
      return false;
    }
  }
}
