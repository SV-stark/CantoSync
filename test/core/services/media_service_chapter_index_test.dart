import 'package:flutter_test/flutter_test.dart';
import 'package:canto_sync/core/services/media_service.dart';

/// `MediaService.currentChapterIndex` is the shared helper that both
/// `previousChapter` (restart-vs-step-back) and the end-of-chapter sleep timer
/// rely on to locate the chapter containing the current position.
void main() {
  final chapters = [
    Chapter(title: 'One', startTime: 0, endTime: 120),
    Chapter(title: 'Two', startTime: 120, endTime: 300),
    Chapter(title: 'Three', startTime: 300, endTime: 600),
  ];

  group('MediaService.currentChapterIndex', () {
    test('returns 0 for an empty chapter list', () {
      expect(MediaService.currentChapterIndex([], 42), 0);
    });

    test('returns 0 for a position before the first chapter start', () {
      expect(MediaService.currentChapterIndex(chapters, 0), 0);
    });

    test('matches a chapter exactly on its start boundary', () {
      expect(MediaService.currentChapterIndex(chapters, 120), 1);
      expect(MediaService.currentChapterIndex(chapters, 300), 2);
    });

    test('returns the last chapter whose startTime is <= position', () {
      expect(MediaService.currentChapterIndex(chapters, 119.9), 0);
      expect(MediaService.currentChapterIndex(chapters, 299.9), 1);
      expect(MediaService.currentChapterIndex(chapters, 599), 2);
    });

    test('clamps a position past the end to the last chapter', () {
      expect(MediaService.currentChapterIndex(chapters, 99999), 2);
    });

    test('handles a negative position without throwing', () {
      expect(MediaService.currentChapterIndex(chapters, -10), 0);
    });

    test('handles chapters with a null endTime', () {
      final openEnded = [
        Chapter(title: 'A', startTime: 0),
        Chapter(title: 'B', startTime: 50),
      ];
      expect(MediaService.currentChapterIndex(openEnded, 75), 1);
    });

    test('single-chapter list always resolves to index 0', () {
      final single = [Chapter(title: 'Only', startTime: 0, endTime: 10)];
      expect(MediaService.currentChapterIndex(single, 999), 0);
    });

    test('stops at the first chapter starting after the position', () {
      // Unsorted-after-first input must not scan past a later start.
      final sparse = [
        Chapter(title: 'A', startTime: 0, endTime: 10),
        Chapter(title: 'B', startTime: 10, endTime: 20),
        Chapter(title: 'C', startTime: 1000, endTime: 1010),
      ];
      expect(MediaService.currentChapterIndex(sparse, 15), 1);
    });
  });
}
