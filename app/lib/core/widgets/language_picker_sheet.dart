import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../extensions/context_extensions.dart';
import '../providers/locale_controller.dart';

const _languages = [
  (code: null, label: 'System default'),
  (code: 'en', label: 'English'),
  (code: 'hi', label: 'हिंदी (Hindi)'),
];

Future<void> showLanguagePickerSheet(BuildContext context, WidgetRef ref) {
  final current = ref.read(localeControllerProvider)?.languageCode;

  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text('Choose language', style: sheetContext.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ),
          RadioGroup<String?>(
            groupValue: current,
            onChanged: (value) {
              ref.read(localeControllerProvider.notifier).setLocale(value == null ? null : Locale(value));
              Navigator.of(sheetContext).pop();
            },
            child: Column(
              children: [
                for (final language in _languages)
                  RadioListTile<String?>(value: language.code, title: Text(language.label)),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
