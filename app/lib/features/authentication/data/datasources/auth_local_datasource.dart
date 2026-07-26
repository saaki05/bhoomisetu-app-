import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';

part 'auth_local_datasource.g.dart';

const _cachedUserKey = 'auth.cached_user';

/// Persists the auth session: tokens go to secure storage (Keystore/
/// Keychain), the last-known user profile goes to the JSON cache so the
/// splash screen can restore a session instantly without a network round
/// trip, then refresh it in the background.
class AuthLocalDataSource {
  AuthLocalDataSource(this._secureStorage, this._cache);

  final SecureStorageService _secureStorage;
  final LocalCacheService _cache;

  Future<void> saveSession({required UserModel user, required String accessToken, required String refreshToken}) {
    return Future.wait([
      _secureStorage.saveTokens(accessToken: accessToken, refreshToken: refreshToken),
      _cache.putJson(_cachedUserKey, user.toJson()),
    ]);
  }

  Future<void> updateCachedUser(UserModel user) => _cache.putJson(_cachedUserKey, user.toJson());

  UserModel? get cachedUser {
    final json = _cache.getJson(_cachedUserKey);
    if (json == null) return null;
    try {
      return UserModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<bool> get hasStoredSession async => (await _secureStorage.accessToken) != null;

  Future<String?> get refreshToken => _secureStorage.refreshToken;

  Future<void> clearSession() {
    return Future.wait([
      _secureStorage.clearTokens(),
      _cache.remove(_cachedUserKey),
    ]);
  }
}

@Riverpod(keepAlive: true)
AuthLocalDataSource authLocalDataSource(AuthLocalDataSourceRef ref) => AuthLocalDataSource(
      ref.watch(secureStorageServiceProvider),
      ref.watch(localCacheServiceProvider),
    );
