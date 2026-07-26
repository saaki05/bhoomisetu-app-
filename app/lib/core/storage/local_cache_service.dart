import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/storage_keys.dart';
import '../exceptions/app_exception.dart';

part 'local_cache_service.g.dart';

/// Offline-first JSON cache backed by Hive. Feature data sources store the
/// already-serialized DTO map (`model.toJson()`) under a namespaced key and
/// read it back the same way, so no per-model Hive type adapters/codegen
/// are needed — one generic box serves every feature.
class LocalCacheService {
  LocalCacheService(this._box);

  final Box<String> _box;

  Future<void> putJson(String key, Map<String, dynamic> value) async {
    try {
      await _box.put(key, jsonEncode(value));
    } catch (_) {
      throw const CacheException('Failed to write to local cache');
    }
  }

  Future<void> putJsonList(String key, List<Map<String, dynamic>> value) async {
    try {
      await _box.put(key, jsonEncode(value));
    } catch (_) {
      throw const CacheException('Failed to write to local cache');
    }
  }

  Map<String, dynamic>? getJson(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>>? getJsonList(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  DateTime? cachedAt(String key) => _box.containsKey('$key.cachedAt')
      ? DateTime.tryParse(_box.get('$key.cachedAt') ?? '')
      : null;

  Future<void> markCachedNow(String key) => _box.put('$key.cachedAt', DateTime.now().toIso8601String());

  Future<void> remove(String key) => _box.delete(key);

  Future<void> clear() => _box.clear();
}

@Riverpod(keepAlive: true)
LocalCacheService localCacheService(LocalCacheServiceRef ref) {
  final box = Hive.box<String>(StorageKeys.cacheBox);
  return LocalCacheService(box);
}
