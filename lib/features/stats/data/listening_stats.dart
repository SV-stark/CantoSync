import 'package:isar_community/isar.dart';

part 'listening_stats.g.dart';

@collection
class DailyListeningStats {

  DailyListeningStats({
    required this.date,
    this.totalSecondsListened = 0,
    this.booksListened = const [],
    this.listeningSessions = 0,
  });
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  final String date; // YYYY-MM-DD format

  int totalSecondsListened;

  List<String> booksListened;

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
    this.bookTitles = const [],
  });
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  final String authorName;

  int totalSecondsListened;

  int booksCompleted;

  int booksStarted;

  List<String> bookTitles;

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
    this.averageSpeed = 1.0,
    this.totalSessionsAtSpeed = 0,
    this.speedUsageCountJson,
  });
  Id id = Isar.autoIncrement;

  double averageSpeed;

  int totalSessionsAtSpeed;

  // Isar doesn't support Map directly, so we store it as a JSON string or two lists
  // For simplicity here, let's use two lists or just skip the map if not critical,
  // or use a helper class. Let's use a JSON string for the map.
  String? speedUsageCountJson;
}
