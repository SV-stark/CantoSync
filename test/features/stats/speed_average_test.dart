import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:canto_sync/features/stats/data/stats_service.dart';

void main() {
  group('calculateWeightedAverageSpeed and parseSpeedUsageJson', () {
    test('single speed calculation returns that exact speed', () {
      final usage = {1.25: 5};
      final avg = calculateWeightedAverageSpeed(usage);
      expect(avg, closeTo(1.25, 0.0001));
    });

    test('mixed speeds weighting calculates correct weighted average', () {
      // 1.0x with 1 session, 2.0x with 3 sessions -> (1.0*1 + 2.0*3) / 4 = 7.0 / 4 = 1.75
      final usage = {
        1.0: 1,
        2.0: 3,
      };
      final avg = calculateWeightedAverageSpeed(usage);
      expect(avg, closeTo(1.75, 0.0001));
    });

    test('multiple mixed speeds weighting', () {
      // 1.0x (2 sessions) = 2.0
      // 1.5x (4 sessions) = 6.0
      // 2.0x (4 sessions) = 8.0
      // total sessions = 10, total weighted = 16.0 -> avg = 1.6
      final usage = {
        1.0: 2,
        1.5: 4,
        2.0: 4,
      };
      final avg = calculateWeightedAverageSpeed(usage);
      expect(avg, closeTo(1.6, 0.0001));
    });

    test('totalWeight == 0 returns current/default average', () {
      final emptyUsage = <double, int>{};
      expect(calculateWeightedAverageSpeed(emptyUsage, currentAverage: 1.0), 1.0);
      expect(calculateWeightedAverageSpeed(emptyUsage, currentAverage: 1.5), 1.5);
    });

    test('JSON round-trip parsing parses keys as double and values as int', () {
      final speedUsageMap = {
        1.25: 3,
        1.5: 7,
        2.0: 1,
      };

      // Encode map where keys are stringified doubles
      final encoded = json.encode(
        speedUsageMap.map((k, v) => MapEntry(k.toString(), v)),
      );

      final parsed = parseSpeedUsageJson(encoded);

      expect(parsed.length, 3);
      expect(parsed[1.25], 3);
      expect(parsed[1.5], 7);
      expect(parsed[2.0], 1);

      final avg = calculateWeightedAverageSpeed(parsed);
      // (1.25*3 + 1.5*7 + 2.0*1) / 11 = (3.75 + 10.5 + 2.0) / 11 = 16.25 / 11 ~= 1.47727
      expect(avg, closeTo(16.25 / 11, 0.0001));
    });

    test('parseSpeedUsageJson handles null, empty, and invalid json gracefully', () {
      expect(parseSpeedUsageJson(null), isEmpty);
      expect(parseSpeedUsageJson(''), isEmpty);
      expect(parseSpeedUsageJson('not json'), isEmpty);
      expect(parseSpeedUsageJson('{"invalid": "value"}'), isEmpty);
    });
  });
}
