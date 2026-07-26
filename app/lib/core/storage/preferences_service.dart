import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';

part 'preferences_service.g.dart';

/// Lightweight app preferences that are safe to store unencrypted:
/// onboarding state, theme mode, locale, and the last-used role (used to
/// pick a sensible default on the login screen's role switcher).
class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  bool get hasCompletedOnboarding => _prefs.getBool(StorageKeys.onboardingComplete) ?? false;
  Future<void> setOnboardingComplete() => _prefs.setBool(StorageKeys.onboardingComplete, true);

  String? get themeMode => _prefs.getString(StorageKeys.themeMode);
  Future<void> setThemeMode(String mode) => _prefs.setString(StorageKeys.themeMode, mode);

  String? get localeCode => _prefs.getString(StorageKeys.localeCode);
  Future<void> setLocaleCode(String code) => _prefs.setString(StorageKeys.localeCode, code);

  String? get lastUserRole => _prefs.getString(StorageKeys.lastUserRole);
  Future<void> setLastUserRole(String role) => _prefs.setString(StorageKeys.lastUserRole, role);
}

@Riverpod(keepAlive: true)
PreferencesService preferencesService(PreferencesServiceRef ref) {
  throw UnimplementedError('Overridden in ProviderScope with the resolved SharedPreferences instance');
}
