import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:canto_sync/features/library/data/library_service.dart';

void main() {
  group('performFileScan', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('cantosync_scan_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('recognizes all supported audio extensions including .opus (H5 regression guard)', () async {
      final supportedExtensions = ['.mp3', '.m4b', '.m4a', '.flac', '.ogg', '.wav', '.opus'];
      final createdFiles = <String>[];

      for (final ext in supportedExtensions) {
        final f = File(p.join(tempDir.path, 'track$ext'));
        await f.writeAsString('audio data');
        createdFiles.add(f.path);
      }

      final groups = await performFileScan(tempDir.path);

      expect(groups.length, 1);
      final found = groups[tempDir.path] ?? [];
      expect(found.length, supportedExtensions.length);
      for (final fPath in createdFiles) {
        expect(found.contains(fPath), isTrue, reason: 'Expected to find $fPath');
      }
    });

    test('ignores non-audio and unknown extensions', () async {
      final ignoredFiles = ['cover.jpg', 'notes.txt', 'info.nfo', 'track.exe', 'data.bin', 'thumb.png'];
      for (final name in ignoredFiles) {
        await File(p.join(tempDir.path, name)).writeAsString('dummy');
      }

      final validAudio = File(p.join(tempDir.path, 'chapter.mp3'));
      await validAudio.writeAsString('audio');

      final groups = await performFileScan(tempDir.path);

      expect(groups.length, 1);
      final found = groups[tempDir.path] ?? [];
      expect(found.length, 1);
      expect(found.first, validAudio.path);
    });

    test('single dropped FILE path branch returns group with parent dir and file', () async {
      final singleAudio = File(p.join(tempDir.path, 'single_audio.m4b'));
      await singleAudio.writeAsString('m4b content');

      final groups = await performFileScan(singleAudio.path);

      expect(groups.length, 1);
      expect(groups.containsKey(tempDir.path), isTrue);
      expect(groups[tempDir.path], [singleAudio.path]);
    });

    test('single dropped non-audio file returns empty map', () async {
      final textFile = File(p.join(tempDir.path, 'readme.txt'));
      await textFile.writeAsString('readme');

      final groups = await performFileScan(textFile.path);
      expect(groups, isEmpty);
    });

    test('groups files by parent folder across nested directories', () async {
      final authorDir = Directory(p.join(tempDir.path, 'Brandon Sanderson'));
      final book1Dir = Directory(p.join(authorDir.path, 'The Way of Kings'));
      final book2Dir = Directory(p.join(authorDir.path, 'Words of Radiance'));

      await book1Dir.create(recursive: true);
      await book2Dir.create(recursive: true);

      final b1Track1 = await File(p.join(book1Dir.path, 'part1.mp3')).create();
      final b1Track2 = await File(p.join(book1Dir.path, 'part2.mp3')).create();

      final b2Track1 = await File(p.join(book2Dir.path, 'part1.opus')).create();

      final groups = await performFileScan(tempDir.path);

      expect(groups.length, 2);
      expect(groups.containsKey(book1Dir.path), isTrue);
      expect(groups.containsKey(book2Dir.path), isTrue);

      expect(groups[book1Dir.path]!.length, 2);
      expect(groups[book1Dir.path], containsAll([b1Track1.path, b1Track2.path]));

      expect(groups[book2Dir.path]!.length, 1);
      expect(groups[book2Dir.path], contains(b2Track1.path));
    });

    test('non-existent path returns empty map', () async {
      final nonExistent = p.join(tempDir.path, 'non_existent_folder');
      final groups = await performFileScan(nonExistent);
      expect(groups, isEmpty);
    });
  });
}
