import 'package:hive/hive.dart';

part 'listening_stats.g.dart';

@HiveType(typeId: 3)
class DailyListeningStats extends HiveObject {
  @HiveField(0)
  final String date; // YYYY-MM-DD format

  @HiveField(1)
  int totalSecondsListened;

  @HiveField(2)
  List<String> booksListened;

  @HiveField(3)
  int listeningSessions;

  DailyListeningStats({
    required this.date,
    this.totalSecondsListened = 0,
    List<String>? booksListened,
    this.listeningSessions = 0,
  }) : booksListened = booksListened ?? [];

  double get totalHours => totalSecondsListened / 3600;
}

@HiveType(typeId: 4)
class AuthorStats extends HiveObject {
  @HiveField(0)
  final String authorName;

  @HiveField(1)
  int totalSecondsListened;

  @HiveField(2)
  int booksCompleted;

  @HiveField(3)
  int booksStarted;

  @HiveField(4)
  List<String> bookTitles;

  AuthorStats({
    required this.authorName,
    this.totalSecondsListened = 0,
    this.booksCompleted = 0,
    this.booksStarted = 0,
    List<String>? bookTitles,
  }) : bookTitles = bookTitles ?? [];

  double get totalHours => totalSecondsListened / 3600;
}

@HiveType(typeId: 5)
class BookCompletionStats extends HiveObject {
  @HiveField(0)
  final String bookPath;

  @HiveField(1)
  final String bookTitle;

  @HiveField(2)
  String? author;

  @HiveField(3)
  DateTime? completedDate;

  @HiveField(4)
  int totalSecondsListened;

  @HiveField(5)
  DateTime? startedDate;

  @HiveField(6)
  bool isCompleted;

  BookCompletionStats({
    required this.bookPath,
    required this.bookTitle,
    this.author,
    this.completedDate,
    this.totalSecondsListened = 0,
    this.startedDate,
    this.isCompleted = false,
  });

  double get totalHours => totalSecondsListened / 3600;
}

@HiveType(typeId: 6)
class ListeningSpeedPreference extends HiveObject {
  @HiveField(0)
  double averageSpeed;

  @HiveField(1)
  int totalSessionsAtSpeed;

  @HiveField(2)
  Map<double, int> speedUsageCount;

  ListeningSpeedPreference({
    this.averageSpeed = 1.0,
    this.totalSessionsAtSpeed = 0,
    Map<double, int>? speedUsageCount,
  }) : speedUsageCount = speedUsageCount ?? {};
}
