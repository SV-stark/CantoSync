import 'package:flutter_test/flutter_test.dart';
import 'package:canto_sync/core/services/playback_sync_service.dart';
import 'package:canto_sync/features/library/data/book.dart';

void main() {
  group('buildMultiFileChapters', () {
    test('cumulative startTime/endTime math for valid durations', () {
      final files = [
        FileMetadata(title: 'Part 1', duration: 100.0, path: '/book/part1.mp3'),
        FileMetadata(title: 'Part 2', duration: 250.0, path: '/book/part2.mp3'),
        FileMetadata(title: 'Part 3', duration: 150.0, path: '/book/part3.mp3'),
      ];

      final (chapters, totalDuration) = buildMultiFileChapters(files);

      expect(chapters.length, 3);
      expect(totalDuration, 500.0);

      expect(chapters[0].title, 'Part 1');
      expect(chapters[0].startTime, 0.0);
      expect(chapters[0].endTime, 100.0);
      expect(chapters[0].durationSeconds, 100.0);

      expect(chapters[1].title, 'Part 2');
      expect(chapters[1].startTime, 100.0);
      expect(chapters[1].endTime, 350.0);
      expect(chapters[1].durationSeconds, 250.0);

      expect(chapters[2].title, 'Part 3');
      expect(chapters[2].startTime, 350.0);
      expect(chapters[2].endTime, 500.0);
      expect(chapters[2].durationSeconds, 150.0);
    });

    test('null-duration file creates chapter without endTime and is excluded from total', () {
      final files = [
        FileMetadata(title: 'Intro', duration: 30.0),
        FileMetadata(title: 'Corrupted Track', duration: null),
        FileMetadata(title: 'Outro', duration: 40.0),
      ];

      final (chapters, totalDuration) = buildMultiFileChapters(files);

      expect(chapters.length, 3);
      expect(totalDuration, 70.0); // 30 + 40, null duration excluded

      // Track 1
      expect(chapters[0].title, 'Intro');
      expect(chapters[0].startTime, 0.0);
      expect(chapters[0].endTime, 30.0);

      // Track 2 (null duration -> startTime stays at 30.0, endTime is null)
      expect(chapters[1].title, 'Corrupted Track');
      expect(chapters[1].startTime, 30.0);
      expect(chapters[1].endTime, isNull);

      // Track 3 (startTime remains 30.0 because track 2 had null duration)
      expect(chapters[2].title, 'Outro');
      expect(chapters[2].startTime, 30.0);
      expect(chapters[2].endTime, 70.0);
    });

    test('handles single-file and empty input edge cases', () {
      // Empty input
      final (emptyChapters, emptyTotal) = buildMultiFileChapters([]);
      expect(emptyChapters, isEmpty);
      expect(emptyTotal, 0.0);

      // Single file with duration
      final (singleChapters, singleTotal) = buildMultiFileChapters([
        FileMetadata(title: 'Whole Book', duration: 3600.0),
      ]);
      expect(singleChapters.length, 1);
      expect(singleTotal, 3600.0);
      expect(singleChapters[0].title, 'Whole Book');
      expect(singleChapters[0].startTime, 0.0);
      expect(singleChapters[0].endTime, 3600.0);

      // Single file without title falls back to Track 1
      final (fallbackTitleChapters, _) = buildMultiFileChapters([
        FileMetadata(title: '', duration: 100.0),
      ]);
      expect(fallbackTitleChapters[0].title, 'Track 1');
    });
  });
}
