import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/storage_keys.dart';

part 'secure_storage_service.g.dart';

/// Wraps [FlutterSecureStorage] for the handful of values that must never
/// touch Hive/SharedPreferences: auth tokens and the biometric-login flag.
/// Backed by Keystore on Android and Keychain on iOS.
class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await Future.wait([
      _storage.write(key: StorageKeys.accessToken, value: accessToken),
      _storage.write(key: StorageKeys.refreshToken, value: refreshToken),
    ]);
  }

  Future<String?> get accessToken => _storage.read(key: StorageKeys.accessToken);

  Future<String?> get refreshToken => _storage.read(key: StorageKeys.refreshToken);

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: StorageKeys.accessToken),
      _storage.delete(key: StorageKeys.refreshToken),
    ]);
  }

  Future<void> setBiometricEnabled(bool enabled) =>
      _storage.write(key: StorageKeys.biometricEnabled, value: enabled.toString());

  Future<bool> get isBiometricEnabled async =>
      (await _storage.read(key: StorageKeys.biometricEnabled)) == 'true';

  Future<void> clearAll() => _storage.deleteAll();
}

@Riverpod(keepAlive: true)
SecureStorageService secureStorageService(SecureStorageServiceRef ref) {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  return SecureStorageService(storage);
}
