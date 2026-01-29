import 'dart:async';
import 'dart:io';
import 'package:media_kit/media_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:canto_sync/core/constants/app_constants.dart';
import 'package:canto_sync/core/services/app_settings_service.dart';
import 'book.dart';

final libraryServiceProvider = Provider<LibraryService>((ref) {
  return LibraryService(Hive.box<Book>(AppConstants.libraryBox), ref: ref);
});

class LibrarySearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String query) => state = query;
}

final librarySearchQueryProvider = NotifierProvider<LibrarySearchQuery, String>(
  LibrarySearchQuery.new,
);

class LibraryGroupingMode extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final libraryGroupingModeProvider = NotifierProvider<LibraryGroupingMode, bool>(
  LibraryGroupingMode.new,
);

final libraryBooksProvider = StreamProvider<List<Book>>((ref) {
  final service = ref.watch(libraryServiceProvider);
  final searchQuery = ref.watch(librarySearchQueryProvider).toLowerCase();

  return service.listenToBooks().map((books) {
    if (searchQuery.isEmpty) return books;
    return books.where((book) {
      final title = book.title.toLowerCase();
      final author = book.author?.toLowerCase() ?? '';
      final album = book.album?.toLowerCase() ?? '';
      return title.contains(searchQuery) ||
          author.contains(searchQuery) ||
          album.contains(searchQuery);
    }).toList();
  });
});

final libraryGroupedBooksProvider =
    Provider<AsyncValue<Map<String, List<Book>>>>((ref) {
      final booksAsync = ref.watch(libraryBooksProvider);

      return booksAsync.whenData((books) {
        final Map<String, List<Book>> groups = {};
        for (final book in books) {
          final key = book.series ?? 'Standalone';
          groups.putIfAbsent(key, () => []).add(book);
        }
        return groups;
      });
    });

class LibraryService {
  final Box<Book> _box;
  final Ref? ref;

  LibraryService(this._box, {this.ref});

  List<Book> get books => _box.values.toList();

  Stream<List<Book>> listenToBooks() {
    return _box
        .watch()
        .map((event) => _box.values.toList())
        .startWith(_box.values.toList());
  }

  Future<void> rescanLibraries() async {
    if (ref == null) return;

    final settings = ref!.read(appSettingsProvider);
    final libraryPaths = settings.libraryPaths;

    // Create shared player for metadata extraction
    final probePlayer = Player(
      configuration: const PlayerConfiguration(vo: 'null'),
    );

    final Set<String> allFoundBookPaths = {};

    try {
      for (final path in libraryPaths) {
        final found = await _scanDirectory(path, probePlayer);
        allFoundBookPaths.addAll(found);
      }

      // Prune books that are no longer in the libraries
      final booksToRemove = <dynamic>[];

      for (final book in _box.values) {
        // Check if book is within any of the managed library paths
        bool isManaged = false;
        for (final libPath in libraryPaths) {
          if (p.isWithin(libPath, book.path) || p.equals(libPath, book.path)) {
            isManaged = true;
            break;
          }
        }

        if (isManaged) {
          if (!allFoundBookPaths.contains(book.path)) {
            // Book is in a managed folder but was not found in scan -> deleted
            booksToRemove.add(book.key);
          }
        }
      }

      await _box.deleteAll(booksToRemove);
    } finally {
      await probePlayer.dispose();
    }
  }

  // Wrapper for backward compatibility if called directly, but preferred to use rescanLibraries
  Future<void> scanDirectory(String path) async {
    final probePlayer = Player(
      configuration: const PlayerConfiguration(vo: 'null'),
    );
    try {
      await _scanDirectory(path, probePlayer);
    } finally {
      await probePlayer.dispose();
    }
  }

  Future<List<String>> _scanDirectory(String path, Player probePlayer) async {
    final dir = Directory(path);
    if (!await dir.exists()) return [];

    final List<FileSystemEntity> entities = await dir
        .list(recursive: true, followLinks: false)
        .toList();

    final audioExtensions = {'.mp3', '.m4b', '.m4a', '.flac', '.ogg', '.wav'};

    // Group files by parent directory
    final Map<String, List<File>> dirBasedGroups = {};

    for (final entity in entities) {
      if (entity is File) {
        final ext = p.extension(entity.path).toLowerCase();
        if (audioExtensions.contains(ext)) {
          final parent = p.dirname(entity.path);
          dirBasedGroups.putIfAbsent(parent, () => []).add(entity);
        }
      }
    }

    final List<String> foundBookPaths = [];

    for (final entry in dirBasedGroups.entries) {
      final parentPath = entry.key;
      final files = entry.value;

      files.sort((a, b) => a.path.compareTo(b.path));

      if (files.length == 1 &&
          files.first.parent.path == dir.path &&
          files.length == 1) {
        final filePaths = files.map((f) => f.path).toList();
        await _addBookIfNotExists(
          parentPath,
          isDirectory: true,
          audioFiles: filePaths,
          probePlayer: probePlayer,
        );
        foundBookPaths.add(parentPath);
      } else {
        final filePaths = files.map((f) => f.path).toList();
        await _addBookIfNotExists(
          parentPath,
          isDirectory: true,
          audioFiles: filePaths,
          probePlayer: probePlayer,
        );
        foundBookPaths.add(parentPath);
      }
    }
    return foundBookPaths;
  }

  Future<void> _addBookIfNotExists(
    String path, {
    required bool isDirectory,
    List<String>? audioFiles,
    required Player probePlayer,
  }) async {
    // Check if already in DB
    final exists = _box.values.any((b) => b.path == path);
    if (exists) return;

    String? title;
    String? author;
    String? album;
    String? coverPath;
    String? description;
    double duration = 0;

    // Use the first file to extract metadata
    final metadataSourcePath = (audioFiles != null && audioFiles.isNotEmpty)
        ? audioFiles.first
        : path;

    try {
      final metadata = await MetadataGod.readMetadata(file: metadataSourcePath);
      title = metadata.title;
      author = metadata.artist;
      album = metadata.album;

      if (metadata.picture != null) {
        coverPath = await _extractAndCacheCover(
          metadata.picture!,
          metadataSourcePath,
        );
      }

      // Extract description using the shared media_kit player
      // We pass the already created player to avoid overhead
      description = await _extractDescription(metadataSourcePath, probePlayer);

      // Calculate total duration
      if (audioFiles != null) {
        for (final filePath in audioFiles) {
          try {
            final fileMeta = await MetadataGod.readMetadata(file: filePath);
            if (fileMeta.durationMs != null) {
              duration += fileMeta.durationMs! / 1000.0;
            }
          } catch (_) {}
        }
      } else {
        if (metadata.durationMs != null) {
          duration = metadata.durationMs! / 1000.0;
        }
      }
    } catch (e) {
      debugPrint('Error reading metadata for $path: $e');
    }

    // Fallback title to folder name
    final folderName = p.basename(path);

    final book = Book(
      path: path,
      title: title ?? folderName,
      author: author,
      album: album,
      durationSeconds: duration > 0 ? duration : null,
      coverPath: coverPath,
      lastPlayed: DateTime.now(),
      audioFiles: audioFiles,
      isDirectory: isDirectory,
      description: description,
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

  Future<void> updateProgress(
    String path,
    double positionSeconds, {
    int? trackIndex,
  }) async {
    try {
      final book = _box.values.firstWhere((b) => b.path == path);
      book.positionSeconds = positionSeconds;
      book.lastPlayed = DateTime.now();
      if (trackIndex != null) {
        book.lastTrackIndex = trackIndex;
      }
      await book.save();
    } catch (e) {
      // Book not found in library, ignore
    }
  }

  Future<void> addBookmark(String path, Bookmark bookmark) async {
    try {
      final book = _box.values.firstWhere((b) => b.path == path);
      book.bookmarks ??= [];
      book.bookmarks!.add(bookmark);
      await book.save();
    } catch (e) {
      debugPrint('Error adding bookmark: $e');
    }
  }

  Future<void> removeBookmark(String path, int index) async {
    try {
      final book = _box.values.firstWhere((b) => b.path == path);
      if (book.bookmarks != null && index < book.bookmarks!.length) {
        book.bookmarks!.removeAt(index);
        await book.save();
      }
    } catch (e) {
      debugPrint('Error removing bookmark: $e');
    }
  }

  Future<String?> _extractDescription(String path, Player player) async {
    try {
      await player.open(Media(path), play: false);

      // Wait for metadata to be populated.
      // MediaKit doesn't have a direct "awaitUntilMetadataLoaded" but probing is usually fast.
      // We can check if metadata is already present or wait a tiny bit?
      // Actually, opening a file triggers metadata loading.
      // Let's retry a few times to get 'comment' or 'description'.

      // We don't want to block for too long.
      // We wait up to 5 seconds (100 * 50ms) to be safe for slow drives/heavy files.
      for (int i = 0; i < 100; i++) {
        // Safe check for native platform
        if (player.platform is NativePlayer) {
          final native = player.platform as NativePlayer;

          // Try specific common keys
          final comment = await native.getProperty('metadata/by-key/comment');
          if (comment.isNotEmpty) return comment;

          // User requested explicit check for uppercase 'COMMENT' which some taggers use
          final commentUpper = await native.getProperty('metadata/COMMENT');
          if (commentUpper.isNotEmpty) return commentUpper;

          final desc = await native.getProperty('metadata/by-key/description');
          if (desc.isNotEmpty) return desc;

          final synopsis = await native.getProperty('metadata/by-key/synopsis');
          if (synopsis.isNotEmpty) return synopsis;
        }
        await Future.delayed(const Duration(milliseconds: 50));
      }
    } catch (e) {
      debugPrint('Error extracting description with media_kit: $e');
    }
    return null;
  }
}

extension StreamStartWith<T> on Stream<T> {
  Stream<T> startWith(T value) async* {
    yield value;
    yield* this;
  }
}
