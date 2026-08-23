import 'package:flutter_test/flutter_test.dart';
import 'package:canto_sync/features/library/data/book.dart';
import 'package:canto_sync/features/library/data/library_service.dart';

void main() {
  group('filterBooks', () {
    final book1 = Book(
      title: 'The Hobbit',
      author: 'J.R.R. Tolkien',
      narrator: 'Andy Serkis',
      album: 'The Lord of the Rings Prelude',
      collections: ['Fantasy', 'Favorites'],
    );
    final book2 = Book(
      title: 'Project Hail Mary',
      author: 'Andy Weir',
      narrator: 'Ray Porter',
      album: 'Sci-Fi Hits',
      collections: ['Sci-Fi', 'Favorites'],
    );
    final book3 = Book(
      title: 'Dune',
      author: 'Frank Herbert',
      narrator: 'Scott Brick',
      album: 'Dune Chronicles',
      collections: ['Sci-Fi'],
    );
    final allBooks = [book1, book2, book3];

    test('empty query and null collection returns all books', () {
      final results = filterBooks(allBooks, '', null);
      expect(results.length, 3);
      expect(results, equals(allBooks));
    });

    test('matches title case-insensitively', () {
      final results = filterBooks(allBooks, 'hobbit', null);
      expect(results.length, 1);
      expect(results.first.title, 'The Hobbit');

      final upperResults = filterBooks(allBooks, 'DUNE', null);
      expect(upperResults.length, 1);
      expect(upperResults.first.title, 'Dune');
    });

    test('matches author case-insensitively', () {
      final results = filterBooks(allBooks, 'tolkien', null);
      expect(results.length, 1);
      expect(results.first.title, 'The Hobbit');

      final weirResults = filterBooks(allBooks, 'andy weir', null);
      expect(weirResults.length, 1);
      expect(weirResults.first.title, 'Project Hail Mary');
    });

    test('matches narrator case-insensitively', () {
      // Andy Serkis narrated Hobbit, Andy Weir wrote Project Hail Mary -> 'andy' matches both
      final andyMatches = filterBooks(allBooks, 'andy', null);
      expect(andyMatches.length, 2);

      final porterMatches = filterBooks(allBooks, 'ray porter', null);
      expect(porterMatches.length, 1);
      expect(porterMatches.first.title, 'Project Hail Mary');
    });

    test('matches album case-insensitively', () {
      final results = filterBooks(allBooks, 'chronicles', null);
      expect(results.length, 1);
      expect(results.first.title, 'Dune');
    });

    test('collection filter filters books correctly', () {
      final favorites = filterBooks(allBooks, '', 'Favorites');
      expect(favorites.length, 2);
      expect(favorites.map((b) => b.title), containsAll(['The Hobbit', 'Project Hail Mary']));

      final fantasy = filterBooks(allBooks, '', 'Fantasy');
      expect(fantasy.length, 1);
      expect(fantasy.first.title, 'The Hobbit');
    });

    test('combined search query and collection filter', () {
      // 'Andy' in 'Favorites' matches both Hobbit (narrator Andy) and Hail Mary (author Andy)
      final favAndies = filterBooks(allBooks, 'andy', 'Favorites');
      expect(favAndies.length, 2);

      // 'Andy' in 'Fantasy' only matches Hobbit
      final fantasyAndies = filterBooks(allBooks, 'andy', 'Fantasy');
      expect(fantasyAndies.length, 1);
      expect(fantasyAndies.first.title, 'The Hobbit');

      // 'Dune' in 'Favorites' matches none
      final duneFavs = filterBooks(allBooks, 'dune', 'Favorites');
      expect(duneFavs, isEmpty);
    });

    test('handles books with null fields gracefully', () {
      final emptyBook = Book();
      final results = filterBooks([emptyBook], 'test', null);
      expect(results, isEmpty);

      final matchEmpty = filterBooks([emptyBook], '', null);
      expect(matchEmpty.length, 1);
    });
  });
}
