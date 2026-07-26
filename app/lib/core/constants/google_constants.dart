import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Google API keys/client IDs read from `.env`. Kept separate from
/// [ApiConstants] since these are third-party integration config rather
/// than our own backend's contract.
abstract final class GoogleConstants {
  static String? get signInWebClientId {
    final value = dotenv.env['GOOGLE_SIGN_IN_WEB_CLIENT_ID'];
    return (value == null || value.isEmpty) ? null : value;
  }

  static String? get mapsApiKey {
    final value = dotenv.env['GOOGLE_MAPS_API_KEY'];
    return (value == null || value.isEmpty) ? null : value;
  }
}
