import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
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

    String? title;
    String? author;
    String? album;
    String? coverPath;
    double? duration;

    try {
      final metadata = await MetadataGod.readMetadata(file: path);
      title = metadata.title;
      author = metadata.artist;
      album = metadata.album;

      if (metadata.durationMs != null) {
        duration = metadata.durationMs! / 1000.0;
      }

      if (metadata.picture != null) {
        coverPath = await _extractAndCacheCover(metadata.picture!, path);
      }
    } catch (e) {
      debugPrint('Error reading metadata for $path: $e');
    }

    final filename = p.basenameWithoutExtension(path);

    final book = Book(
      path: path,
      title: title ?? filename,
      author: author,
      album: album,
      durationSeconds: duration,
      coverPath: coverPath,
      lastPlayed: DateTime.now(),
    );

    await _box.add(book);
  }

  Future<String?> _extractAndCacheCover(
    Picture picture,
    String audioPath,
  ) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final coversDir = Directory(p.join(appDir.path, 'canto_sync', 'covers'));
      if (!await coversDir.exists()) {
        await coversDir.create(recursive: true);
      }

      // Generate a unique hash for the cover based on audio path and mime type
      // Using audio path ensures we map 1:1, but might duplicate if same image is in multiple files.
      // Better: Hash the image bytes? Yes.
      final imageHash = md5.convert(picture.data).toString();
      final ext = picture.mimeType == 'image/png' ? '.png' : '.jpg';
      final coverFile = File(p.join(coversDir.path, '$imageHash$ext'));

      if (!await coverFile.exists()) {
        await coverFile.writeAsBytes(picture.data);
      }

      return coverFile.path;
    } catch (e) {
      debugPrint('Error saving cover art: $e');
      return null;
    }
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
