import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/app_bootstrap.dart';
import 'core/storage/preferences_service.dart';

Future<void> main() async {
  final bootstrap = await AppBootstrap.run();

  runApp(
    ProviderScope(
      overrides: [
        preferencesServiceProvider.overrideWithValue(PreferencesService(bootstrap.sharedPreferences)),
      ],
      child: const BhoomiSetuApp(),
    ),
  );
}
