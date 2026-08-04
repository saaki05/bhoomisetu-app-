/// Keys used across secure storage, Hive boxes, and shared preferences.
/// Centralized so a rename never causes a silent key mismatch.
abstract final class StorageKeys {
  // Secure storage (tokens, credentials)
  static const String accessToken = 'bhoomisetu.access_token';
  static const String refreshToken = 'bhoomisetu.refresh_token';
  static const String biometricEnabled = 'bhoomisetu.biometric_enabled';

  // Hive boxes
  static const String cacheBox = 'bhoomisetu_cache_box_v2';
  static const String draftsBox = 'bhoomisetu_drafts_box_v2';

  // Shared preferences
  static const String onboardingComplete = 'bhoomisetu.onboarding_complete';
  static const String themeMode = 'bhoomisetu.theme_mode';
  static const String localeCode = 'bhoomisetu.locale_code';
  static const String lastUserRole = 'bhoomisetu.last_user_role';
}
