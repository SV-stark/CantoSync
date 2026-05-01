import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:metadata_audio/metadata_audio.dart' hide Chapter;
import 'package:path/path.dart' as p;
import 'package:canto_sync/core/services/media_service.dart';
import 'package:canto_sync/features/library/data/library_service.dart';
import 'package:canto_sync/features/library/data/book.dart';
import 'package:canto_sync/features/stats/data/stats_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'playback_sync_service.g.dart';

@Riverpod(keepAlive: true)
PlaybackSyncService playbackSync(Ref ref) {
  final mediaService = ref.watch(mediaServiceProvider);
  final libraryService = ref.watch(libraryServiceProvider);
  final service = PlaybackSyncService(mediaService, libraryService, ref);
  ref.onDispose(() => service.dispose());
  return service;
}

@riverpod
class CurrentBookPath extends _$CurrentBookPath {
  @override
  String? build() => null;

  void update(String? value) => state = value;
}

class PlaybackSyncService {

  PlaybackSyncService(this._mediaService, this._libraryService, this._ref) {
    _init();
  }
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
        // Fix: Use milliseconds to avoid losing fractional seconds during calculation
        final delta = position - lastPosition;
        if (delta.inMilliseconds > 0 && delta.inMilliseconds < 10000) {
          // Add delta to session, capping at 10s to avoid jump-related spikes
          _sessionSeconds += delta.inMilliseconds;
          // Batch stats recording every 30 seconds
          if (_sessionSeconds >= 30000) {
            _recordStatsSession(_sessionSeconds ~/ 1000);
            _sessionSeconds = 0;
          }
        }
        lastPosition = position;
      }
    });

    _completedSubscription = _mediaService.completedStream.listen((completed) {
      if (completed) {
        onPlaybackCompleted();
      }
    });
  }

  void setCurrentBook(String path) {
    _currentPath = path;
    _ref.read(currentBookPathProvider.notifier).update(path);
  }

  void _recordStatsSession(int seconds) async {
    if (_currentBook == null) return;

    try {
      final statsService = _ref.read(listeningStatsServiceProvider);
      final speed = _mediaService.playRate;
      await statsService.recordListeningTime(
        _currentBook!,
        seconds,
        playbackSpeed: speed,
      );
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
    _ref.read(currentBookPathProvider.notifier).update(path);

    // Find book to get last position and metadata
    String? title;
    String? author;
    String? album;
    double? lastPosition;
    List<String>? audioFiles;
    bool isDirectory = false;
    int? lastTrackIndex;

    final books = await _libraryService.getAllBooks();
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
      isDirectory = book.isDirectory ?? false;
      lastTrackIndex = book.lastTrackIndex;
    }

    if (isDirectory && audioFiles != null && audioFiles.isNotEmpty) {
      if (audioFiles.length > 1) {
        final List<Chapter> chapters = [];
        double totalDurationSeconds = 0;
        List<Map<String, dynamic>> fileDataList = [];

        Book? bookObj = _currentBook;

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
            final futures = audioFiles.map((filePath) async {
              String fileTitle = p.basename(filePath);
              double? fileDuration;

              try {
                final meta = await parseFile(
                  filePath,
                  options: const ParseOptions(duration: true),
                );
                if (meta.common.title != null && meta.common.title!.isNotEmpty) {
                  fileTitle = meta.common.title!;
                }
                if (meta.format.duration != null) {
                  fileDuration = meta.format.duration!;
                }
              } catch (e) {
                debugPrint('Error reading metadata for file: $e');
              }
              return {
                'title': fileTitle,
                'duration': fileDuration,
                'path': filePath,
              };
            }).toList();

            fileDataList = await Future.wait(futures);

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
              await _libraryService.saveBook(bookObj);
            }
          }

          double currentStartTime = 0;
          for (var i = 0; i < fileDataList.length; i++) {
            final data = fileDataList[i];
            final duration = data['duration'] as double?;
            final title = data['title'] as String;

            if (duration != null) {
              chapters.add(
                Chapter(
                  title: title,
                  startTime: currentStartTime,
                  endTime: currentStartTime + duration,
                ),
              );
              currentStartTime += duration;
              totalDurationSeconds += duration;
            } else {
              chapters.add(Chapter(title: title, startTime: currentStartTime));
            }
          }
        } catch (e) {
          debugPrint('Error processing multi-file book chapters: $e');
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

        if (lastTrackIndex != null &&
            lastTrackIndex >= 0 &&
            lastTrackIndex < audioFiles.length) {
          await _mediaService.jump(lastTrackIndex);
        }

        // Fix: Also seek to last position within the track for multi-file books
        if (lastPosition != null && lastPosition > 0.1) {
          await Future.delayed(const Duration(milliseconds: 500));
          try {
            await _mediaService.seek(
              Duration(milliseconds: (lastPosition * 1000).toInt()),
            );
          } catch (e) {
            debugPrint('Error seeking multi-file book during resume: $e');
          }
        }
        return; 
      }
    }

    await _mediaService.open(
      (audioFiles != null && audioFiles.isNotEmpty) ? audioFiles.first : path,
      title: title,
      artist: author,
      album: album,
      chapters: book?.internalChapters
          ?.map((c) => Chapter(
                title: c.title ?? '',
                startTime: c.startTime ?? 0,
                endTime: c.endTime,
              ))
          .toList(),
    );

    if (lastPosition != null && lastPosition > 0.1) {
      await Future.delayed(const Duration(milliseconds: 500));
      try {
        await _mediaService.seek(
          Duration(milliseconds: (lastPosition * 1000).toInt()),
        );
      } catch (e) {
        debugPrint('Error seeking during resume: $e');
      }
    }
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
