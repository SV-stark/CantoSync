import 'dart:async';
import 'package:metadata_audio/metadata_audio.dart' hide Chapter;
import 'package:path/path.dart' as p;
import 'package:canto_sync/core/services/media_service.dart';
import 'package:canto_sync/core/utils/logger.dart';
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
  StreamSubscription? _chaptersSubscription;
  String? _currentPath;
  Timer? _debounceTimer;
  Timer? _statsTimer;
  double _lastPosition = 0;
  int _lastTrackIndex = 0;
  bool _pendingSave = false;
  Book? _currentBook;
  int _sessionSeconds = 0;

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

    // Stats sampling timer: ticks every 10s, records every 30s of playback
    _statsTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_currentPath != null && _mediaService.isPlaying) {
        _sessionSeconds += 10;
        if (_sessionSeconds >= 30) {
          unawaited(_recordStatsSession(_sessionSeconds));
          _sessionSeconds = 0;
        }
      }
    });

    _completedSubscription = _mediaService.completedStream.listen((completed) {
      if (completed) {
        final playlistLength = _currentBook?.audioFiles?.length ?? 1;
        final currentIndex = _mediaService.currentIndex;
        if (playlistLength <= 1 || currentIndex >= playlistLength - 1) {
          unawaited(onPlaybackCompleted());
        }
      }
    });

    _chaptersSubscription = _mediaService.chaptersStream.listen((chapters) {
      if (_currentBook != null &&
          chapters.isNotEmpty &&
          (_currentBook!.audioFiles == null ||
              _currentBook!.audioFiles!.length <= 1) &&
          (_currentBook!.internalChapters == null ||
              _currentBook!.internalChapters!.isEmpty)) {
        final updatedChapters = chapters
            .map(
              (c) => ChapterMetadata(
                title: c.title,
                startTime: c.startTime,
                endTime: c.endTime,
              ),
            )
            .toList();

        _currentBook!.internalChapters = updatedChapters;
        _libraryService
            .saveBook(_currentBook!)
            .then((_) {
              logger.i(
                'Saved ${chapters.length} chapters from mpv to DB for book: ${_currentBook!.title}',
              );
            })
            .catchError((e) {
              logger.e('Error updating book chapters from mpv stream', error: e);
            });
      }
    });
  }

  void setCurrentPath(String? path) {
    _currentPath = path;
    _ref.read(currentBookPathProvider.notifier).update(path);
  }

  Future<void> _recordStatsSession(int seconds) async {
    if (_currentBook == null) return;

    try {
      final statsService = _ref.read(listeningStatsServiceProvider);
      final speed = _mediaService.playRate;
      await statsService.recordListeningTime(
        _currentBook!,
        seconds,
        playbackSpeed: speed,
      );
    } catch (e, stack) {
      logger.e('Error recording stats', error: e, stackTrace: stack);
    }
  }

  /// Marks current book as completed in stats
  Future<void> onPlaybackCompleted() async {
    if (_currentBook == null) return;

    try {
      final statsService = _ref.read(listeningStatsServiceProvider);
      await statsService.markBookAsCompleted(_currentBook!);
    } catch (e, stack) {
      logger.e('Error marking book as completed', error: e, stackTrace: stack);
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

    final book = await _libraryService.getBookByPath(path);
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
                if (meta.common.title != null &&
                    meta.common.title!.isNotEmpty) {
                  fileTitle = meta.common.title!;
                }
                if (meta.format.duration != null) {
                  fileDuration = meta.format.duration!;
                }
              } catch (e, stack) {
                logger.w(
                  'Error reading metadata for file',
                  error: e,
                  stackTrace: stack,
                );
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

          final metadataList = bookObj?.filesMetadata ??
              fileDataList
                  .map(
                    (d) => FileMetadata(
                      title: d['title'] as String?,
                      duration: d['duration'] as double?,
                      path: d['path'] as String?,
                    ),
                  )
                  .toList();
          final (builtChapters, builtTotalDuration) =
              buildMultiFileChapters(metadataList);
          chapters.addAll(builtChapters);
          totalDurationSeconds += builtTotalDuration;
        } catch (e, stack) {
          logger.e(
            'Error processing multi-file book chapters',
            error: e,
            stackTrace: stack,
          );
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
          } catch (e, stack) {
            logger.e(
              'Error seeking multi-file book during resume',
              error: e,
              stackTrace: stack,
            );
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
      chapters:
          (book?.internalChapters != null && book!.internalChapters!.isNotEmpty)
          ? book.internalChapters!
                .map(
                  (c) => Chapter(
                    title: c.title ?? '',
                    startTime: c.startTime ?? 0,
                    endTime: c.endTime,
                  ),
                )
                .toList()
          : null,
    );

    if (lastPosition != null && lastPosition > 0.1) {
      await Future.delayed(const Duration(milliseconds: 500));
      try {
        await _mediaService.seek(
          Duration(milliseconds: (lastPosition * 1000).toInt()),
        );
      } catch (e, stack) {
        logger.e('Error seeking during resume', error: e, stackTrace: stack);
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
    _chaptersSubscription?.cancel();
    _debounceTimer?.cancel();
    _statsTimer?.cancel();

    // Record any pending stats time
    if (_sessionSeconds > 0) {
      unawaited(_recordStatsSession(_sessionSeconds));
    }

    if (_pendingSave && _currentPath != null) {
      // Best effort save on dispose
      unawaited(
        _libraryService.updateProgress(
          _currentPath!,
          _lastPosition,
          trackIndex: _lastTrackIndex,
        ),
      );
    }
  }
}

(List<Chapter> chapters, double totalDuration) buildMultiFileChapters(
  List<FileMetadata> files,
) {
  final List<Chapter> chapters = [];
  double totalDuration = 0;
  double currentStartTime = 0;

  for (var i = 0; i < files.length; i++) {
    final file = files[i];
    final duration = file.duration;
    final title = (file.title != null && file.title!.isNotEmpty)
        ? file.title!
        : 'Track ${i + 1}';

    if (duration != null) {
      chapters.add(
        Chapter(
          title: title,
          startTime: currentStartTime,
          endTime: currentStartTime + duration,
        ),
      );
      currentStartTime += duration;
      totalDuration += duration;
    } else {
      chapters.add(Chapter(title: title, startTime: currentStartTime));
    }
  }

  return (chapters, totalDuration);
}
