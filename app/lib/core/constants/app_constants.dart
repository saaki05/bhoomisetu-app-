/// Design and behavior constants shared across features. Screen-specific
/// magic numbers still belong in that screen; this file is only for values
/// reused in three or more places.
abstract final class AppConstants {
  static const String appName = 'BhoomiSetu';

  // Spacing scale (Material 3 4dp grid)
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double spaceXxl = 48;

  // Corner radius scale
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;

  // Pagination
  static const int defaultPageSize = 20;

  // Debounce
  static const Duration searchDebounce = Duration(milliseconds: 400);

  // Animation
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Image upload
  static const int maxImagesPerListing = 6;
  static const int imageMaxDimension = 1600;
  static const int imageQuality = 82;

  // Responsive breakpoints
  static const double breakpointMobile = 480;
  static const double breakpointTablet = 800;
  static const double breakpointDesktop = 1200;
}
