import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:path/path.dart' as p;
import 'package:canto_sync/core/services/media_service.dart';
import 'package:canto_sync/features/library/data/library_service.dart';
import 'package:canto_sync/features/library/data/book.dart';
import 'package:canto_sync/features/stats/data/stats_service.dart';

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
  StreamSubscription? _completedSubscription;
  String? _currentPath;
  Timer? _debounceTimer;
  double _lastPosition = 0;
  int _lastTrackIndex = 0;
  bool _pendingSave = false;
  Book? _currentBook;
  int _sessionSeconds = 0;
  Timer? _statsTimer;

  PlaybackSyncService(this._mediaService, this._libraryService, this._ref) {
    _init();
  }

  void _init() {
    Duration lastPosition = Duration.zero;
    
    _subscription = _mediaService.positionStream.listen((position) {
      if (_currentPath != null && _mediaService.isPlaying) {
        _debounceSave(
          _currentPath!,
          position.inMilliseconds / 1000.0,
          _mediaService.currentIndex,
        );
        
        // Track stats - calculate time delta
        if (position > lastPosition) {
          final deltaSeconds = (position - lastPosition).inSeconds;
          if (deltaSeconds > 0 && deltaSeconds < 60) {
            _sessionSeconds += deltaSeconds;
            // Batch stats recording every 30 seconds
            if (_sessionSeconds >= 30) {
              _recordStatsSession(_sessionSeconds);
              _sessionSeconds = 0;
            }
          }
        }
        lastPosition = position;
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

  void _recordStatsSession(int seconds) async {
    if (_currentBook == null) return;
    
    try {
      final statsService = _ref.read(listeningStatsServiceProvider);
      // Get current playback speed from media service
      final speed = 1.0; // Default speed since we don't track speed changes yet
      await statsService.recordListeningTime(_currentBook!, seconds, playbackSpeed: speed);
    } catch (e) {
      debugPrint('Error recording stats: $e');
    }
  }

  /// Marks current book as completed in stats
  void onPlaybackCompleted() async {
    if (_currentBook == null) return;
    
    try {
      final statsService = _ref.read(listeningStatsServiceProvider);
      await statsService.markBookAsCompleted(_currentBook!);
    } catch (e) {
      debugPrint('Error marking book as completed: $e');
    }
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

    final books = _libraryService.books;
    final book = books.cast<Book?>().firstWhere(
      (b) => b?.path == path,
      orElse: () => null,
    );
    if (book != null) {
      _currentBook = book;
      title = book.title;
      author = book.author;
      album = book.album;
      lastPosition = book.positionSeconds;
      audioFiles = book.audioFiles;
      isDirectory = book.isDirectory;
      lastTrackIndex = book.lastTrackIndex;
    }

    if (isDirectory && audioFiles != null && audioFiles.isNotEmpty) {
      // FIX: Only treat as "Multi-File Book" if there is actually more than one file.
      // If there is only 1 file (e.g. an M4B in its own folder), we treat it as a single file
      // so that MediaService/MPV can parse its INTERNAL chapters.
      if (audioFiles.length > 1) {
        // For multi-file books, we want to construct a "Virtual Timeline".
        // We process files to get their titles and durations.

        final List<Chapter> chapters = [];
        double totalDurationSeconds = 0;
        List<Map<String, dynamic>> fileDataList = [];

        Book? bookObj;
        try {
          bookObj = _libraryService.books.firstWhere((b) => b.path == path);
        } catch (_) {}

        try {
          if (bookObj?.filesMetadata != null &&
              bookObj!.filesMetadata!.length == audioFiles.length) {
            fileDataList = bookObj.filesMetadata!
                .map(
                  (m) => {
                    'title': m.title,
                    'duration': m.duration,
                    'path': m.path,
                  },
                )
                .toList();
          } else {
            // Create futures list
            final futures = audioFiles.map((filePath) async {
              String fileTitle = p.basename(filePath);
              double? fileDuration;

              try {
                // We can optimize this by caching chapter data in the Book object if possible,
                // but for now, we read on open (might be slightly slow for huge books).
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

            fileDataList = await Future.wait(futures);

            // Cache the results
            if (bookObj != null) {
              bookObj.filesMetadata = fileDataList
                  .map(
                    (d) => FileMetadata(
                      title: d['title'] as String,
                      duration: d['duration'] as double?,
                      path: d['path'] as String,
                    ),
                  )
                  .toList();
              await bookObj.save();
            }
          }

          // now build chapters securely in order
          double currentStartTime = 0;
          for (var i = 0; i < fileDataList.length; i++) {
            final data = fileDataList[i];
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
        return; // EXIT here for multi-file case
      }
      // If only 1 file, treat as normal file below...
    }

    // Default / Single-file behavior
    await _mediaService.open(
      // Use the single file from the list if available, otherwise path
      (audioFiles != null && audioFiles.isNotEmpty) ? audioFiles.first : path,
      title: title,
      artist: author,
      album: album,
    );

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

  /// Forces a save immediately. Used during app shutdown.
  Future<void> forceSave() async {
    _debounceTimer?.cancel();
    await _performSave();
  }

  void dispose() {
    _subscription?.cancel();
    _completedSubscription?.cancel();
    _debounceTimer?.cancel();
    _statsTimer?.cancel();
    
    // Record any pending stats time
    if (_sessionSeconds > 0) {
      _recordStatsSession(_sessionSeconds);
    }
    
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
