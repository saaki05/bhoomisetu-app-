import 'package:flutter/material.dart';

import '../localization/generated/app_localizations.dart';

/// Shorthand accessors for the values pulled from [BuildContext] most often
/// across screens — cuts `Theme.of(context).colorScheme` repetition.
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  AppLocalizations get l10n => AppLocalizations.of(this);
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  bool get isMobile => screenSize.width < 480;
  bool get isTablet => screenSize.width >= 480 && screenSize.width < 1200;
  bool get isDesktop => screenSize.width >= 1200;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: isError ? colors.error : null,
      ));
  }

  void hapticSelect() => Feedback.forTap(this);
}
