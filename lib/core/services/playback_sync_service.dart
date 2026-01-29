import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:path/path.dart' as p;
import 'package:canto_sync/core/services/media_service.dart';
import 'package:canto_sync/features/library/data/library_service.dart';

final playbackSyncProvider = Provider<PlaybackSyncService>((ref) {
  final mediaService = ref.watch(mediaServiceProvider);
  final libraryService = ref.watch(libraryServiceProvider);
  return PlaybackSyncService(mediaService, libraryService, ref);
});

final currentBookPathProvider =
    NotifierProvider<CurrentBookPathNotifier, String?>(() {
      return CurrentBookPathNotifier();
    });

class CurrentBookPathNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  @override
  set state(String? value) => super.state = value;
}

class PlaybackSyncService {
  final MediaService _mediaService;
  final LibraryService _libraryService;
  final Ref _ref;
  StreamSubscription? _subscription;
  String? _currentPath;
  Timer? _debounceTimer;
  double _lastPosition = 0;
  int _lastTrackIndex = 0;
  bool _pendingSave = false;

  PlaybackSyncService(this._mediaService, this._libraryService, this._ref) {
    _init();
  }

  void _init() {
    _subscription = _mediaService.positionStream.listen((position) {
      if (_currentPath != null && _mediaService.isPlaying) {
        _debounceSave(
          _currentPath!,
          position.inMilliseconds / 1000.0,
          _mediaService.currentIndex,
        );
      }
    });

    // Also listen to media open to update _currentPath
    // MediaKit doesn't give "current file path" stream easily directly from Player.stream.playlist
    // But we can store it when we call open().
    // For now, let's rely on the fact that we call open() via a provider or we can just not handle it here yet?
    // Better: Helper method in this service to open file, ensuring we track it.
  }

  void setCurrentBook(String path) {
    _currentPath = path;
    _ref.read(currentBookPathProvider.notifier).state = path;
  }

  Future<void> resumeBook(String path) async {
    _currentPath = path;
    _ref.read(currentBookPathProvider.notifier).state = path;

    // Find book to get last position and metadata
    String? title;
    String? author;
    String? album;
    double? lastPosition;
    List<String>? audioFiles;
    bool isDirectory = false;
    int? lastTrackIndex;

    try {
      final books = _libraryService.books;
      final book = books.firstWhere((b) => b.path == path);
      title = book.title;
      author = book.author;
      album = book.album;
      lastPosition = book.positionSeconds;
      audioFiles = book.audioFiles;
      isDirectory = book.isDirectory;
      lastTrackIndex = book.lastTrackIndex;
    } catch (_) {}

    if (isDirectory && audioFiles != null && audioFiles.isNotEmpty) {
      // For multi-file books, we want to construct a "Virtual Timeline".
      // We process files to get their titles and durations.

      final List<Chapter> chapters = [];
      double totalDurationSeconds = 0;

      // We process sequentially or parallel? Parallel is faster.
      // But we need strict order.
      // Let's do a map and wait.
      try {
        // Create futures list
        final futures = audioFiles.map((filePath) async {
          String fileTitle = p.basename(filePath);
          double? fileDuration;

          try {
            // We can optimize this by caching chapter data in the Book object if possible,
            // but for now, we read on open (might be slightly slow for huge books).
            // TODO: Optimize by caching in library.
            final meta = await MetadataGod.readMetadata(file: filePath);
            if (meta.title != null && meta.title!.isNotEmpty) {
              fileTitle = meta.title!;
            }
            if (meta.durationMs != null) {
              fileDuration = meta.durationMs! / 1000.0;
            }
          } catch (e) {
            // Ignore metadata errors, rely on basename
          }
          return {
            'title': fileTitle,
            'duration': fileDuration,
            'path': filePath,
          };
        }).toList();

        final results = await Future.wait(futures);

        // now build chapters securely in order
        double currentStartTime = 0;
        for (var i = 0; i < results.length; i++) {
          final data = results[i];
          final duration = data['duration'] as double?;
          final title = data['title'] as String;

          // If duration is null (metadata failed), we unfortunately can't know the end time accurately
          // without opening the file.
          // For the timeline to work, we kind of need it.
          // If mostly missing, this feature won't work well.
          // We'll skip adding accurate chapters if duration missing but we'll try our best.

          // If we have duration, we add a chapter.
          if (duration != null) {
            chapters.add(
              Chapter(
                title: title,
                startTime:
                    currentStartTime, // This start time is actually mostly for display "what index corresponds to what time"
                // But wait, the user requested "Progress bar should show progress in current chapter".
                // So the startTime here doesn't map to the player position (which resets to 0 for each file).
                // It strictly maps to the "Total Duration" timeline.
                endTime: currentStartTime + duration,
              ),
            );
            currentStartTime += duration;
            totalDurationSeconds += duration;
          } else {
            // Fallback: Just add a chapter marker with 0 duration or skip?
            // Let's just use the filename as title and move on.
            // We won't be able to calculate total duration correctly.
            chapters.add(Chapter(title: title, startTime: currentStartTime));
          }
        }
      } catch (e) {
        // If something fails, we just proceed without custom chapters
      }

      await _mediaService.open(
        audioFiles,
        title: title,
        artist: author,
        album: album,
        chapters: chapters,
        totalDuration: totalDurationSeconds > 0
            ? Duration(milliseconds: (totalDurationSeconds * 1000).toInt())
            : null,
      );

      // Restore track index
      if (lastTrackIndex != null &&
          lastTrackIndex >= 0 &&
          lastTrackIndex < audioFiles.length) {
        await _mediaService.jump(lastTrackIndex);
      }
    } else {
      await _mediaService.open(
        path,
        title: title,
        artist: author,
        album: album,
      );
    }

    if (lastPosition != null && lastPosition > 0) {
      await _mediaService.seek(
        Duration(milliseconds: (lastPosition * 1000).toInt()),
      );
    }

    // Resume playback is handled by autoPlay: true in open by default now, or explicit play
    // Check if open already plays. My modified open has autoPlay=true default.
    // So we don't strictly need _mediaService.play() providing we ensure open handles it.
    // But let's verify MediaService implementation.
    // Modified open uses `play: autoPlay`.
    // So we can remove explicit play if we want, or keep it safe.
  }

  void _debounceSave(String path, double seconds, int trackIndex) {
    _lastPosition = seconds;
    _lastTrackIndex = trackIndex;
    _pendingSave = true;

    if (_debounceTimer?.isActive ?? false) return;

    _debounceTimer = Timer(const Duration(seconds: 2), () {
      _performSave();
    });
  }

  Future<void> _performSave() async {
    if (_currentPath != null) {
      _pendingSave = false;
      await _libraryService.updateProgress(
        _currentPath!,
        _lastPosition,
        trackIndex: _lastTrackIndex,
      );
    }
  }

  void dispose() {
    _subscription?.cancel();
    _debounceTimer?.cancel();
    if (_pendingSave && _currentPath != null) {
      // Best effort save on dispose
      _libraryService.updateProgress(
        _currentPath!,
        _lastPosition,
        trackIndex: _lastTrackIndex,
      );
    }
  }
}
