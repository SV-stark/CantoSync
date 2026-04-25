import 'package:isar/isar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:canto_sync/features/library/data/library_service.dart';
import 'package:canto_sync/features/library/data/book.dart';
import 'package:canto_sync/features/stats/data/listening_stats.dart';
import 'dart:convert';

final listeningStatsServiceProvider = Provider<ListeningStatsService>((ref) {
  final isar = ref.watch(isarProvider);
  return ListeningStatsService(isar);
});

final listeningStatsProvider = StreamProvider<ListeningStatsSummary>((ref) {
  final service = ref.watch(listeningStatsServiceProvider);
  return service.watchStats();
});

class ListeningStatsSummary {

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
}

class ListeningStatsService {

  ListeningStatsService(this._isar);
  final Isar _isar;

  Stream<ListeningStatsSummary> watchStats() {
    final dailyStream = _isar.dailyListeningStats.where().watch(fireImmediately: true);
    final authorStream = _isar.authorStats.where().watch(fireImmediately: true);
    final bookStream = _isar.bookCompletionStats.where().watch(fireImmediately: true);
    final speedStream = _isar.listeningSpeedPreferences.where().watch(fireImmediately: true);

    return Rx.combineLatest4(
      dailyStream,
      authorStream,
      bookStream,
      speedStream,
      (_, __, ___, ____) => _calculateStatsSync(),
    );
  }

  ListeningStatsSummary _calculateStatsSync() {
    final dailyStats = _isar.dailyListeningStats.where().findAllSync();
    final authorStats = _isar.authorStats.where().findAllSync();
    final bookStats = _isar.bookCompletionStats.where().findAllSync();
    final speedPref = _isar.listeningSpeedPreferences.getSync(0) ?? ListeningSpeedPreference();

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
    final yesterday = _formatDate(
      DateTime.now().subtract(const Duration(days: 1)),
    );

    // Check if listening happened today or yesterday for current streak
    if (datesWithActivity.contains(today) ||
        datesWithActivity.contains(yesterday)) {
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
          longestStreak = currentCount > longestStreak
              ? currentCount
              : longestStreak;
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
    final bookPath = book.path ?? '';
    final authorName = book.author ?? 'Unknown Author';

    await _isar.writeTxn(() async {
      // Update daily stats
      var dailyStats = await _isar.dailyListeningStats.filter().dateEqualTo(today).findFirst();
      dailyStats ??= DailyListeningStats(date: today);
      dailyStats.totalSecondsListened += secondsListened;
      if (!dailyStats.booksListened.contains(bookPath)) {
        dailyStats.booksListened.add(bookPath);
      }
      dailyStats.listeningSessions++;
      await _isar.dailyListeningStats.put(dailyStats);

      // Update author stats
      var authorStats = await _isar.authorStats.filter().authorNameEqualTo(authorName).findFirst();
      authorStats ??= AuthorStats(authorName: authorName);
      authorStats.totalSecondsListened += secondsListened;
      if (!authorStats.bookTitles.contains(book.title ?? 'Unknown')) {
        authorStats.bookTitles.add(book.title ?? 'Unknown');
        authorStats.booksStarted++;
      }
      await _isar.authorStats.put(authorStats);

      // Update book stats
      var bookStats = await _isar.bookCompletionStats.filter().bookPathEqualTo(bookPath).findFirst();
      bookStats ??= BookCompletionStats(
          bookPath: bookPath,
          bookTitle: book.title ?? 'Unknown',
          author: authorName,
          startedDate: DateTime.now(),
        );
      bookStats.totalSecondsListened += secondsListened;
      await _isar.bookCompletionStats.put(bookStats);

      // Update speed preference if provided
      if (playbackSpeed != null) {
        var speedPref = await _isar.listeningSpeedPreferences.get(0) ?? ListeningSpeedPreference();
        Map<double, int> speedUsage = {};
        if (speedPref.speedUsageCountJson != null) {
          try {
            final Map<String, dynamic> decoded = json.decode(speedPref.speedUsageCountJson!);
            speedUsage = decoded.map((key, value) => MapEntry(double.parse(key), value as int));
          } catch (_) {}
        }
        
        speedUsage[playbackSpeed] = (speedUsage[playbackSpeed] ?? 0) + 1;
        speedPref.totalSessionsAtSpeed++;

        // Recalculate weighted average
        double totalWeight = 0;
        double weightedSum = 0;
        speedUsage.forEach((speed, count) {
          weightedSum += speed * count;
          totalWeight += count;
        });

        if (totalWeight > 0) {
          speedPref.averageSpeed = weightedSum / totalWeight;
        }
        
        speedPref.speedUsageCountJson = json.encode(speedUsage.map((k, v) => MapEntry(k.toString(), v)));
        speedPref.id = 0;
        await _isar.listeningSpeedPreferences.put(speedPref);
      }
    });
  }

  Future<void> markBookAsCompleted(Book book) async {
    final bookPath = book.path ?? '';
    final authorName = book.author ?? 'Unknown Author';

    await _isar.writeTxn(() async {
      var bookStats = await _isar.bookCompletionStats.filter().bookPathEqualTo(bookPath).findFirst();
      bookStats ??= BookCompletionStats(
          bookPath: bookPath,
          bookTitle: book.title ?? 'Unknown',
          author: authorName,
          startedDate: DateTime.now(),
        );

      bookStats.isCompleted = true;
      bookStats.completedDate = DateTime.now();
      await _isar.bookCompletionStats.put(bookStats);

      // Update author completed count
      var authorStats = await _isar.authorStats.filter().authorNameEqualTo(authorName).findFirst();
      if (authorStats != null) {
        authorStats.booksCompleted++;
        await _isar.authorStats.put(authorStats);
      }
    });
  }

  Future<void> resetAllStats() async {
    await _isar.writeTxn(() async {
      await _isar.dailyListeningStats.clear();
      await _isar.authorStats.clear();
      await _isar.bookCompletionStats.clear();
      await _isar.listeningSpeedPreferences.clear();
    });
  }
}
