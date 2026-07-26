import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Builds the Material 3 [TextTheme] on top of Google Fonts. Poppins for
/// display/headline/title (a friendlier, rounder voice for a farmer-facing
/// app) and Inter for body/label copy (optimized for small-size legibility,
/// including Devanagari via Noto fallback when the active locale is Hindi).
abstract final class AppTypography {
  static TextTheme textTheme(Brightness brightness) {
    final base = brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light();
    final headingFont = GoogleFonts.poppinsTextTheme(base.textTheme);
    final bodyFont = GoogleFonts.interTextTheme(base.textTheme);

    return bodyFont.copyWith(
      displayLarge: headingFont.displayLarge,
      displayMedium: headingFont.displayMedium,
      displaySmall: headingFont.displaySmall,
      headlineLarge: headingFont.headlineLarge,
      headlineMedium: headingFont.headlineMedium,
      headlineSmall: headingFont.headlineSmall,
      titleLarge: headingFont.titleLarge,
      titleMedium: headingFont.titleMedium,
      titleSmall: headingFont.titleSmall,
    );
  }
}
