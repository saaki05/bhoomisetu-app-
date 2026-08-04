import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Shows external sign-in methods only after their provider configuration is
/// complete, so users are never sent into a flow that is known to fail.
abstract final class AuthFeatureFlags {
  static bool get googleEnabled =>
      dotenv.isInitialized &&
      dotenv.env['GOOGLE_AUTH_ENABLED']?.toLowerCase() == 'true';

  static bool get phoneOtpEnabled =>
      dotenv.isInitialized &&
      dotenv.env['PHONE_AUTH_ENABLED']?.toLowerCase() == 'true';
}
