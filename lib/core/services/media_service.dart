import 'dart:async';
import 'dart:convert';
import 'package:media_kit/media_kit.dart';
import 'package:canto_sync/core/services/app_settings_service.dart';
import 'package:canto_sync/core/utils/logger.dart';
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
  bool _initFailed = false;

  /// In-flight mpv chapter read, de-duplicated by [getChapters].
  Future<List<Chapter>>? _chapterFetchFuture;

  /// True once the player failed to construct so the UI can surface an error
  /// instead of silently showing an inert player forever.
  bool get isInitialised => _player != null && !_initFailed;

  Player get _p {
    if (_initFailed) {
      throw StateError('MediaKit Player failed to initialize');
    }
    if (_player == null) {
      _init();
    }
    return _player!;
  }

  StreamSubscription<Duration>? _playerDurationSubscription;
  int _chapterFetchGeneration = 0;

  void _init() {
    // Guard against re-entry: the _p getter re-invokes _init() whenever the
    // player is null, which previously leaked a native handle on each call
    // because the old instance was overwritten without being disposed.
    if (_player != null || _initialising) return;
    _initialising = true;
    try {
      final player = Player();
      _playerDurationSubscription?.cancel();
      _playerDurationSubscription = player.stream.duration.listen((d) {
        if (_customTotalDuration == null) {
          _totalDurationController.add(d);
        }
      });
      _player = player;
      _initFilters();
      _initFailed = false;
    } catch (e, stack) {
      _initFailed = true;
      logger.e(
        'Error creating Player in MediaService',
        error: e,
        stackTrace: stack,
      );
    } finally {
      _initialising = false;
    }
  }

  bool _initialising = false;

  // State Streams
  Stream<bool> get playingStream =>
      _player != null ? _p.stream.playing : Stream.value(false);
  Stream<Duration> get positionStream =>
      _player != null ? _p.stream.position : Stream.value(Duration.zero);
  Stream<Duration> get durationStream =>
      _player != null ? _p.stream.duration : Stream.value(Duration.zero);
  Stream<double> get volumeStream =>
      _player != null ? _p.stream.volume : Stream.value(100.0);
  Stream<Playlist> get playlistStream =>
      _player != null ? _p.stream.playlist : Stream.value(const Playlist([]));
  Stream<bool> get completedStream =>
      _player != null ? _p.stream.completed : Stream.value(false);

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

  /// Total duration override for multi-file books. Reset to null on every
  /// open() so the previous book's total never leaks into the next one.
  Duration? _customTotalDuration;

  /// Set by the player so the UI can tell folder-books from single files
  /// reliably, instead of inferring it from a possibly-stale duration delta.
  bool _isPlaylistOpen = false;
  bool get isPlaylistOpen => _isPlaylistOpen;

  final StreamController<List<Chapter>> _chaptersController =
      StreamController<List<Chapter>>.broadcast();
  Stream<List<Chapter>> get chaptersStream => _chaptersController.stream;

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
    final generation = ++_chapterFetchGeneration;
    _isPlaylistOpen = mediaSource is List<String> && mediaSource.length > 1;

    if (totalDuration != null) {
      _totalDurationController.add(totalDuration);
    } else {
      // Clear the previous book's total immediately. Leaving it in place made
      // the next book briefly look "multi-file" and corrupted the seek maths.
      _totalDurationController.add(Duration.zero);
    }

    if (chapters != null) {
      _chaptersController.add(chapters);
    } else {
      _chaptersController.add([]);
      unawaited(
        getChapters(generation: generation).then((c) {
          // Only publish if this is still the book we were asked about, and
          // only if we actually found chapters -- an empty result from a
          // superseded fetch must not wipe a good chapter list.
          if (generation == _chapterFetchGeneration && c.isNotEmpty) {
            _chaptersController.add(c);
          }
        }),
      );
    }

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

  /// Seeks to [position], clamped into the media's valid range.
  ///
  /// A negative [position] is invalid for mpv and used to throw when the
  /// skip-backward shortcut fired within the first 15 seconds of a track.
  Future<void> seek(Duration position) async {
    var target = position;
    if (target.isNegative) target = Duration.zero;
    final total = _player?.state.duration ?? Duration.zero;
    if (total > Duration.zero && target > total) target = total;
    await _p.seek(target);
  }

  Future<void> setVolume(double volume) async {
    // media_kit accepts 0-100 (values above 100 are possible but would
    // desync every volume Slider, which is bounded to 100).
    await _p.setVolume(volume.clamp(0.0, 100.0));
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

  Stream<Tracks> get tracksStream =>
      _player != null ? _p.stream.tracks : Stream.value(const Tracks());
  Stream<Track> get trackStream =>
      _player != null ? _p.stream.track : Stream.value(const Track());

  // ... (constructor) ...

  // Chapter Navigation
  Future<List<Chapter>> getChapters({int? generation}) async {
    // If we have custom chapters (from multi-file book), return those
    if (_customChapters != null && _customChapters!.isNotEmpty) {
      return _customChapters!;
    }

    // An in-flight read is de-duplicated by returning the same future rather
    // than bailing out with an empty list. Bailing out here is what let a
    // concurrent call report "no chapters" and wipe a good chapter list.
    final inFlight = _chapterFetchFuture;
    if (inFlight != null && _chapterFetchGeneration == generation) {
      return inFlight;
    }

    final future = _readChapters();
    _chapterFetchFuture = future;
    if (generation != null) {
      _chapterFetchGeneration = generation;
    }
    try {
      return await future;
    } finally {
      if (identical(_chapterFetchFuture, future)) {
        _chapterFetchFuture = null;
      }
    }
  }

  Future<List<Chapter>> _readChapters() async {
    final platform = _p.platform;
    if (platform is! NativePlayer) {
      logger.d(
        'Player platform is not NativePlayer, cannot fetch internal chapters '
        'via mpv properties.',
      );
      return [];
    }

    final native = platform;
    try {
      // Retry briefly to handle the race where mpv has not finished loading
      // the file's metadata yet.
      for (var i = 0; i < 10; i++) {
        final countStr = await native.getProperty('chapters');
        final count = int.tryParse(countStr) ?? 0;

        if (count > 0) {
          final resultString = await native.getProperty('chapter-list');
          if (resultString.isNotEmpty) {
            final result = jsonDecode(resultString);
            final chapters = parseMpvChapters(result, _p.state.duration);
            if (chapters.isNotEmpty) {
              logger.d('Found ${chapters.length} chapters internally.');
              return chapters;
            }
          }
        }

        final currentDuration = _p.state.duration.inMilliseconds;
        if (currentDuration > 0 && i > 3) {
          logger.d(
            'Duration loaded but no chapters found. '
            'Likely no internal chapters.',
          );
          return [];
        }

        await Future.delayed(const Duration(milliseconds: 150));
      }
    } catch (e, stack) {
      logger.e(
        'Error fetching/parsing chapters',
        error: e,
        stackTrace: stack,
      );
    }
    return [];
  }

  final StreamController<Duration> _totalDurationController =
      StreamController<Duration>.broadcast();

  /// Returns the total duration of the book.
  /// If it's a multi-file book, this is the sum of all files.
  /// Otherwise, it's the duration of the current file/stream.
  Stream<Duration> get totalDurationStream => _totalDurationController.stream;

  Future<void> jumpToChapter(int index) async {
    if (index < 0) return;

    // If custom chapters exist, we are in multi-file mode where each chapter
    // corresponds to a playlist item.
    if (_customChapters != null) {
      final mediaCount = _p.state.playlist.medias.length;
      if (index >= mediaCount) {
        logger.w(
          'jumpToChapter($index) out of range for $mediaCount media items',
        );
        return;
      }
      await _p.jump(index);
      return;
    }

    if (_p.platform is NativePlayer) {
      final native = _p.platform as NativePlayer;
      await native.setProperty('chapter', index.toString());
    }
  }

  Future<void> jump(int index) async {
    if (index < 0) return;
    await _p.jump(index);
  }

  Future<void> nextChapter() async {
    // If we have a playlist with multiple files (e.g. folder of MP3s),
    // next/prev means next file.
    if (_p.state.playlist.medias.length > 1) {
      await _p.next();
      return;
    }

    // Otherwise, for single files (M4B), navigate internal chapters.
    if (_p.platform is NativePlayer) {
      final native = _p.platform as NativePlayer;
      await native.command(['add', 'chapter', '1']);
    } else {
      logger.w(
        'nextChapter: platform is not NativePlayer and only one media is '
        'loaded; cannot advance chapters.',
      );
    }
  }

  /// Seconds into the current chapter beyond which "previous" restarts the
  /// current chapter instead of stepping to the one before it.
  static const double chapterRestartThresholdSeconds = 3.0;

  Future<void> previousChapter() async {
    if (_p.state.playlist.medias.length > 1) {
      await _p.previous();
      return;
    }

    if (_p.platform is NativePlayer) {
      final native = _p.platform as NativePlayer;
      // Match the familiar media-player behaviour: if we are more than a few
      // seconds into the chapter, restart it; otherwise step back. mpv's
      // `add chapter -1` always steps relative to the current chapter.
      final chapters = _customChapters ?? await getChapters();
      if (chapters.isNotEmpty) {
        final position = _p.state.position.inMilliseconds / 1000.0;
        final chapterIndex = currentChapterIndex(chapters, position);
        final chapter = chapters[chapterIndex];
        final intoChapter = position - chapter.startTime;
        if (chapterIndex > 0 &&
            intoChapter > chapterRestartThresholdSeconds) {
          await seek(
            Duration(milliseconds: (chapter.startTime * 1000).toInt()),
          );
          return;
        }
      }
      await native.command(['add', 'chapter', '-1']);
    } else {
      logger.w(
        'previousChapter: platform is not NativePlayer and only one media is '
        'loaded; cannot step back chapters.',
      );
    }
  }

  /// Index of the chapter containing [positionSeconds], or 0 if none match.
  static int currentChapterIndex(
    List<Chapter> chapters,
    double positionSeconds,
  ) {
    if (chapters.isEmpty) return 0;
    var index = 0;
    for (var i = 0; i < chapters.length; i++) {
      if (chapters[i].startTime <= positionSeconds) {
        index = i;
      } else {
        break;
      }
    }
    return index;
  }

  Duration get position => _player != null ? _p.state.position : Duration.zero;
  Duration get duration => _player != null ? _p.state.duration : Duration.zero;
  bool get isPlaying => _player != null ? _p.state.playing : false;
  double get volume => _player != null ? _p.state.volume : 100.0;
  double get playRate => _player != null ? _p.state.rate : 1.0;
  int get currentIndex => _player != null ? _p.state.playlist.index : 0;
  Tracks get tracks => _player != null ? _p.state.tracks : const Tracks();
  Track get track => _player != null ? _p.state.track : const Track();

  void dispose() {
    _playerDurationSubscription?.cancel();
    _playerDurationSubscription = null;
    _player?.dispose();
    _player = null;
    _totalDurationController.close();
    _chaptersController.close();
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

List<Chapter> parseMpvChapters(dynamic jsonResult, Duration fallbackDuration) {
  if (jsonResult is! List || jsonResult.isEmpty) return [];

  final validEntries = jsonResult.whereType<Map>().toList();
  if (validEntries.isEmpty) return [];

  final List<Chapter> chapters = [];
  for (int j = 0; j < validEntries.length; j++) {
    final e = validEntries[j];

    final startTime = (e['time'] as num?)?.toDouble() ?? 0.0;
    double? endTime;

    if (j < validEntries.length - 1) {
      final next = validEntries[j + 1];
      endTime = (next['time'] as num?)?.toDouble();
    } else {
      final d = fallbackDuration.inMilliseconds / 1000.0;
      if (d > 0) endTime = d;
    }

    final title = e['title']?.toString() ?? 'Chapter ${j + 1}';

    chapters.add(
      Chapter(
        title: title,
        startTime: startTime,
        endTime: endTime,
      ),
    );
  }
  return chapters;
}
