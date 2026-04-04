import 'package:flutter_test/flutter_test.dart';
import 'package:canto_sync/core/utils/format_duration.dart';

void main() {
  group('formatDuration', () {
    test('formats minutes and seconds correctly', () {
      expect(formatDuration(const Duration(minutes: 5, seconds: 30)), '5:30');
    });

    test('formats hours, minutes, and seconds correctly', () {
      expect(
        formatDuration(const Duration(hours: 1, minutes: 23, seconds: 45)),
        '1:23:45',
      );
    });

    test('pads single-digit minutes and seconds', () {
      expect(formatDuration(const Duration(minutes: 3, seconds: 7)), '3:07');
    });

    test('handles zero duration', () {
      expect(formatDuration(Duration.zero), '0:00');
    });

    test('handles large hour values', () {
      expect(
        formatDuration(const Duration(hours: 12, minutes: 0, seconds: 0)),
        '12:00:00',
      );
    });
  });

  group('formatDurationSeconds', () {
    test('formats seconds to time string', () {
      expect(formatDurationSeconds(330.0), '5:30');
    });

    test('handles hour boundary', () {
      expect(formatDurationSeconds(3661.0), '1:01:01');
    });

    test('handles zero', () {
      expect(formatDurationSeconds(0.0), '0:00');
    });
  });

  group('formatDurationVerbose', () {
    test('returns Unknown for null', () {
      expect(formatDurationVerbose(null), 'Unknown');
    });

    test('formats with hours', () {
      expect(formatDurationVerbose(7265.0), '2h 1m 5s');
    });

    test('formats without hours', () {
      expect(formatDurationVerbose(125.0), '2m 5s');
    });

    test('handles zero', () {
      expect(formatDurationVerbose(0.0), '0m 0s');
    });
  });
}
