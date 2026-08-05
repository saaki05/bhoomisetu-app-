import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../extensions/context_extensions.dart';
import '../providers/locale_controller.dart';

const _languages = [
  (code: 'en', label: 'English'),
  (code: 'hi', label: 'हिंदी (Hindi)'),
  (code: 'as', label: 'অসমীয়া (Assamese)'),
  (code: 'bn', label: 'বাংলা (Bengali)'),
  (code: 'gu', label: 'ગુજરાતી (Gujarati)'),
  (code: 'kn', label: 'ಕನ್ನಡ (Kannada)'),
  (code: 'ml', label: 'മലയാളം (Malayalam)'),
  (code: 'mr', label: 'मराठी (Marathi)'),
  (code: 'or', label: 'ଓଡ଼ିଆ (Odia)'),
  (code: 'pa', label: 'ਪੰਜਾਬੀ (Punjabi)'),
  (code: 'ta', label: 'தமிழ் (Tamil)'),
  (code: 'te', label: 'తెలుగు (Telugu)'),
  (code: 'ur', label: 'اردو (Urdu)'),
];

Future<void> showLanguagePickerSheet(BuildContext context, WidgetRef ref) {
  final current = ref.read(localeControllerProvider)?.languageCode;

  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.82,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text(
                sheetContext.l10n.languageChoose,
                style: sheetContext.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _LanguageTile(
                    label: sheetContext.l10n.languageSystemDefault,
                    selected: current == null,
                    onTap: () => _selectLanguage(sheetContext, ref, null),
                  ),
                  const Divider(height: 1),
                  for (final language in _languages)
                    _LanguageTile(
                      label: language.label,
                      selected: current == language.code,
                      onTap: () =>
                          _selectLanguage(sheetContext, ref, language.code),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _selectLanguage(
  BuildContext context,
  WidgetRef ref,
  String? languageCode,
) {
  ref
      .read(localeControllerProvider.notifier)
      .setLocale(languageCode == null ? null : Locale(languageCode));
  Navigator.of(context).pop();
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: 56,
      leading: Icon(
        Icons.translate_rounded,
        color: selected ? context.colors.primary : context.colors.outline,
      ),
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: context.colors.primary)
          : null,
      onTap: onTap,
    );
  }
}
