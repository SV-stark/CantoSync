import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:canto_sync/features/stats/data/listening_stats.dart';
import 'package:canto_sync/features/stats/data/stats_service.dart';

class FakeIsar extends Fake implements Isar {}

void main() {
  group('ListeningStatsService Calculations', () {
    late ListeningStatsService service;

    setUp(() {
      service = ListeningStatsService(FakeIsar());
    });

    test('calculateStreaksForTesting handles empty stats', () {
      final streaks = service.calculateStreaksForTesting([]);
      expect(streaks['current'], 0);
      expect(streaks['longest'], 0);
    });

    test('calculateStreaksForTesting calculates consecutive days correctly', () {
      final now = DateTime.now();
      final d1 = now.subtract(const Duration(days: 2));
      final d2 = now.subtract(const Duration(days: 1));
      final d3 = now;

      String formatDate(DateTime d) =>
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      final stats = [
        DailyListeningStats(date: formatDate(d1), totalSecondsListened: 120),
        DailyListeningStats(date: formatDate(d2), totalSecondsListened: 300),
        DailyListeningStats(date: formatDate(d3), totalSecondsListened: 500),
      ];

      final streaks = service.calculateStreaksForTesting(stats);
      expect(streaks['current'], 3);
      expect(streaks['longest'], 3);
    });

    test('calculateWeeklyActivityForTesting aggregates seconds by day of week', () {
      final stats = [
        DailyListeningStats(date: '2026-08-17', totalSecondsListened: 3600), // Mon
        DailyListeningStats(date: '2026-08-18', totalSecondsListened: 1800), // Tue
        DailyListeningStats(date: '2026-08-19', totalSecondsListened: 1200), // Wed
      ];

      final activity = service.calculateWeeklyActivityForTesting(stats);
      expect(activity['Mon'], 3600);
      expect(activity['Tue'], 1800);
      expect(activity['Wed'], 1200);
      expect(activity['Thu'], 0);
      expect(activity['Fri'], 0);
      expect(activity['Sat'], 0);
      expect(activity['Sun'], 0);
    });
  });
}
