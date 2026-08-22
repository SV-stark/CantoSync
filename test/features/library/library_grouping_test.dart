import 'package:flutter_test/flutter_test.dart';
import 'package:canto_sync/features/library/data/book.dart';

void main() {
  group('Book model', () {
    test('fileExtension handles single file paths', () {
      final book = Book(path: 'D:/Audiobooks/book.opus');
      expect(book.fileExtension, 'opus');
    });

    test('fileExtension handles directory with audioFiles', () {
      final book = Book(
        path: 'D:/Audiobooks/AlbumFolder',
        isDirectory: true,
        audioFiles: ['D:/Audiobooks/AlbumFolder/01.m4b', 'D:/Audiobooks/AlbumFolder/02.m4b'],
      );
      expect(book.fileExtension, 'm4b');
    });

    test('fileExtension returns empty on empty path', () {
      final book = Book();
      expect(book.fileExtension, '');
    });
  });

  group('Series sorting logic', () {
    test('sorts series books by seriesIndex then title', () {
      final b1 = Book(title: 'Zeta Final', series: 'Epic', seriesIndex: 3);
      final b2 = Book(title: 'Alpha Prequel', series: 'Epic', seriesIndex: 1);
      final b3 = Book(title: 'Beta Mid', series: 'Epic', seriesIndex: 2);
      final b4 = Book(title: 'No Index B', series: 'Epic', seriesIndex: null);
      final b5 = Book(title: 'No Index A', series: 'Epic', seriesIndex: null);

      final list = [b1, b4, b2, b5, b3];
      list.sort((a, b) {
        if (a.seriesIndex != null && b.seriesIndex != null) {
          return a.seriesIndex!.compareTo(b.seriesIndex!);
        }
        if (a.seriesIndex != null) return -1;
        if (b.seriesIndex != null) return 1;
        return (a.title ?? '').compareTo(b.title ?? '');
      });

      expect(list.map((b) => b.title).toList(), [
        'Alpha Prequel', // index 1
        'Beta Mid',      // index 2
        'Zeta Final',    // index 3
        'No Index A',    // title sort
        'No Index B',    // title sort
      ]);
    });
  });
}
