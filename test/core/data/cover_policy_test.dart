import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:canto_sync/features/library/data/library_service.dart';

void main() {
  group('isDeletableCover (R2 regression guard)', () {
    test('cached cover under app directory is deletable', () {
      final coversDir = p.join('C:', 'Users', 'test', 'AppData', 'canto_sync', 'covers');
      final cachedCover = p.join(coversDir, 'a1b2c3d4.jpg');

      expect(isDeletableCover(coversDir, cachedCover), isTrue);
    });

    test('nested cached cover under app directory is deletable', () {
      final coversDir = p.join('/home', 'user', '.local', 'share', 'canto_sync', 'covers');
      final nestedCachedCover = p.join(coversDir, 'sub', 'cover.png');

      expect(isDeletableCover(coversDir, nestedCachedCover), isTrue);
    });

    test('user own folder cover on Windows (D:\\Books\\cover.jpg) is protected', () {
      final coversDir = p.join('C:', 'Users', 'test', 'AppData', 'canto_sync', 'covers');
      final userFolderCover = p.join('D:', 'Audiobooks', 'SciFi', 'Dune', 'cover.jpg');

      expect(isDeletableCover(coversDir, userFolderCover), isFalse);
    });

    test('user own folder cover on Linux (/media/book/cover.jpg) is protected', () {
      final coversDir = p.join('/home', 'user', '.local', 'share', 'canto_sync', 'covers');
      final userFolderCover = p.join('/media', 'external_drive', 'Books', 'cover.jpg');

      expect(isDeletableCover(coversDir, userFolderCover), isFalse);
    });

    test('exact coversDir path itself is not within coversDir', () {
      final coversDir = p.join('C:', 'canto_sync', 'covers');
      expect(isDeletableCover(coversDir, coversDir), isFalse);
    });

    test('sibling or parent directories are protected', () {
      final appDir = p.join('C:', 'Users', 'test', 'AppData', 'canto_sync');
      final coversDir = p.join(appDir, 'covers');
      final siblingDb = p.join(appDir, 'db.isar');

      expect(isDeletableCover(coversDir, siblingDb), isFalse);
    });
  });
}
