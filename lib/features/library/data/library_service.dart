import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import 'book.dart';

final libraryServiceProvider = Provider<LibraryService>((ref) {
  return LibraryService(Hive.box<Book>('library'));
});

final libraryBooksProvider = StreamProvider<List<Book>>((ref) {
  final service = ref.watch(libraryServiceProvider);
  return service.listenToBooks();
});

class LibraryService {
  final Box<Book> _box;

  LibraryService(this._box);

  List<Book> get books => _box.values.toList();

  Stream<List<Book>> listenToBooks() {
    return _box
        .watch()
        .map((event) => _box.values.toList())
        .startWith(_box.values.toList());
  }

  Future<void> scanDirectory(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) return;

    final List<FileSystemEntity> entities = await dir
        .list(recursive: true, followLinks: false)
        .toList();

    final audioExtensions = {'.mp3', '.m4b', '.m4a', '.flac', '.ogg', '.wav'};

    for (final entity in entities) {
      if (entity is File) {
        final ext = p.extension(entity.path).toLowerCase();
        if (audioExtensions.contains(ext)) {
          await _addBookIfNotExists(entity.path);
        }
      }
    }
  }

  Future<void> _addBookIfNotExists(String path) async {
    // Check if already in DB (naive O(n) check, optimize later if needed)
    final exists = _box.values.any((b) => b.path == path);
    if (exists) return;

    final filename = p.basenameWithoutExtension(path);

    final book = Book(
      path: path,
      title: filename, // Temporary title until metadata parsed
      lastPlayed: DateTime.now(),
    );

    await _box.add(book);
  }

  Future<void> updateProgress(String path, double positionSeconds) async {
    try {
      final book = _box.values.firstWhere((b) => b.path == path);
      book.positionSeconds = positionSeconds;
      book.lastPlayed = DateTime.now();
      await book.save();
    } catch (e) {
      // Book not found in library, ignore
    }
  }
}

extension StreamStartWith<T> on Stream<T> {
  Stream<T> startWith(T value) async* {
    yield value;
    yield* this;
  }
}
