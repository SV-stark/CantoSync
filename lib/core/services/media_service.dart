import 'dart:async';
import 'dart:convert';
import 'package:media_kit/media_kit.dart';
import 'package:canto_sync/core/services/app_settings_service.dart';
import 'package:canto_sync/core/utils/logger.dart';
import 'package:canto_sync/features/library/data/library_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'media_service.g.dart';

@Riverpod(keepAlive: true)
MediaService mediaService(Ref ref) {
  final service = MediaService(ref);
  ref.onDispose(() => service.dispose());
  return service;
}

class MediaService {
  MediaService(this._ref) {
    _init();
  }
  Player? _player;
  final Ref _ref;
  bool _isFetchingChapters = false;

  Player get _p {
    if (_player == null) {
      _init();
    }
    return _player!;
  }

  void _init() {
    try {
      _player = Player();
      _initFilters();
    } catch (e, stack) {
      _ref.read(isarProvider).writeTxnSync(() {
        // Log to Isar or something if needed, but for now use logger
      });
      logger.e(
        'Error creating Player in MediaService',
        error: e,
        stackTrace: stack,
      );
    }
  }

  // State Streams
  Stream<bool> get playingStream => _p.stream.playing;
  Stream<Duration> get positionStream => _p.stream.position;
  Stream<Duration> get durationStream => _p.stream.duration;
  Stream<double> get volumeStream => _p.stream.volume;
  Stream<Playlist> get playlistStream => _p.stream.playlist;
  Stream<bool> get completedStream => _p.stream.completed;

  void _initFilters() {
    try {
      // Initialize filters from settings
      final settings = _ref.read(appSettingsProvider);
      _skipSilence = settings.skipSilence;
      _loudnessNormalization = settings.loudnessNormalization;
      _activePresetFilter = settings.audioPreset.filter;
      _applyFilters();
    } catch (e, stack) {
      logger.e(
        'Error initializing filters in MediaService',
        error: e,
        stackTrace: stack,
      );
    }
  }

  List<Chapter>? _customChapters;
  List<Chapter>? get customChapters => _customChapters;
  Duration? _customTotalDuration;

  Future<void> open(
    Object mediaSource, {
    String? title,
    String? artist,
    String? album,
    bool autoPlay = true,
    List<Chapter>? chapters,
    Duration? totalDuration,
  }) async {
    _customChapters = chapters;
    _customTotalDuration = totalDuration;
    _totalDurationController.add(totalDuration ?? Duration.zero);

    if (mediaSource is String) {
      await _p.open(Media(mediaSource), play: autoPlay);
    } else if (mediaSource is List<String>) {
      final playlist = Playlist(
        mediaSource.map((path) => Media(path)).toList(),
      );
      await _p.open(playlist, play: autoPlay);
    }

    // Ensure filters are applied to the new media
    await _applyFilters();
  }

  Future<void> play() async {
    await _p.play();
  }

  Future<void> pause() async {
    await _p.pause();
  }

  Future<void> playOrPause() async {
    await _p.playOrPause();
  }

  Future<void> seek(Duration position) async {
    await _p.seek(position);
  }

  Future<void> setVolume(double volume) async {
    // Clamp to reasonable max (200)
    // Note: media_kit volume is 0.0 to 100.0 normally, but can go higher.
    await _p.setVolume(volume);
  }

  Future<void> setSkipSilence(bool enabled) async {
    _skipSilence = enabled;
    await _applyFilters();
  }

  Future<void> setLoudnessNormalization(bool enabled) async {
    _loudnessNormalization = enabled;
    await _applyFilters();
  }

  bool _skipSilence = false;
  bool _loudnessNormalization = false;
  String _activePresetFilter = '';

  Future<void> setAudioFilter(String filter) async {
    _activePresetFilter = filter;
    await _applyFilters();
  }

  Future<void> _applyFilters() async {
    try {
      final platform = _p.platform;
      if (platform is NativePlayer) {
        final List<String> filters = [];

        if (_activePresetFilter.isNotEmpty) {
          filters.add(_activePresetFilter);
        }

        if (_skipSilence) {
          // Robust silence removal: removes silences longer than 0.5s with -50dB threshold
          filters.add(
            'silenceremove=stop_periods=-1:stop_duration=0.5:stop_threshold=-50dB',
          );
        }

        if (_loudnessNormalization) {
          filters.add('loudnorm');
        }

        final filterString = filters.join(',');
        logger.d('Applying audio filters: "$filterString"');

        // We use 'af' property to set audio filters in mpv
        await platform.setProperty('af', filterString);
      }
    } catch (e, stack) {
      logger.e(
        'Error applying filters in MediaService',
        error: e,
        stackTrace: stack,
      );
    }
  }

  Future<void> setRate(double rate) async {
    await _p.setRate(rate);
  }

  Stream<Tracks> get tracksStream => _p.stream.tracks;
  Stream<Track> get trackStream => _p.stream.track;

  // ... (constructor) ...

  // Chapter Navigation
  Future<List<Chapter>> getChapters() async {
    // If we have custom chapters (from multi-file book), return those
    if (_customChapters != null && _customChapters!.isNotEmpty) {
      return _customChapters!;
    }

    if (_isFetchingChapters) return [];
    _isFetchingChapters = true;

    try {
      final platform = _p.platform;
      if (platform is NativePlayer) {
        final native = platform;
        try {
          // Retry logic to handle race conditions where chapters/metadata aren't loaded yet.
          for (int i = 0; i < 15; i++) {
            // Increased retries to ~7.5 seconds
            final countStr = await native.getProperty('chapters');
            final count = int.tryParse(countStr) ?? 0;

            logger.d('Chapter check attempt $i: count = $count');

            if (count > 0) {
              final resultString = await native.getProperty('chapter-list');
              logger.d('Chapter list raw string: $resultString');

              if (resultString.isNotEmpty) {
                final result = jsonDecode(resultString);
                if (result is List && result.isNotEmpty) {
                  final List<Chapter> chapters = [];

                  for (int j = 0; j < result.length; j++) {
                    final e = result[j];
                    if (e is! Map) continue;

                    final startTime = (e['time'] as num?)?.toDouble() ?? 0.0;
                    double? endTime;

                    if (j < result.length - 1) {
                      final next = result[j + 1];
                      if (next is Map) {
                        endTime = (next['time'] as num?)?.toDouble();
                      }
                    } else {
                      final d = _p.state.duration.inMilliseconds / 1000.0;
                      if (d > 0) endTime = d;
                    }

                    chapters.add(
                      Chapter(
                        title: e['title']?.toString() ?? 'Chapter ${j + 1}',
                        startTime: startTime,
                        endTime: endTime,
                      ),
                    );
                  }
                  logger.d('Found ${chapters.length} chapters internally.');
                  return chapters;
                }
              }
            }

            final currentDuration = _p.state.duration.inMilliseconds;
            if (currentDuration > 0 && i > 8) {
              logger.d(
                'Duration loaded but no chapters found after $i attempts. Likely no internal chapters.',
              );
              return [];
            }

            await Future.delayed(const Duration(milliseconds: 500));
          }
        } catch (e, stack) {
          logger.e(
            'Error fetching/parsing chapters',
            error: e,
            stackTrace: stack,
          );
        }
      } else {
        logger.d(
          'Player platform is not NativePlayer, cannot fetch internal chapters via mpv properties.',
        );
      }
    } finally {
      _isFetchingChapters = false;
    }
    return [];
  }

  final StreamController<Duration> _totalDurationController =
      StreamController<Duration>.broadcast();

  /// Returns the total duration of the book.
  /// If it's a multi-file book, this is the sum of all files.
  /// Otherwise, it's the duration of the current file/stream.
  Stream<Duration> get totalDurationStream {
    if (_customTotalDuration != null) {
      return _totalDurationController.stream;
    }
    return _p.stream.duration;
  }

  Future<void> jumpToChapter(int index) async {
    // If custom chapters exist, it means we are in multi-file mode where
    // each chapter corresponds to a playlist item.
    if (_customChapters != null) {
      await _p.jump(index);
      return;
    }

    if (_p.platform is NativePlayer) {
      final native = _p.platform as NativePlayer;
      await native.setProperty('chapter', index.toString());
    }
  }

  Future<void> jump(int index) async {
    await _p.jump(index);
  }

  Future<void> nextChapter() async {
    // If we have a playlist with multiple files (e.g. folder of MP3s),
    // next/prev usually means next file.
    if (_p.state.playlist.medias.length > 1) {
      await _p.next();
      return;
    }

    // Otherwise, for single files (M4B), we want to navigate internal chapters.
    if (_p.platform is NativePlayer) {
      final native = _p.platform as NativePlayer;
      await native.command(['add', 'chapter', '1']);
    } else {
      await _p.next();
    }
  }

  Future<void> previousChapter() async {
    if (_p.state.playlist.medias.length > 1) {
      await _p.previous();
      return;
    }

    if (_p.platform is NativePlayer) {
      final native = _p.platform as NativePlayer;
      await native.command(['add', 'chapter', '-1']);
    } else {
      await _p.previous();
    }
  }

  Duration get position => _p.state.position;
  Duration get duration => _p.state.duration;
  bool get isPlaying => _p.state.playing;
  double get volume => _p.state.volume;
  double get playRate => _p.state.rate;
  int get currentIndex => _p.state.playlist.index;
  Tracks get tracks => _p.state.tracks;
  Track get track => _p.state.track;

  void dispose() {
    _player?.dispose();
    _totalDurationController.close();
  }
}

class Chapter {
  Chapter({required this.title, required this.startTime, this.endTime});
  final String title;
  final double startTime;
  final double? endTime;

  double? get durationSeconds =>
      endTime != null ? (endTime! - startTime) : null;
}
