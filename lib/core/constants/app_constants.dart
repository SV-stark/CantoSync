class AppConstants {

  // Private constructor to prevent instantiation
  AppConstants._();
  // Player layout thresholds
  static const double wideLayoutWidthThreshold = 900;

  // Chapter matching tolerance
  static const double chapterMatchingToleranceSeconds = 0.5;

  // Seek delay after slider release
  static const Duration seekDelayAfterSlider = Duration(milliseconds: 500);

  // Book completion threshold (95% considered complete)
  static const double bookCompletionThreshold = 0.95;
}
