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

  final SharedPreferences sharedPreferences;

  static Future<AppBootstrap> run() async {
    WidgetsFlutterBinding.ensureInitialized();

    await dotenv.load(fileName: 'config/app.env');

    await Hive.initFlutter();
    final startupResults = await Future.wait<dynamic>([
      Hive.openBox<String>(StorageKeys.cacheBox),
      Hive.openBox<String>(StorageKeys.draftsBox),
      SharedPreferences.getInstance(),
    ]);
    final sharedPreferences = startupResults[2] as SharedPreferences;

    return AppBootstrap._(sharedPreferences: sharedPreferences);
  }
}
