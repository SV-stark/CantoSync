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

  /// Maximum volume percentage supported natively by mpv (`volume-max=200`).
  static const double maxVolume = 200.0;

  Player? _player;
  final Ref _ref;
  bool _initFailed = false;
  bool _isDisposed = false;

  /// In-flight mpv chapter read, de-duplicated by [getChapters].
  Future<List<Chapter>>? _chapterFetchFuture;
  int _chapterFetchInFlightGeneration = -1;

  /// True once the player failed to construct so the UI can surface an error
  /// instead of silently showing an inert player forever.
  bool get isInitialised => _player != null && !_initFailed && !_isDisposed;
  bool get isDisposed => _isDisposed;

  Player get _p {
    if (_isDisposed) {
      throw StateError('MediaService has been disposed');
    }
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
  Completer<List<Chapter>>? _chapterCompleter;
  int _chapterCompleterGeneration = -1;

  void _init() {
    // Guard against re-entry: the _p getter re-invokes _init() whenever the
    // player is null, which previously leaked a native handle on each call
    // because the old instance was overwritten without being disposed.
    if (_isDisposed || _player != null || _initialising) return;
    _initialising = true;
    try {
      final player = Player();
      _playerDurationSubscription?.cancel();
      _playerDurationSubscription = player.stream.duration.listen((d) {
        if (_customTotalDuration == null) {
          _emitTotalDuration(d);
        }
      });
      _player = player;
      unawaited(_configureNativePlayer(player));
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

  Future<void> _configureNativePlayer(Player player) async {
    final platform = player.platform;
    if (platform is! NativePlayer || _isDisposed) return;

    try {
      await platform.setProperty('gapless-audio', 'yes');
      await platform.setProperty('replaygain', 'track');
      await platform.setProperty('audio-pitch-correction', 'yes');
      await platform.setProperty('hr-seek', 'yes');
      await platform.setProperty('prefetch-playlist', 'yes');
      await platform.setProperty('cache', 'yes');
      await platform.setProperty('demuxer-max-bytes', '33554432');
      await platform.setProperty('volume-max', maxVolume.toInt().toString());
      await platform.setProperty(
        'audio-channels',
        _monoAudio ? 'mono' : 'auto',
      );
      if (_audioDevice.isNotEmpty && _audioDevice != 'auto') {
        await platform.setProperty('audio-device', _audioDevice);
      }

      await platform.observeProperty('chapter-list', (value) async {
        if (_isDisposed || _customChapters != null || value.isEmpty) return;
        try {
          final decoded = jsonDecode(value);
          final chapters = parseMpvChapters(decoded, player.state.duration);
          if (chapters.isEmpty) return;

          final completer = _chapterCompleter;
          if (completer != null &&
              !completer.isCompleted &&
              _chapterCompleterGeneration == _chapterFetchGeneration) {
            completer.complete(chapters);
          } else {
            _emitChapters(chapters);
          }
        } catch (e, stack) {
          logger.w(
            'Error parsing observed chapter-list',
            error: e,
            stackTrace: stack,
          );
        }
      });

      await platform.observeProperty('chapter', (value) async {
        if (_isDisposed) return;
        final parsed = int.tryParse(value.trim());
        _emitChapterIndex(parsed != null && parsed >= 0 ? parsed : -1);
      });

      await platform.observeProperty('eof-reached', (value) async {
        if (_isDisposed) return;
        final normalized = value.trim().toLowerCase();
        _emitEofReached(normalized == 'yes' || normalized == 'true');
      });
    } catch (e, stack) {
      logger.w(
        'Error configuring NativePlayer audiobook properties',
        error: e,
        stackTrace: stack,
      );
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
      // Initialize filters and native audio options from settings
      final settings = _ref.read(appSettingsProvider);
      _skipSilence = settings.skipSilence;
      _loudnessNormalization = settings.loudnessNormalization;
      _dynamicNormalization = settings.dynamicNormalization;
      _voiceClarity = settings.voiceClarity;
      _monoAudio = settings.monoAudio;
      _audioDevice = settings.audioDevice;
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
  List<Chapter> _lastChapters = const [];
  List<Chapter> get lastChapters => _lastChapters;

  final StreamController<int> _chapterIndexController =
      StreamController<int>.broadcast();
  Stream<int> get currentChapterIndexStream => _chapterIndexController.stream;

  final StreamController<bool> _eofReachedController =
      StreamController<bool>.broadcast();
  Stream<bool> get eofReachedStream => _eofReachedController.stream;

  void _emitChapters(List<Chapter> chapters) {
    _lastChapters = chapters;
    if (!_isDisposed && !_chaptersController.isClosed) {
      _chaptersController.add(chapters);
    }
  }

  void _emitChapterIndex(int index) {
    if (!_isDisposed && !_chapterIndexController.isClosed) {
      _chapterIndexController.add(index);
    }
  }

  void _emitEofReached(bool reached) {
    if (!_isDisposed && !_eofReachedController.isClosed) {
      _eofReachedController.add(reached);
    }
  }

  void _emitTotalDuration(Duration duration) {
    _lastTotalDuration = duration;
    if (!_isDisposed && !_totalDurationController.isClosed) {
      _totalDurationController.add(duration);
    }
  }

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
    _chapterFetchFuture = null;
    if (_chapterCompleter != null && !_chapterCompleter!.isCompleted) {
      _chapterCompleter!.complete(const []);
    }
    _chapterCompleter = null;
    _isPlaylistOpen = mediaSource is List<String> && mediaSource.length > 1;

    if (totalDuration != null) {
      _emitTotalDuration(totalDuration);
    } else {
      // Clear the previous book's total immediately. Leaving it in place made
      // the next book briefly look "multi-file" and corrupted the seek maths.
      _emitTotalDuration(Duration.zero);
    }

    if (chapters != null) {
      _emitChapters(chapters);
    } else {
      _emitChapters(const []);
    }
    _emitChapterIndex(-1);
    _emitEofReached(false);

    if (mediaSource is String) {
      await _p.open(Media(mediaSource), play: autoPlay);
    } else if (mediaSource is List<String>) {
      final playlist = Playlist(
        mediaSource.map((path) => Media(path)).toList(),
      );
      await _p.open(playlist, play: autoPlay);
    }

    if (chapters == null && !_isDisposed && generation == _chapterFetchGeneration) {
      unawaited(
        getChapters(generation: generation).then((c) {
          // Only publish if this is still the book we were asked about, and
          // only if we actually found chapters -- an empty result from a
          // superseded fetch must not wipe a good chapter list.
          if (!_isDisposed &&
              generation == _chapterFetchGeneration &&
              c.isNotEmpty) {
            _emitChapters(c);
          }
        }),
      );
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
    final platform = _p.platform;
    if (platform is NativePlayer) {
      final seconds = (target.inMilliseconds / 1000.0).toStringAsFixed(3);
      await platform.command(['seek', seconds, 'absolute+exact']);
    } else {
      await _p.seek(target);
    }
  }

  Future<void> setVolume(double volume) async {
    await _p.setVolume(volume.clamp(0.0, maxVolume));
  }

  Future<void> setSkipSilence(bool enabled) async {
    _skipSilence = enabled;
    await _applyFilters();
  }

  Future<void> setLoudnessNormalization(bool enabled) async {
    _loudnessNormalization = enabled;
    await _applyFilters();
  }

  Future<void> setDynamicNormalization(bool enabled) async {
    _dynamicNormalization = enabled;
    await _applyFilters();
  }

  Future<void> setVoiceClarity(bool enabled) async {
    _voiceClarity = enabled;
    await _applyFilters();
  }

  Future<void> setMonoAudio(bool enabled) async {
    _monoAudio = enabled;
    final platform = _p.platform;
    if (platform is NativePlayer) {
      await platform.setProperty('audio-channels', enabled ? 'mono' : 'auto');
    }
  }

  Future<void> setAudioDevice(String device) async {
    _audioDevice = device.isEmpty ? 'auto' : device;
    final platform = _p.platform;
    if (platform is NativePlayer) {
      await platform.setProperty('audio-device', _audioDevice);
    }
  }

  /// Queries mpv's `audio-device-list` property for available audio outputs.
  Future<List<AudioOutputDevice>> getAudioDevices() async {
    final platform = _player?.platform;
    if (platform is! NativePlayer) return const [];
    try {
      final raw = await platform.getProperty('audio-device-list');
      if (raw.isEmpty) return const [];
      return parseAudioDeviceList(jsonDecode(raw));
    } catch (e, stack) {
      logger.w(
        'Error reading mpv audio-device-list',
        error: e,
        stackTrace: stack,
      );
      return const [];
    }
  }

  /// Parses mpv's JSON `audio-device-list` array into typed [AudioOutputDevice]s.
  static List<AudioOutputDevice> parseAudioDeviceList(dynamic decoded) {
    if (decoded is! List) return const [];
    final devices = <AudioOutputDevice>[];
    for (final entry in decoded) {
      if (entry is! Map) continue;
      final name = entry['name']?.toString() ?? '';
      if (name.isEmpty) continue;
      final description = entry['description']?.toString() ?? name;
      devices.add(AudioOutputDevice(name: name, description: description));
    }
    return devices;
  }

  bool _skipSilence = false;
  bool _loudnessNormalization = false;
  bool _dynamicNormalization = false;
  bool _voiceClarity = false;
  bool _monoAudio = false;
  String _audioDevice = 'auto';
  String _activePresetFilter = '';

  Future<void> setAudioFilter(String filter) async {
    _activePresetFilter = filter;
    await _applyFilters();
  }

  /// Builds a labeled mpv `af` filter chain from the enabled audio options.
  static String buildAudioFilterChain({
    String presetFilter = '',
    bool skipSilence = false,
    bool loudnessNormalization = false,
    bool dynamicNormalization = false,
    bool voiceClarity = false,
  }) {
    final filters = <String>[];

    if (presetFilter.isNotEmpty) {
      final parts = presetFilter
          .split(',')
          .map((p) => p.trim())
          .where((p) => p.isNotEmpty);
      var idx = 0;
      for (final part in parts) {
        filters.add(part.startsWith('@') ? part : '@eq${idx++}:$part');
      }
    }

    if (voiceClarity) {
      filters.add('@highpass:highpass=f=80');
      filters.add('@comp:acompressor=threshold=-20dB:ratio=3:attack=5:release=50');
    }

    if (skipSilence) {
      filters.add(
        '@silence:silenceremove=stop_periods=-1:stop_duration=0.5:stop_threshold=-50dB',
      );
    }

    if (loudnessNormalization) {
      filters.add('@loudnorm:loudnorm');
    }

    if (dynamicNormalization) {
      filters.add('@dynaudnorm:dynaudnorm=f=150:g=15');
    }

    return filters.join(',');
  }

  Future<void> _applyFilters() async {
    try {
      final platform = _p.platform;
      if (platform is NativePlayer) {
        final filterString = buildAudioFilterChain(
          presetFilter: _activePresetFilter,
          skipSilence: _skipSilence,
          loudnessNormalization: _loudnessNormalization,
          dynamicNormalization: _dynamicNormalization,
          voiceClarity: _voiceClarity,
        );
        logger.d('Applying audio filters: "$filterString"');

        // We use 'af' property to set labeled audio filters in mpv
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
  Stream<double> get rateStream =>
      _player != null ? _p.stream.rate : Stream.value(1.0);

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
    final targetGeneration = generation ?? _chapterFetchGeneration;
    final inFlight = _chapterFetchFuture;
    if (inFlight != null && _chapterFetchInFlightGeneration == targetGeneration) {
      return inFlight;
    }

    final future = _readChapters(targetGeneration);
    _chapterFetchFuture = future;
    _chapterFetchInFlightGeneration = targetGeneration;
    try {
      return await future;
    } finally {
      if (identical(_chapterFetchFuture, future)) {
        _chapterFetchFuture = null;
      }
    }
  }

  Future<List<Chapter>> _readChapters(int generation) async {
    if (_isDisposed || _player == null) return [];
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
      // Check immediately in case mpv already parsed chapters before getChapters() ran.
      final immediate = await native.getProperty('chapter-list');
      if (_isDisposed ||
          _player == null ||
          generation != _chapterFetchGeneration) {
        return [];
      }
      if (immediate.isNotEmpty) {
        final decoded = jsonDecode(immediate);
        final chapters = parseMpvChapters(decoded, _p.state.duration);
        if (chapters.isNotEmpty) {
          logger.d('Found ${chapters.length} chapters internally.');
          return chapters;
        }
      }

      // Otherwise wait for the event-driven observeProperty('chapter-list') callback.
      final completer = Completer<List<Chapter>>();
      _chapterCompleter = completer;
      _chapterCompleterGeneration = generation;
      final chapters = await completer.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () => const [],
      );
      if (identical(_chapterCompleter, completer)) {
        _chapterCompleter = null;
      }
      if (_isDisposed || generation != _chapterFetchGeneration) {
        return [];
      }
      if (chapters.isNotEmpty) {
        logger.d('Found ${chapters.length} chapters via chapter-list observer.');
      }
      return chapters;
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
  Duration _lastTotalDuration = Duration.zero;
  Duration get lastTotalDuration => _lastTotalDuration;

  /// Returns the total duration of the book.
  /// If it's a multi-file book, this is the sum of all files.
  /// Otherwise, it's the duration of the current file/stream.
  Stream<Duration> get totalDurationStream => _totalDurationController.stream;

  Future<void> jumpToChapter(int index) async {
    if (index < 0) return;

    // Only treat chapters as playlist indices when a multi-file playlist is open.
    if (_isPlaylistOpen) {
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
    _isDisposed = true;
    if (_chapterCompleter != null && !_chapterCompleter!.isCompleted) {
      _chapterCompleter!.complete(const []);
    }
    _chapterCompleter = null;
    final platform = _player?.platform;
    if (platform is NativePlayer) {
      unawaited(platform.unobserveProperty('chapter-list').catchError((_) {}));
      unawaited(platform.unobserveProperty('chapter').catchError((_) {}));
      unawaited(platform.unobserveProperty('eof-reached').catchError((_) {}));
    }
    _playerDurationSubscription?.cancel();
    _playerDurationSubscription = null;
    _player?.dispose();
    _player = null;
    _totalDurationController.close();
    _chaptersController.close();
    _chapterIndexController.close();
    _eofReachedController.close();
  }
}

class AudioOutputDevice {
  const AudioOutputDevice({required this.name, required this.description});

  final String name;
  final String description;
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
