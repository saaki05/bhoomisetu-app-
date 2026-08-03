import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/preferences_service.dart';

part 'locale_controller.g.dart';

/// The user's chosen app language, persisted across launches. `null` means
/// "follow the system locale" — [BhoomiSetuApp] passes this straight to
/// [MaterialApp.locale], where `null` already means exactly that.
@riverpod
class LocaleController extends _$LocaleController {
  @override
  Locale? build() {
    final code = ref.watch(preferencesServiceProvider).localeCode;
    return code == null || code.isEmpty ? null : Locale(code);
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    if (locale == null) {
      await ref.read(preferencesServiceProvider).setLocaleCode('');
    } else {
      await ref.read(preferencesServiceProvider).setLocaleCode(locale.languageCode);
    }
  }
}
