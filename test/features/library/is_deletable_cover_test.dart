import 'package:flutter_test/flutter_test.dart';
import 'package:canto_sync/features/library/data/library_service.dart';
import 'package:path/path.dart' as p;

/// Guards the containment check that decides whether a cached cover file may
/// be deleted from disk. A false positive here deletes arbitrary user files;
/// a false negative leaks covers.
void main() {
  const coversDir = '/app/docs/canto_sync/covers';

  group('isDeletableCover', () {
    test('accepts a file directly inside the covers dir', () {
      expect(
        isDeletableCover(coversDir, p.join(coversDir, 'abc123.jpg')),
        isTrue,
      );
    });

    test('accepts a file in a nested subdirectory of the covers dir', () {
      expect(
        isDeletableCover(coversDir, p.join(coversDir, 'nested', 'abc.jpg')),
        isTrue,
      );
    });

    test('rejects a file outside the covers dir', () {
      expect(
        isDeletableCover(coversDir, '/app/docs/canto_sync/other/abc.jpg'),
        isFalse,
      );
    });

    test('rejects a sibling directory sharing the covers prefix', () {
      // 'covers_backup' starts with 'covers' but is not within it.
      expect(
        isDeletableCover(coversDir, '/app/docs/canto_sync/covers_old/a.jpg'),
        isFalse,
      );
    });

    test('rejects the covers dir itself', () {
      expect(isDeletableCover(coversDir, coversDir), isFalse);
    });

    test('normalises mixed separators before comparing', () {
      // Isar can return Windows-style paths while the covers dir is built from
      // path_provider; a raw string compare used to fail here and leak covers.
      final mixed = '$coversDir\\win-style.jpg';
      expect(isDeletableCover(coversDir, mixed), isTrue);
    });

    test('resolves a relative cover path against the cwd, not the covers dir', () {
      // Both sides go through p.absolute, so a bare relative path lands under
      // the process cwd. That must be rejected -- it is not a cached cover.
      expect(isDeletableCover(coversDir, 'abc.jpg'), isFalse);
    });

    test('accepts an absolute path that lands inside the covers dir', () {
      final base = p.absolute(coversDir);
      expect(
        isDeletableCover(base, p.join(base, 'abc.jpg')),
        isTrue,
      );
    });
  });
}
