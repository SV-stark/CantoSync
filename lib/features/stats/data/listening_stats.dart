import 'package:isar_community/isar.dart';

part 'listening_stats.g.dart';

@collection
class DailyListeningStats {
  DailyListeningStats({
    required this.date,
    this.totalSecondsListened = 0,
    this.listeningSessions = 0,
  });
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  final String date; // YYYY-MM-DD format

  int totalSecondsListened;

  /// Grown in place by recordListeningTime. Initialised to a growable list per
  /// instance -- a `const []` default is a single shared immutable instance and
  /// threw on the first `.add()`.
  List<String> booksListened = <String>[];

  int listeningSessions;

  double get totalHours => totalSecondsListened / 3600;
}

@collection
class AuthorStats {
  AuthorStats({
    required this.authorName,
    this.totalSecondsListened = 0,
    this.booksCompleted = 0,
    this.booksStarted = 0,
  });
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  final String authorName;

  int totalSecondsListened;

  int booksCompleted;

  int booksStarted;

  /// Book *paths*, not titles, so two same-titled books stay distinct and a
  /// rename does not register as a new book. See stats_service.
  List<String> bookTitles = <String>[];

  double get totalHours => totalSecondsListened / 3600;
}

@collection
class BookCompletionStats {
  BookCompletionStats({
    required this.bookPath,
    required this.bookTitle,
    this.author,
    this.completedDate,
    this.totalSecondsListened = 0,
    this.startedDate,
    this.isCompleted = false,
  });
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  final String bookPath;

  final String bookTitle;

  String? author;

  DateTime? completedDate;

  int totalSecondsListened;

  DateTime? startedDate;

  bool isCompleted;

  double get totalHours => totalSecondsListened / 3600;
}

@collection
class ListeningSpeedPreference {
  ListeningSpeedPreference({
    this.id = kSpeedPreferenceId,
    this.averageSpeed = 1.0,
    this.totalSessionsAtSpeed = 0,
    this.speedUsageCountJson,
  });

  /// Fixed id so the single-row preferences document is always addressable.
  /// `Isar.autoIncrement` is a sentinel (i64 min), not a valid lookup key.
  static const Id kSpeedPreferenceId = 0;

  Id id;

  double averageSpeed;

  int totalSessionsAtSpeed;

  // Isar doesn't support Map directly, so we store it as a JSON string or two lists
  // For simplicity here, let's use two lists or just skip the map if not critical,
  // or use a helper class. Let's use a JSON string for the map.
  String? speedUsageCountJson;
}
