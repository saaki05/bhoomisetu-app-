import 'package:flutter/material.dart';

/// Brand and semantic colors for BhoomiSetu. [ColorScheme]s derived from
/// [seed] via Material 3's dynamic color algorithm live in [AppTheme];
/// this file only holds colors that fall outside that scheme (status
/// badges, organic tags, chart series) plus the seed itself.
abstract final class AppColors {
  /// Deep leaf green — reflects growth, agriculture, and trust.
  static const Color seed = Color(0xFF2E7D4F);

  static const Color organic = Color(0xFF4CAF50);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color danger = Color(0xFFD32F2F);
  static const Color info = Color(0xFF0288D1);

  static const Color harvestGold = Color(0xFFE8A33D);
  static const Color soilBrown = Color(0xFF6D4C33);
  static const Color skyBlue = Color(0xFF64B5F6);

  static const List<Color> chartSeries = [
    Color(0xFF2E7D4F),
    Color(0xFFE8A33D),
    Color(0xFF0288D1),
    Color(0xFF8E24AA),
    Color(0xFFD32F2F),
    Color(0xFF00897B),
  ];
}
