import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';

/// Everything that must finish before `runApp` — environment variables,
/// Hive box registration, and warming the SharedPreferences instance so it
/// can be injected synchronously via provider override instead of every
/// screen awaiting it individually.
class AppBootstrap {
  const AppBootstrap._({required this.sharedPreferences});

  static const Map<String, String> _compiledConfiguration = {
    'API_BASE_URL': String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://bhoomisetu-backend-5lrq.onrender.com/api/v1',
    ),
    'SOCKET_URL': String.fromEnvironment(
      'SOCKET_URL',
      defaultValue: 'https://bhoomisetu-backend-5lrq.onrender.com',
    ),
    'SUPABASE_URL': String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://cuwfxljwskbmqjuflykw.supabase.co',
    ),
    'SUPABASE_ANON_KEY': String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'sb_publishable_LKZJrApRaBzVUQW0B9PUWg_1T9RTl4X',
    ),
    'GOOGLE_MAPS_API_KEY': String.fromEnvironment('GOOGLE_MAPS_API_KEY'),
    'GOOGLE_SIGN_IN_WEB_CLIENT_ID': String.fromEnvironment(
      'GOOGLE_SIGN_IN_WEB_CLIENT_ID',
    ),
    'GOOGLE_AUTH_ENABLED': String.fromEnvironment(
      'GOOGLE_AUTH_ENABLED',
      defaultValue: 'false',
    ),
    'PHONE_AUTH_ENABLED': String.fromEnvironment(
      'PHONE_AUTH_ENABLED',
      defaultValue: 'false',
    ),
    'WEATHER_API_KEY': String.fromEnvironment('WEATHER_API_KEY'),
    'APP_ENV': String.fromEnvironment('APP_ENV', defaultValue: 'production'),
  };

  final SharedPreferences sharedPreferences;

  static Future<AppBootstrap> run() async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      await dotenv.load(
        fileName: 'config/app.env',
        mergeWith: _compiledConfiguration,
      );
    } catch (error, stackTrace) {
      debugPrint('Runtime configuration could not be loaded: $error');
      debugPrintStack(stackTrace: stackTrace);
      dotenv.testLoad(mergeWith: _compiledConfiguration);
    }

    await Hive.initFlutter();
    SharedPreferences.setPrefix('bhoomisetu.preferences.');
    final startupResults = await Future.wait<dynamic>([
      Hive.openBox<String>(StorageKeys.cacheBox),
      Hive.openBox<String>(StorageKeys.draftsBox),
      SharedPreferences.getInstance(),
    ]);
    final sharedPreferences = startupResults[2] as SharedPreferences;

    return AppBootstrap._(sharedPreferences: sharedPreferences);
  }
}
