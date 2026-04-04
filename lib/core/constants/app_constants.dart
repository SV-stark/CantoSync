class AppConstants {
  // Hive Box Names
  static const String libraryBox = 'library';
  static const String booksBox = 'books';
  static const String settingsBox = 'settings';

  // Stats Box Names
  static const String dailyStatsBox = 'dailyStats';
  static const String authorStatsBox = 'authorStats';
  static const String bookStatsBox = 'bookStats';
  static const String speedStatsBox = 'speedStats';

  // Keyboard Shortcuts Box Name
  static const String keyboardShortcutsBox = 'keyboardShortcuts';

  // Schema version for data migrations
  static const int currentSchemaVersion = 1;
  static const String schemaVersionBox = 'schemaVersion';

  // Player layout thresholds
  static const double wideLayoutWidthThreshold = 900;

  // Chapter matching tolerance
  static const double chapterMatchingToleranceSeconds = 0.5;

  // Seek delay after slider release
  static const Duration seekDelayAfterSlider = Duration(milliseconds: 500);

  // Book completion threshold (95% considered complete)
  static const double bookCompletionThreshold = 0.95;

  // Private constructor to prevent instantiation
  AppConstants._();
}
