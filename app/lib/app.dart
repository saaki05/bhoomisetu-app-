import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'core/constants/app_constants.dart';
import 'core/localization/generated/app_localizations.dart';
import 'core/providers/locale_controller.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class BhoomiSetuApp extends ConsumerWidget {
  const BhoomiSetuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeControllerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child ?? const SizedBox.shrink(),
        breakpoints: const [
          Breakpoint(start: 0, end: 479, name: MOBILE),
          Breakpoint(start: 480, end: 1199, name: TABLET),
          Breakpoint(start: 1200, end: double.infinity, name: DESKTOP),
        ],
      ),
    );
  }
}
