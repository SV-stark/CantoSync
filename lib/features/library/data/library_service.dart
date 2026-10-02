import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:isar_community/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:metadata_audio/metadata_audio.dart' hide Chapter;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:canto_sync/core/data/isar_provider.dart';
import 'package:canto_sync/core/services/app_settings_service.dart';
import 'package:canto_sync/core/utils/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'book.dart';

part 'library_service.g.dart';

@Riverpod(keepAlive: true)
LibraryService libraryService(Ref ref) {
  final isarInstance = ref.watch(isarProvider);
  return LibraryService(isarInstance, ref);
}

@riverpod
class LibrarySearchQuery extends _$LibrarySearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) => state = query;
  void setQuery(String query) => state = query;
}

@riverpod
class LibraryGroupingMode extends _$LibraryGroupingMode {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

@riverpod
class LibraryCollectionFilter extends _$LibraryCollectionFilter {
  @override
  String? build() => null;

  void setFilter(String? collection) => state = collection;
}

List<Book> filterBooks(
  List<Book> books,
  String query,
  String? collectionFilter,
) {
  var filteredBooks = books;

  if (collectionFilter != null) {
    filteredBooks = filteredBooks
        .where((b) => b.collections?.contains(collectionFilter) ?? false)
        .toList();
  }

  final trimmed = query.toLowerCase();
  if (trimmed.isEmpty) return filteredBooks;
  return filteredBooks.where((book) {
    final title = book.title?.toLowerCase() ?? '';
    final author = book.author?.toLowerCase() ?? '';
    final narrator = book.narrator?.toLowerCase() ?? '';
    final album = book.album?.toLowerCase() ?? '';
    final series = book.series?.toLowerCase() ?? '';
    final description = book.description?.toLowerCase() ?? '';
    return title.contains(trimmed) ||
        author.contains(trimmed) ||
        narrator.contains(trimmed) ||
        album.contains(trimmed) ||
        series.contains(trimmed) ||
        description.contains(trimmed);
  }).toList();
}

/// Returns a stream of books filtered by search query and collection.
/// Note: Riverpod automatically wraps this Stream in an [AsyncValue].
@riverpod
Stream<List<Book>> libraryBooks(Ref ref) {
  final service = ref.watch(libraryServiceProvider);
  final searchQuery = ref.watch(librarySearchQueryProvider);
  final collectionFilter = ref.watch(libraryCollectionFilterProvider);

  return service
      .listenToBooks()
      .map((books) => filterBooks(books, searchQuery, collectionFilter));
}

@riverpod
List<Book> libraryRecentBooks(Ref ref) {
  final booksAsync = ref.watch(libraryBooksProvider);
  return booksAsync.maybeWhen(
    data: (books) {
      // Only surface books with real progress, otherwise "Continue Listening"
      // fills with never-opened titles when fewer than 5 books have been played.
      final played = books
          .where((b) => b.lastPlayed != null || (b.positionSeconds ?? 0) > 0)
          .toList();
      played.sort(
        (a, b) => (b.lastPlayed ?? DateTime(0)).compareTo(
          a.lastPlayed ?? DateTime(0),
        ),
      );
      return played.take(5).toList();
    },
    orElse: () => [],
  );
}

@riverpod
Stream<List<String>> libraryCollections(Ref ref) {
  final service = ref.watch(libraryServiceProvider);
  return service.listenToBooks().map((books) {
    final collections = <String>{};
    for (final book in books) {
      if (book.collections != null) {
        collections.addAll(book.collections!);
      }
    }
    return collections.toList()..sort();
  });
}

@riverpod
Future<Map<String, List<Book>>> libraryGroupedBooks(Ref ref) async {
  final books = await ref.watch(libraryBooksProvider.future);

  final Map<String, List<Book>> groups = {};
  for (final book in books) {
    final key = book.series ?? 'Standalone';
    groups.putIfAbsent(key, () => []).add(book);
  }

  // Sort books within each series by seriesIndex then title
  for (final entry in groups.entries) {
    if (entry.key != 'Standalone') {
      entry.value.sort((a, b) {
        if (a.seriesIndex != null && b.seriesIndex != null) {
          return a.seriesIndex!.compareTo(b.seriesIndex!);
        }
        if (a.seriesIndex != null) return -1;
        if (b.seriesIndex != null) return 1;
        return (a.title ?? '').compareTo(b.title ?? '');
      });
    }
  }

  return groups;
}

String _cleanMetadataString(String str) {
  // Only collapse runs of whitespace. Replacing every '-' and '_' mangled real
  // titles ("Spider-Man" -> "Spider Man", "Sci-Fi" -> "Sci Fi") and the damage
  // was then persisted over the user's own metadata on every rescan.
  return str.replaceAll(RegExp(r'\s+'), ' ').trim();
}

bool isDeletableCover(String coversDirPath, String coverPath) {
  // Normalise both sides: Isar can return paths with '/' separators even on
  // Windows, and a mixed-separator comparison makes isWithin() return false,
  // so cached covers were never actually removed.
  return p.isWithin(
    p.normalize(p.absolute(coversDirPath)),
    p.normalize(p.absolute(coverPath)),
  );
}

/// Deletes cached cover files that live inside the app-managed covers dir.
Future<void> _deleteCachedCovers(Iterable<String> coverPaths) async {
  try {
    final appDir = await getApplicationDocumentsDirectory();
    final coversDirPath = p.join(appDir.path, 'canto_sync', 'covers');
    for (final coverPath in coverPaths) {
      if (!isDeletableCover(coversDirPath, coverPath)) continue;
      final file = File(coverPath);
      if (await file.exists()) {
        await file.delete();
        logger.d('Deleted cached cover file: $coverPath');
      }
    }
  } catch (e) {
    logger.w('Failed to delete cached cover files: $e');
  }
}

Future<Map<String, List<String>>> performFileScan(String path) async {
  final audioExtensions = {'.mp3', '.m4b', '.m4a', '.flac', '.ogg', '.wav', '.opus'};
  final Map<String, List<String>> groups = {};

  final file = File(path);
  if (await file.exists()) {
    final ext = p.extension(path).toLowerCase();
    if (audioExtensions.contains(ext)) {
      groups[p.dirname(path)] = [path];
      return groups;
    }
  }

  final dir = Directory(path);
  if (!await dir.exists()) return {};

  final entities = await dir.list(recursive: true, followLinks: false).toList();

  for (final entity in entities) {
    if (entity is File) {
      final ext = p.extension(entity.path).toLowerCase();
      if (audioExtensions.contains(ext)) {
        final parent = p.dirname(entity.path);
        groups.putIfAbsent(parent, () => []).add(entity.path);
      }
    }
  }
  return groups;
}

class LibraryService {
  LibraryService(this._isar, this._ref);
  final Isar _isar;
  final Ref _ref;

  Future<List<Book>> getAllBooks() async {
    return _isar.books.where().findAll();
  }

  Future<Book?> getBookByPath(String path) async {
    return _isar.books.where().pathEqualTo(path).findFirst();
  }

  Future<void> saveBook(Book book) async {
    await _isar.writeTxn(() async {
      await _isar.books.put(book);
    });
  }

  /// Persists mpv-discovered chapters for a single-file book.
  ///
  /// Re-reads the row inside the transaction instead of writing a caller-held
  /// snapshot, so a concurrent progress update is not clobbered.
  Future<void> saveChapters(String? path, List<ChapterMetadata> chapters) async {
    if (path == null || chapters.isEmpty) return;
    await _isar.writeTxn(() async {
      final book = await _isar.books.where().pathEqualTo(path).findFirst();
      if (book == null) return;
      book.internalChapters = chapters;
      await _isar.books.put(book);
    });
  }

  Future<void> deleteBook(String path) async {
    final book = await _isar.books.where().pathEqualTo(path).findFirst();
    if (book?.coverPath != null) {
      await _deleteCachedCovers([book!.coverPath!]);
    }
    await _isar.writeTxn(() async {
      await _isar.books.where().pathEqualTo(path).deleteFirst();
    });
  }

  Stream<List<Book>> listenToBooks() {
    return _isar.books
        .where()
        .watch(fireImmediately: true)
        .throttleTime(
          const Duration(seconds: 3),
          leading: true,
          trailing: true,
        );
  }

  Future<void> assignCollection(String path, String collectionName) async {
    final book = await _isar.books.where().pathEqualTo(path).findFirst();
    if (book != null) {
      final collections = List<String>.from(book.collections ?? []);
      if (!collections.contains(collectionName)) {
        collections.add(collectionName);
        book.collections = collections;
        await saveBook(book);
      }
    }
  }

  Future<void> removeBookFromCollection(String path, String collectionName) async {
    final book = await _isar.books.where().pathEqualTo(path).findFirst();
    if (book != null && (book.collections?.contains(collectionName) ?? false)) {
      final collections = List<String>.from(book.collections!);
      collections.remove(collectionName);
      book.collections = collections;
      await saveBook(book);
    }
  }

  Future<void> removeCollection(String collectionName) async {
    final books = await getAllBooks();
    final updatedBooks = <Book>[];
    for (final book in books) {
      if (book.collections?.contains(collectionName) ?? false) {
        book.collections!.remove(collectionName);
        updatedBooks.add(book);
      }
    }
    if (updatedBooks.isNotEmpty) {
      await _isar.writeTxn(() async {
        await _isar.books.putAll(updatedBooks);
      });
    }
  }

  /// Scans every configured library path and reconciles the database.
  Future<void> rescanLibraries() async {
    final settings = _ref.read(appSettingsProvider);
    final libraryPaths = settings.libraryPaths;

    // No probe Player is created here: metadata is read via parseFile in
    // isolates, so the native handle was allocated and never used.
    final Set<String> allFoundBookPaths = {};

    for (final path in libraryPaths) {
      if (await Directory(path).exists()) {
        final found = await _scanDirectory(path);
        allFoundBookPaths.addAll(found);
      } else {
        logger.w('Library folder inaccessible (unmounted/offline): $path');
      }
    }

    final existingBooks = await getAllBooks();
    final idsToRemove = <int>[];

    for (final book in existingBooks) {
      final bookPath = book.path;
      if (bookPath == null) continue;

      // A book outside every configured library path is no longer managed.
      // Without this, removing a folder in Settings left its books in the
      // database forever, still showing progress bars and resume positions.
      final isUnderAnyLibrary = libraryPaths.any(
        (libPath) =>
            p.isWithin(libPath, bookPath) || p.equals(libPath, bookPath),
      );
      if (!isUnderAnyLibrary) {
        // Guard: if the user has removed every library, keep the existing rows
        // rather than wiping the database.
        if (libraryPaths.isNotEmpty) {
          idsToRemove.add(book.id);
        }
        continue;
      }

      final libPath = libraryPaths.firstWhere(
        (lib) => p.isWithin(lib, bookPath) || p.equals(lib, bookPath),
      );
      // Only prune from a library that is actually mounted: an offline drive
      // must not delete the whole library from the database.
      final isLibAvailable = await Directory(libPath).exists();
      if (isLibAvailable && !allFoundBookPaths.contains(bookPath)) {
        idsToRemove.add(book.id);
      }
    }

    if (idsToRemove.isNotEmpty) {
      // Collect cached covers before deleting so the orphaned files on disk
      // are cleaned up too, matching what cleanOrphanedBooks() does.
      final coversToDelete = existingBooks
          .where((b) => idsToRemove.contains(b.id) && b.coverPath != null)
          .map((b) => b.coverPath!)
          .toList();

      await _isar.writeTxn(() async {
        await _isar.books.deleteAll(idsToRemove);
      });
      await _deleteCachedCovers(coversToDelete);
    }

    // After scanning all, update series indices if needed
    await _updateSeriesIndices();
  }

  Future<void> _updateSeriesIndices() async {
    final books = await getAllBooks();
    final Map<String, List<Book>> seriesGroups = {};
    for (var b in books) {
      if (b.series != null && b.series!.isNotEmpty) {
        seriesGroups.putIfAbsent(b.series!, () => []).add(b);
      }
    }

    final updatedBooks = <Book>[];
    for (var entry in seriesGroups.entries) {
      final seriesBooks = entry.value;
      // Order by explicit index first, then title. Books with no index sort
      // LAST (not first) so that appending a newly-discovered title to an
      // existing series yields the next sequential number rather than
      // colliding with the volumes the user already numbered.
      seriesBooks.sort((a, b) {
        if (a.seriesIndex != null && b.seriesIndex != null) {
          return a.seriesIndex!.compareTo(b.seriesIndex!);
        }
        if (a.seriesIndex != null) return -1;
        if (b.seriesIndex != null) return 1;
        return (a.title ?? '').compareTo(b.title ?? '');
      });

      // Number from the highest existing index so explicit user-set values
      // are preserved and only gaps at the tail get filled in.
      var next = 1;
      for (final book in seriesBooks) {
        if (book.seriesIndex != null) {
          next = book.seriesIndex! + 1;
        } else {
          book.seriesIndex = next;
          next++;
          updatedBooks.add(book);
        }
      }
    }

    if (updatedBooks.isNotEmpty) {
      await _isar.writeTxn(() async {
        await _isar.books.putAll(updatedBooks);
      });
    }
  }

  Future<List<String>> scanDirectory(String path, {bool forceUpdate = false}) async {
    return _scanDirectory(path, forceUpdate: forceUpdate);
  }

  Future<void> updateBookCover(Book book, String newCoverFile) async {
    try {
      final sourceFile = File(newCoverFile);
      if (!await sourceFile.exists()) {
        logger.w('Source cover file does not exist: $newCoverFile');
        return;
      }
      final appDir = await getApplicationDocumentsDirectory();
      final coversDir = Directory(p.join(appDir.path, 'canto_sync', 'covers'));
      if (!await coversDir.exists()) {
        await coversDir.create(recursive: true);
      }
      final ext = p.extension(newCoverFile);
      final hash = md5.convert(await sourceFile.readAsBytes()).toString();
      final targetPath = p.join(coversDir.path, '$hash$ext');
      await sourceFile.copy(targetPath);

      book.coverPath = targetPath;
      await saveBook(book);
    } catch (e, stack) {
      logger.e('Error updating book cover', error: e, stackTrace: stack);
    }
  }

  Future<String?> _findLocalCoverImage(
    String bookPath, {
    required bool isDirectory,
  }) async {
    try {
      final dirPath = isDirectory ? bookPath : p.dirname(bookPath);
      final dir = Directory(dirPath);
      if (!await dir.exists()) return null;

      final imageExtensions = {'.jpg', '.jpeg', '.png', '.webp', '.bmp'};
      final entities = await dir
          .list(recursive: false, followLinks: false)
          .toList();

      // Common cover filenames, most-specific first. Matching only on the
      // substring "cover" missed folder.jpg / front.jpg / <title>.jpg.
      const preferredNames = [
        'cover',
        'folder',
        'front',
        'albumart',
        'album',
        'artwork',
        'art',
        'thumb',
        'image',
        'img',
      ];

      for (final entity in entities) {
        if (entity is! File) continue;
        final name = p.basename(entity.path).toLowerCase();
        final ext = p.extension(entity.path).toLowerCase();
        if (!imageExtensions.contains(ext)) continue;

        final stem = p.basenameWithoutExtension(name);
        if (preferredNames.contains(stem) || stem.startsWith('cover')) {
          return entity.path;
        }
      }

      // Fall back to the single image in the folder if there is exactly one.
      final images = entities
          .whereType<File>()
          .where(
            (f) => imageExtensions.contains(
              p.extension(f.path).toLowerCase(),
            ),
          )
          .toList();
      if (images.length == 1) return images.first.path;
    } catch (e) {
      logger.w('Error scanning for local cover image in $bookPath: $e');
    }
    return null;
  }

  Future<List<String>> _scanDirectory(String path, {bool forceUpdate = false}) async {
    final groups = await Isolate.run(() => performFileScan(path));
    final List<String> foundBookPaths = [];

    for (final entry in groups.entries) {
      final parentPath = entry.key;
      final filePaths = entry.value;

      filePaths.sort();

      await _addBookIfNotExists(
        parentPath,
        isDirectory: true,
        audioFiles: filePaths,
        forceUpdate: forceUpdate,
      );
      foundBookPaths.add(parentPath);
    }
    return foundBookPaths;
  }

  Future<void> _addBookIfNotExists(
    String path, {
    required bool isDirectory,
    List<String>? audioFiles,
    bool forceUpdate = false,
  }) async {
    final existingBook = await _isar.books
        .where()
        .pathEqualTo(path)
        .findFirst();
    if (existingBook != null && !forceUpdate) {
      // Even on non-forced scan, update cover if it's missing
      if (existingBook.coverPath == null) {
        await _updateCoverForBook(existingBook, path, audioFiles);
      }
      return;
    }

    String? title;
    String? author;
    String? album;
    String? narrator;
    String? coverPath;
    String? description;
    double duration = 0;

    final folderName = p.basename(path);
    final List<ChapterMetadata> internalChapters = [];
    final List<FileMetadata> fileMetaList = [];

    try {
      String metadataSourcePath = path;
      if (isDirectory && audioFiles != null && audioFiles.isNotEmpty) {
        metadataSourcePath = audioFiles.first;
      }

      final metadata = await Isolate.run(
        () => parseFile(
          metadataSourcePath,
          options: const ParseOptions(duration: true, includeChapters: true),
        ),
      );
      title = metadata.common.title != null
          ? _cleanMetadataString(metadata.common.title!)
          : null;
      author = metadata.common.artist != null
          ? _cleanMetadataString(metadata.common.artist!)
          : null;
      album = metadata.common.album != null
          ? _cleanMetadataString(metadata.common.album!)
          : null;

      final composers = metadata.common.composer;
      if (composers != null && composers.isNotEmpty) {
        narrator = _cleanMetadataString(composers.first);
      }

      // selectCover picks the largest embedded picture. The previous
      // try/catch around it was unreachable dead code and swallowed errors.
      final pictures = metadata.common.picture;
      Picture? cover;
      if (pictures != null && pictures.isNotEmpty) {
        try {
          cover = selectCover(pictures);
        } catch (e, stack) {
          logger.w(
            'selectCover failed for $metadataSourcePath, using first picture',
            error: e,
            stackTrace: stack,
          );
          cover = pictures.first;
        }
        cover ??= pictures.first;
      }

      final localCover = await _findLocalCoverImage(
        path,
        isDirectory: isDirectory,
      );
      if (localCover != null) {
        coverPath = localCover;
        logger.i('Found local cover image for book at: $localCover');
      } else if (cover != null) {
        logger.i(
          'Found cover art in metadata for $metadataSourcePath. Size: ${cover.data.length} bytes',
        );
        coverPath = await _extractAndCacheCover(cover, metadataSourcePath);
        logger.i('Extracted cover to: $coverPath');
      } else {
        logger.w(
          'No cover art found in metadata or folder for $metadataSourcePath',
        );
      }

      if (metadata.format.chapters != null &&
          metadata.format.chapters!.isNotEmpty) {
        for (final chapter in metadata.format.chapters!) {
          String? chapterCoverPath;
          if (chapter.image != null) {
            chapterCoverPath = await _extractAndCacheCover(
              chapter.image!,
              '$metadataSourcePath#${chapter.title}',
            );
          }
          internalChapters.add(
            ChapterMetadata(
              title: chapter.title,
              startTime: chapter.start / (chapter.timeScale ?? 1000),
              endTime: chapter.end != null
                  ? chapter.end! / (chapter.timeScale ?? 1000)
                  : null,
              coverPath: chapterCoverPath,
            ),
          );
        }
        logger.i(
          'Extracted ${internalChapters.length} internal chapters for $metadataSourcePath',
        );
      }

      description =
          metadata.common.longDescription?.toString() ??
          metadata.common.description?.toString();

      if (audioFiles != null) {
        // Process in bounded chunks of 8 concurrent isolates to prevent isolate thrashing
        const chunkSize = 8;
        final results = <FileMetadata>[];
        for (var i = 0; i < audioFiles.length; i += chunkSize) {
          final chunk = audioFiles.sublist(
            i,
            i + chunkSize > audioFiles.length ? audioFiles.length : i + chunkSize,
          );
          final chunkResults = await Future.wait(
            chunk.map(
              (filePath) => Isolate.run(() async {
                try {
                  final fileMeta = await parseFile(
                    filePath,
                    options: const ParseOptions(duration: true),
                  );
                  return FileMetadata(
                    path: filePath,
                    title: fileMeta.common.title != null
                        ? _cleanMetadataString(fileMeta.common.title!)
                        : _cleanMetadataString(
                            p.basenameWithoutExtension(filePath),
                          ),
                    duration: fileMeta.format.duration,
                  );
                } catch (e) {
                  return FileMetadata(
                    path: filePath,
                    title: _cleanMetadataString(
                      p.basenameWithoutExtension(filePath),
                    ),
                    duration: null,
                  );
                }
              }),
            ),
          );
          results.addAll(chunkResults);
        }

        for (final m in results) {
          if (m.duration != null) {
            duration += m.duration!;
          }
          fileMetaList.add(m);
        }
      } else {
        if (metadata.format.duration != null) {
          duration = metadata.format.duration!;
        }
      }
    } catch (e, stack) {
      logger.e('Error reading metadata for $path', error: e, stackTrace: stack);
    }

    if (existingBook != null) {
      // Preserve anything the user has overridden by hand in the metadata
      // editor. Only refresh a field when the file actually supplies a value,
      // otherwise a rescan would revert the user's edits (e.g. a cleaned-up
      // title, a hand-written series, a chosen cover art).
      final mergedTitle = title;
      existingBook.title = (mergedTitle != null && mergedTitle.isNotEmpty)
          ? mergedTitle
          : existingBook.title ?? _cleanMetadataString(folderName);
      existingBook.author = author ?? existingBook.author;
      existingBook.album = album ?? existingBook.album;
      existingBook.narrator = narrator ?? existingBook.narrator;
      existingBook.durationSeconds = duration > 0 ? duration : null;
      existingBook.coverPath = coverPath ?? existingBook.coverPath;
      existingBook.audioFiles = audioFiles;
      existingBook.isDirectory = isDirectory;
      existingBook.description = description ?? existingBook.description;
      existingBook.filesMetadata = fileMetaList.isNotEmpty
          ? fileMetaList
          : existingBook.filesMetadata;
      existingBook.internalChapters = internalChapters.isNotEmpty
          ? internalChapters
          : existingBook.internalChapters;
      await saveBook(existingBook);
    } else {
      final book = Book(
        path: path,
        title: title ?? _cleanMetadataString(folderName),
        author: author,
        album: album,
        narrator: narrator,
        durationSeconds: duration > 0 ? duration : null,
        coverPath: coverPath,
        lastPlayed: null, // Don't set lastPlayed until actually played
        audioFiles: audioFiles,
        isDirectory: isDirectory,
        description: description,
        filesMetadata: fileMetaList.isNotEmpty ? fileMetaList : null,
        internalChapters: internalChapters.isNotEmpty ? internalChapters : null,
      );
      await saveBook(book);
    }
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

      final imageHash = md5.convert(picture.data).toString();
      // Determine extension robustly from format string
      final fmt = picture.format.toLowerCase();
      final ext = fmt.contains('png') ? '.png' : '.jpg';
      final coverFile = File(p.join(coversDir.path, '$imageHash$ext'));

      if (!await coverFile.exists()) {
        await coverFile.writeAsBytes(picture.data);
      }

      return coverFile.path;
    } catch (e) {
      logger.e('Error saving cover art', error: e);
      return null;
    }
  }

  /// Attempts to find and save cover art for an existing book that has none.
  /// Called during non-forced rescans to backfill missing covers.
  Future<void> _updateCoverForBook(
    Book book,
    String path,
    List<String>? audioFiles,
  ) async {
    try {
      final isDir = book.isDirectory ?? false;
      final localCover = await _findLocalCoverImage(path, isDirectory: isDir);
      if (localCover != null) {
        book.coverPath = localCover;
        await saveBook(book);
        logger.i('Backfilled local cover for "${book.title}": $localCover');
        return;
      }

      final sourcePath = (audioFiles != null && audioFiles.isNotEmpty)
          ? audioFiles.first
          : path;

      // Run in an isolate: this is file I/O and was blocking the UI thread on
      // every non-forced rescan, unlike every other parseFile call here.
      final metadata = await Isolate.run(
        () => parseFile(
          sourcePath,
          options: const ParseOptions(duration: false, includeChapters: false),
        ),
      );

      final pictures = metadata.common.picture;
      if (pictures == null || pictures.isEmpty) return;

      Picture? cover;
      try {
        cover = selectCover(pictures);
      } catch (e, stack) {
        logger.w(
          'selectCover failed for $sourcePath, using first picture',
          error: e,
          stackTrace: stack,
        );
        cover = pictures.first;
      }
      cover ??= pictures.first;

      final coverPath = await _extractAndCacheCover(cover, sourcePath);
      if (coverPath != null) {
        book.coverPath = coverPath;
        await saveBook(book);
        logger.i('Backfilled cover for "${book.title}": $coverPath');
      }
    } catch (e) {
      logger.w('Could not backfill cover for ${book.path}: $e');
    }
  }

  Future<void> updateProgress(
    String path,
    double positionSeconds, {
    int? trackIndex,
  }) async {
    try {
      // Read-modify-write inside a single transaction. Loading the book outside
      // the txn and then putting it back meant a concurrent write (e.g. the
      // chapter metadata write) could be clobbered by a stale snapshot.
      await _isar.writeTxn(() async {
        final book = await _isar.books.where().pathEqualTo(path).findFirst();
        if (book == null) return;
        book.positionSeconds = positionSeconds;
        book.lastPlayed = DateTime.now();
        if (trackIndex != null) {
          book.lastTrackIndex = trackIndex;
        }
        await _isar.books.put(book);
      });
    } catch (e, stack) {
      logger.e('Update progress failed', error: e, stackTrace: stack);
    }
  }

  Future<void> addBookmark(String path, Bookmark bookmark) async {
    try {
      await _isar.writeTxn(() async {
        final book = await _isar.books.where().pathEqualTo(path).findFirst();
        if (book == null) return;
        book.bookmarks ??= [];
        book.bookmarks!.add(bookmark);
        await _isar.books.put(book);
      });
    } catch (e, stack) {
      logger.e('Error adding bookmark', error: e, stackTrace: stack);
    }
  }

  Future<void> removeBookmark(String path, int index) async {
    try {
      await _isar.writeTxn(() async {
        final book = await _isar.books.where().pathEqualTo(path).findFirst();
        if (book == null) return;
        final bookmarks = book.bookmarks;
        if (bookmarks == null || index < 0 || index >= bookmarks.length) {
          return;
        }
        bookmarks.removeAt(index);
        await _isar.books.put(book);
      });
    } catch (e, stack) {
      logger.e('Error removing bookmark', error: e, stackTrace: stack);
    }
  }

  /// Scans the database and removes entries for books whose audio files or main path no longer exist on disk.
  Future<int> cleanOrphanedBooks() async {
    final books = await getAllBooks();
    final idsToRemove = <int>[];
    final coverPathsToDelete = <String>[];

    for (final book in books) {
      final mainPath = book.path;
      bool exists = false;

      if (mainPath != null) {
        if (await File(mainPath).exists() || await Directory(mainPath).exists()) {
          exists = true;
        }
      }

      if (!exists && book.audioFiles != null && book.audioFiles!.isNotEmpty) {
        for (final file in book.audioFiles!) {
          if (await File(file).exists()) {
            exists = true;
            break;
          }
        }
      }

      if (!exists) {
        idsToRemove.add(book.id);
        if (book.coverPath != null) {
          coverPathsToDelete.add(book.coverPath!);
        }
      }
    }

    if (idsToRemove.isNotEmpty) {
      await _isar.writeTxn(() async {
        await _isar.books.deleteAll(idsToRemove);
      });
      await _deleteCachedCovers(coverPathsToDelete);
      logger.i('Cleaned ${idsToRemove.length} orphaned book(s) from database.');
    }

    return idsToRemove.length;
  }
}

