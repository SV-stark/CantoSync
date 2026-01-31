import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:canto_sync/core/constants/app_constants.dart';
import 'package:canto_sync/features/library/data/book.dart';
import 'package:canto_sync/features/stats/data/listening_stats.dart';

final listeningStatsServiceProvider = Provider<ListeningStatsService>((ref) {
  try {
    final dailyBox = Hive.box<DailyListeningStats>(AppConstants.dailyStatsBox);
    final authorBox = Hive.box<AuthorStats>(AppConstants.authorStatsBox);
    final bookBox = Hive.box<BookCompletionStats>(AppConstants.bookStatsBox);
    final speedBox = Hive.box<ListeningSpeedPreference>(AppConstants.speedStatsBox);
    return ListeningStatsService(dailyBox, authorBox, bookBox, speedBox);
  } catch (e) {
    debugPrint('Error accessing stats boxes: $e');
    rethrow;
  }
});

final listeningStatsProvider = StreamProvider<ListeningStatsSummary>((ref) {
  final service = ref.watch(listeningStatsServiceProvider);
  return service.watchStats();
});

class ListeningStatsSummary {
  final double totalHoursListened;
  final int totalBooksCompleted;
  final int totalBooksStarted;
  final int currentStreak;
  final int longestStreak;
  final List<DailyListeningStats> last30Days;
  final List<AuthorStats> topAuthors;
  final double averageListeningSpeed;
  final int totalListeningSessions;
  final Map<String, int> weeklyActivity;

  ListeningStatsSummary({
    required this.totalHoursListened,
    required this.totalBooksCompleted,
    required this.totalBooksStarted,
    required this.currentStreak,
    required this.longestStreak,
    required this.last30Days,
    required this.topAuthors,
    required this.averageListeningSpeed,
    required this.totalListeningSessions,
    required this.weeklyActivity,
  });
}

class ListeningStatsService {
  final Box<DailyListeningStats> _dailyBox;
  final Box<AuthorStats> _authorBox;
  final Box<BookCompletionStats> _bookBox;
  final Box<ListeningSpeedPreference> _speedBox;

  ListeningStatsService(
    this._dailyBox,
    this._authorBox,
    this._bookBox,
    this._speedBox,
  );

  Stream<ListeningStatsSummary> watchStats() {
    return Stream.periodic(const Duration(seconds: 5)).asyncMap((_) => _calculateStats());
  }

  Future<ListeningStatsSummary> _calculateStats() async {
    final dailyStats = _dailyBox.values.toList();
    final authorStats = _authorBox.values.toList();
    final bookStats = _bookBox.values.toList();
    final speedPref = _speedBox.get('preference') ?? ListeningSpeedPreference();

    // Calculate totals
    double totalHours = 0;
    int totalSessions = 0;
    for (final day in dailyStats) {
      totalHours += day.totalHours;
      totalSessions += day.listeningSessions;
    }

    final completedBooks = bookStats.where((b) => b.isCompleted).length;
    final startedBooks = bookStats.length;

    // Calculate streaks
    final streaks = _calculateStreaks(dailyStats);

    // Get last 30 days
    final last30Days = _getLast30Days(dailyStats);

    // Get top authors by hours
    final sortedAuthors = authorStats.toList()
      ..sort((a, b) => b.totalHours.compareTo(a.totalHours));
    final topAuthors = sortedAuthors.take(5).toList();

    // Weekly activity
    final weeklyActivity = _calculateWeeklyActivity(dailyStats);

    return ListeningStatsSummary(
      totalHoursListened: totalHours,
      totalBooksCompleted: completedBooks,
      totalBooksStarted: startedBooks,
      currentStreak: streaks['current'] ?? 0,
      longestStreak: streaks['longest'] ?? 0,
      last30Days: last30Days,
      topAuthors: topAuthors,
      averageListeningSpeed: speedPref.averageSpeed,
      totalListeningSessions: totalSessions,
      weeklyActivity: weeklyActivity,
    );
  }

  Map<String, int> _calculateStreaks(List<DailyListeningStats> stats) {
    if (stats.isEmpty) return {'current': 0, 'longest': 0};

    final sortedDates = stats.map((s) => s.date).toList()..sort();
    final datesWithActivity = sortedDates.toSet();

    int currentStreak = 0;
    int longestStreak = 0;
    int currentCount = 0;

    final today = _formatDate(DateTime.now());
    final yesterday = _formatDate(DateTime.now().subtract(const Duration(days: 1)));

    // Check if listening happened today or yesterday for current streak
    if (datesWithActivity.contains(today) || datesWithActivity.contains(yesterday)) {
      // Calculate current streak
      DateTime checkDate = datesWithActivity.contains(today)
          ? DateTime.now()
          : DateTime.now().subtract(const Duration(days: 1));

      while (datesWithActivity.contains(_formatDate(checkDate))) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    }

    // Calculate longest streak
    DateTime? streakStart;
    for (int i = 0; i < sortedDates.length; i++) {
      final currentDate = DateTime.parse(sortedDates[i]);

      if (streakStart == null) {
        streakStart = currentDate;
        currentCount = 1;
      } else {
        final expectedDate = streakStart.add(Duration(days: currentCount));
        if (_formatDate(expectedDate) == sortedDates[i]) {
          currentCount++;
        } else {
          longestStreak = currentCount > longestStreak ? currentCount : longestStreak;
          streakStart = currentDate;
          currentCount = 1;
        }
      }
    }
    longestStreak = currentCount > longestStreak ? currentCount : longestStreak;

    return {'current': currentStreak, 'longest': longestStreak};
  }

  List<DailyListeningStats> _getLast30Days(List<DailyListeningStats> allStats) {
    final today = DateTime.now();
    final last30 = <DailyListeningStats>[];

    for (int i = 29; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateStr = _formatDate(date);

      final existing = allStats.firstWhere(
        (s) => s.date == dateStr,
        orElse: () => DailyListeningStats(date: dateStr),
      );

      last30.add(existing);
    }

    return last30;
  }

  Map<String, int> _calculateWeeklyActivity(List<DailyListeningStats> stats) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final activity = <String, int>{};

    for (final day in days) {
      activity[day] = 0;
    }

    for (final stat in stats) {
      final date = DateTime.parse(stat.date);
      final dayName = days[date.weekday - 1];
      activity[dayName] = (activity[dayName] ?? 0) + stat.totalSecondsListened;
    }

    return activity;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> recordListeningTime(
    Book book,
    int secondsListened, {
    double? playbackSpeed,
  }) async {
    if (secondsListened <= 0) return;

    final today = _formatDate(DateTime.now());
    final bookPath = book.path;
    final author = book.author ?? 'Unknown Author';

    // Update daily stats
    var dailyStats = _dailyBox.get(today);
    if (dailyStats == null) {
      dailyStats = DailyListeningStats(date: today);
      await _dailyBox.put(today, dailyStats);
    }
    dailyStats.totalSecondsListened += secondsListened;
    if (!dailyStats.booksListened.contains(bookPath)) {
      dailyStats.booksListened.add(bookPath);
    }
    dailyStats.listeningSessions++;
    await dailyStats.save();

    // Update author stats
    var authorStats = _authorBox.get(author);
    if (authorStats == null) {
      authorStats = AuthorStats(authorName: author);
      await _authorBox.put(author, authorStats);
    }
    authorStats.totalSecondsListened += secondsListened;
    if (!authorStats.bookTitles.contains(book.title)) {
      authorStats.bookTitles.add(book.title);
      authorStats.booksStarted++;
    }
    await authorStats.save();

    // Update book stats
    var bookStats = _bookBox.get(bookPath);
    if (bookStats == null) {
      bookStats = BookCompletionStats(
        bookPath: bookPath,
        bookTitle: book.title,
        author: author,
        startedDate: DateTime.now(),
      );
      await _bookBox.put(bookPath, bookStats);
    }
    bookStats.totalSecondsListened += secondsListened;
    await bookStats.save();

    // Update speed preference if provided
    if (playbackSpeed != null) {
      var speedPref = _speedBox.get('preference') ?? ListeningSpeedPreference();
      speedPref.speedUsageCount[playbackSpeed] =
          (speedPref.speedUsageCount[playbackSpeed] ?? 0) + 1;
      speedPref.totalSessionsAtSpeed++;

      // Recalculate weighted average
      double totalWeight = 0;
      double weightedSum = 0;
      speedPref.speedUsageCount.forEach((speed, count) {
        weightedSum += speed * count;
        totalWeight += count;
      });

      if (totalWeight > 0) {
        speedPref.averageSpeed = weightedSum / totalWeight;
      }

      await _speedBox.put('preference', speedPref);
    }
  }

  Future<void> markBookAsCompleted(Book book) async {
    final bookPath = book.path;
    var bookStats = _bookBox.get(bookPath) ?? BookCompletionStats(
      bookPath: bookPath,
      bookTitle: book.title,
      author: book.author ?? 'Unknown Author',
      startedDate: DateTime.now(),
    );

    bookStats.isCompleted = true;
    bookStats.completedDate = DateTime.now();
    await _bookBox.put(bookPath, bookStats);

    // Update author completed count
    final author = book.author ?? 'Unknown Author';
    var authorStats = _authorBox.get(author);
    if (authorStats != null) {
      authorStats.booksCompleted++;
      await authorStats.save();
    }
  }

  Future<void> resetAllStats() async {
    await _dailyBox.clear();
    await _authorBox.clear();
    await _bookBox.clear();
    await _speedBox.clear();
  }
}
