import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bhoomisetu/core/localization/generated/app_localizations.dart';

void main() {
  test('supports BhoomiSetu languages used across major Indian regions', () {
    final languageCodes = AppLocalizations.supportedLocales
        .map((locale) => locale.languageCode)
        .toSet();

    expect(
      languageCodes,
      containsAll(<String>{
        'en',
        'hi',
        'as',
        'bn',
        'gu',
        'kn',
        'ml',
        'mr',
        'or',
        'pa',
        'ta',
        'te',
        'ur',
      }),
    );
    expect(languageCodes, hasLength(13));
  });

  testWidgets('Urdu uses a right-to-left reading direction', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ur'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: Text('بھومی سیتو')),
      ),
    );

    expect(
      Directionality.of(tester.element(find.text('بھومی سیتو'))),
      TextDirection.rtl,
    );
  });
}
