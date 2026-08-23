import 'package:flutter_test/flutter_test.dart';
import 'package:canto_sync/core/services/media_service.dart';
import 'package:canto_sync/core/services/sleep_timer_service.dart';

void main() {
  group('stepSleepTimer per-tick reducer', () {
    test('countdown decrements by 1 second on positive remaining time', () {
      final step = stepSleepTimer(const Duration(seconds: 30));
      expect(step.remainingTime, const Duration(seconds: 29));
      expect(step.shouldExpire, isFalse);
      expect(step.shouldCancel, isFalse);
    });

    test('reaches Duration.zero from 1 second remaining', () {
      final step = stepSleepTimer(const Duration(seconds: 1));
      expect(step.remainingTime, Duration.zero);
      expect(step.shouldExpire, isFalse);
      expect(step.shouldCancel, isFalse);
    });

    test('expiry triggers when remaining time is <= Duration.zero', () {
      final stepZero = stepSleepTimer(Duration.zero);
      expect(stepZero.shouldExpire, isTrue);

      final stepNegative = stepSleepTimer(const Duration(seconds: -1));
      expect(stepNegative.shouldExpire, isTrue);
    });

    test('null remaining time triggers cancellation', () {
      final step = stepSleepTimer(null);
      expect(step.shouldCancel, isTrue);
      expect(step.shouldExpire, isFalse);
    });
  });

  group('calculateEndOfChapterRemaining math', () {
    test('multi-file book uses trackDuration minus current position', () {
      final remaining = calculateEndOfChapterRemaining(
        position: const Duration(minutes: 10),
        trackDuration: const Duration(minutes: 45),
        hasCustomChapters: true,
      );

      expect(remaining, const Duration(minutes: 35));
    });

    test('multi-file book with non-positive trackDuration falls back to fallbackDuration', () {
      final remaining = calculateEndOfChapterRemaining(
        position: const Duration(minutes: 5),
        trackDuration: Duration.zero,
        hasCustomChapters: true,
        fallbackDuration: const Duration(minutes: 60),
      );

      expect(remaining, const Duration(minutes: 60));
    });

    test('single-file book with chapters calculates remaining to current chapter endTime', () {
      final chapters = [
        Chapter(title: 'Ch 1', startTime: 0, endTime: 300),
        Chapter(title: 'Ch 2', startTime: 300, endTime: 900), // ends at 900s (15 min)
      ];

      final remaining = calculateEndOfChapterRemaining(
        position: const Duration(seconds: 400),
        trackDuration: const Duration(hours: 1),
        hasCustomChapters: false,
        customChapters: chapters,
        currentIndex: 1,
      );

      // 900s - 400s = 500s
      expect(remaining, const Duration(seconds: 500));
    });

    test('single-file book without chapters calculates remaining to trackDuration', () {
      final remaining = calculateEndOfChapterRemaining(
        position: const Duration(minutes: 20),
        trackDuration: const Duration(minutes: 50),
        hasCustomChapters: false,
        customChapters: null,
      );

      expect(remaining, const Duration(minutes: 30));
    });
  });
}
