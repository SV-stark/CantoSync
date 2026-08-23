import 'package:flutter_test/flutter_test.dart';
import 'package:canto_sync/core/constants/app_constants.dart';
import 'package:canto_sync/features/library/data/book.dart';
import 'package:canto_sync/features/library/ui/library_screen.dart';

void main() {
  group('calculateBookProgress', () {
    test('single-file progress calculates pos / dur', () {
      final book = Book(
        durationSeconds: 1000.0,
        positionSeconds: 250.0,
        audioFiles: ['/book/audio.mp3'],
      );

      expect(calculateBookProgress(book), 0.25);
    });

    test('multi-file progress calculates cumulative offset via lastTrackIndex and filesMetadata durations', () {
      final book = Book(
        durationSeconds: 1000.0,
        positionSeconds: 50.0,
        lastTrackIndex: 2,
        audioFiles: [
          '/book/track1.mp3',
          '/book/track2.mp3',
          '/book/track3.mp3',
        ],
        filesMetadata: [
          FileMetadata(title: 'Track 1', duration: 200.0),
          FileMetadata(title: 'Track 2', duration: 300.0),
          FileMetadata(title: 'Track 3', duration: 500.0),
        ],
      );

      // Track 0 (200s) + Track 1 (300s) + current Track 2 pos (50s) = 550s / 1000s = 0.55
      expect(calculateBookProgress(book), 0.55);
    });

    test('null durations and missing fields treated gracefully, dur <= 0 returns 0', () {
      final zeroDurBook = Book(durationSeconds: 0, positionSeconds: 100);
      expect(calculateBookProgress(zeroDurBook), 0.0);

      final negativeDurBook = Book(durationSeconds: -50, positionSeconds: 100);
      expect(calculateBookProgress(negativeDurBook), 0.0);

      final nullDurBook = Book(durationSeconds: null, positionSeconds: 100);
      expect(calculateBookProgress(nullDurBook), 0.0);

      final nullPosBook = Book(durationSeconds: 200, positionSeconds: null);
      expect(calculateBookProgress(nullPosBook), 0.0);

      // Multi-file with null duration in one track metadata
      final multiNullMetadataBook = Book(
        durationSeconds: 600.0,
        positionSeconds: 50.0,
        lastTrackIndex: 2,
        audioFiles: ['/f1.mp3', '/f2.mp3', '/f3.mp3'],
        filesMetadata: [
          FileMetadata(title: 'T1', duration: 100.0),
          FileMetadata(title: 'T2', duration: null), // null treated as 0
          FileMetadata(title: 'T3', duration: 500.0),
        ],
      );
      // 100 + 0 + 50 = 150 / 600 = 0.25
      expect(calculateBookProgress(multiNullMetadataBook), 0.25);
    });

    test('progress is clamped to <= 1.0', () {
      final overProgressBook = Book(
        durationSeconds: 100.0,
        positionSeconds: 150.0,
      );
      expect(calculateBookProgress(overProgressBook), 1.0);
    });

    test('completion boundary at AppConstants.bookCompletionThreshold', () {
      const threshold = AppConstants.bookCompletionThreshold; // 0.95

      final justUnder = Book(
        durationSeconds: 1000.0,
        positionSeconds: 1000.0 * (threshold - 0.01),
      );
      final pUnder = calculateBookProgress(justUnder);
      expect(pUnder > 0 && pUnder < threshold, isTrue);

      final atThreshold = Book(
        durationSeconds: 1000.0,
        positionSeconds: 1000.0 * threshold,
      );
      final pAt = calculateBookProgress(atThreshold);
      expect(pAt >= threshold, isTrue);

      final completed = Book(
        durationSeconds: 1000.0,
        positionSeconds: 1000.0,
      );
      final pCompleted = calculateBookProgress(completed);
      expect(pCompleted >= threshold, isTrue);
    });
  });
}
