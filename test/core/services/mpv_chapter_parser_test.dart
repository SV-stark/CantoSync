import 'package:flutter_test/flutter_test.dart';
import 'package:canto_sync/core/services/media_service.dart';

void main() {
  group('parseMpvChapters', () {
    test('valid chapter-list parses titles and times with end = next.start', () {
      final json = [
        {'title': 'Prologue', 'time': 0.0},
        {'title': 'Chapter 1', 'time': 120.5},
        {'title': 'Chapter 2', 'time': 300.0},
      ];

      final chapters = parseMpvChapters(json, const Duration(seconds: 500));

      expect(chapters.length, 3);

      expect(chapters[0].title, 'Prologue');
      expect(chapters[0].startTime, 0.0);
      expect(chapters[0].endTime, 120.5);
      expect(chapters[0].durationSeconds, 120.5);

      expect(chapters[1].title, 'Chapter 1');
      expect(chapters[1].startTime, 120.5);
      expect(chapters[1].endTime, 300.0);
      expect(chapters[1].durationSeconds, 179.5);

      expect(chapters[2].title, 'Chapter 2');
      expect(chapters[2].startTime, 300.0);
      expect(chapters[2].endTime, 500.0);
      expect(chapters[2].durationSeconds, 200.0);
    });

    test('last chapter endTime falls back to player duration', () {
      final json = [
        {'title': 'Only Chapter', 'time': 0.0},
      ];

      final chaptersWithDur = parseMpvChapters(json, const Duration(minutes: 10));
      expect(chaptersWithDur.length, 1);
      expect(chaptersWithDur[0].endTime, 600.0);

      final chaptersZeroDur = parseMpvChapters(json, Duration.zero);
      expect(chaptersZeroDur.length, 1);
      expect(chaptersZeroDur[0].endTime, isNull);
    });

    test('non-map entries are skipped', () {
      final json = [
        'not a map',
        123,
        {'title': 'Valid Chapter', 'time': 10.0},
        null,
        ['nested list'],
      ];

      final chapters = parseMpvChapters(json, const Duration(seconds: 60));
      expect(chapters.length, 1);
      expect(chapters[0].title, 'Valid Chapter');
      expect(chapters[0].startTime, 10.0);
      expect(chapters[0].endTime, 60.0);
    });

    test('missing time defaults to 0.0 and missing title defaults to Chapter N', () {
      final json = [
        {'foo': 'bar'},
        {'time': 45.0},
      ];

      final chapters = parseMpvChapters(json, const Duration(seconds: 100));
      expect(chapters.length, 2);

      // index 0 -> 'Chapter 1', time missing -> 0.0, endTime = 45.0
      expect(chapters[0].title, 'Chapter 1');
      expect(chapters[0].startTime, 0.0);
      expect(chapters[0].endTime, 45.0);

      // index 1 -> 'Chapter 2', time = 45.0, endTime = 100.0
      expect(chapters[1].title, 'Chapter 2');
      expect(chapters[1].startTime, 45.0);
      expect(chapters[1].endTime, 100.0);
    });

    test('malformed JSON / empty list returns empty list', () {
      expect(parseMpvChapters(null, const Duration(seconds: 100)), isEmpty);
      expect(parseMpvChapters([], const Duration(seconds: 100)), isEmpty);
      expect(parseMpvChapters('string json', const Duration(seconds: 100)), isEmpty);
      expect(parseMpvChapters(42, const Duration(seconds: 100)), isEmpty);
      expect(parseMpvChapters({}, const Duration(seconds: 100)), isEmpty);
    });
  });
}
