import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:canto_sync/core/services/app_settings_service.dart';

// Provider
final mediaServiceProvider = Provider<MediaService>((ref) {
  final service = MediaService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});

class MediaService {
  late final Player _player;
  final Ref _ref;

  // State Streams
  Stream<bool> get playingStream => _player.stream.playing;
  Stream<Duration> get positionStream => _player.stream.position;
  Stream<Duration> get durationStream => _player.stream.duration;
  Stream<double> get volumeStream => _player.stream.volume;
  Stream<Playlist> get playlistStream => _player.stream.playlist;

  MediaService(this._ref) {
    _player = Player();

    // Initialize filters from settings
    final settings = _ref.read(appSettingsProvider);
    _skipSilence = settings.skipSilence;
    _loudnessNormalization = settings.loudnessNormalization;
    _activePresetFilter = settings.audioPreset.filter;
    _applyFilters();
  }

  List<Chapter>? _customChapters;
  Duration? _customTotalDuration;

  Future<void> open(
    dynamic mediaSource, {
    String? title,
    String? artist,
    String? album,
    bool autoPlay = true,
    List<Chapter>? chapters,
    Duration? totalDuration,
  }) async {
    _customChapters = chapters;
    _customTotalDuration = totalDuration;

    if (mediaSource is String) {
      await _player.open(
        Media(
          mediaSource,
          httpHeaders: {
            'title': title ?? '',
            'artist': artist ?? '',
            'album': album ?? '',
          },
        ),
        play: autoPlay,
      );
    } else if (mediaSource is List<String>) {
      final playlist = Playlist(
        mediaSource
            .map(
              (path) => Media(
                path,
                httpHeaders: {
                  'title': title ?? '',
                  'artist': artist ?? '',
                  'album': album ?? '',
                },
              ),
            )
            .toList(),
      );
      await _player.open(playlist, play: autoPlay);
    }

    // Ensure filters are applied to the new media
    await _applyFilters();
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> playOrPause() async {
    await _player.playOrPause();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setVolume(double volume) async {
    // Clamp to reasonable max (200)
    // Note: media_kit volume is 0.0 to 100.0 normally, but can go higher.
    await _player.setVolume(volume);
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
    if (_player.platform is NativePlayer) {
      final native = _player.platform as NativePlayer;
      final List<String> filters = [];

      if (_activePresetFilter.isNotEmpty) {
        filters.add(_activePresetFilter);
      }

      if (_skipSilence) {
        filters.add(
          'lavfi=[silenceremove=stop_periods=-1:stop_duration=0.5:stop_threshold=-45dB]',
        );
      }

      if (_loudnessNormalization) {
        filters.add('lavfi=[loudnorm]');
      }

      if (filters.isEmpty) {
        await native.setProperty('af', '');
      } else {
        await native.setProperty('af', filters.join(','));
      }
    }
  }

  Future<void> setRate(double rate) async {
    await _player.setRate(rate);
  }

  Stream<Tracks> get tracksStream => _player.stream.tracks;
  Stream<Track> get trackStream => _player.stream.track;

  // ... (constructor) ...

  // Chapter Navigation
  Future<List<Chapter>> getChapters() async {
    // If we have custom chapters (from multi-file book), return those
    if (_customChapters != null && _customChapters!.isNotEmpty) {
      return _customChapters!;
    }

    if (_player.platform is NativePlayer) {
      final native = _player.platform as NativePlayer;
      try {
        // Retry logic to handle race conditions where chapters/metadata aren't loaded yet.
        // We increase to 10 attempts (approx 5 seconds max wait) to be very safe for large M4Bs.
        for (int i = 0; i < 10; i++) {
          // First, check if mpv even sees chapters.
          // 'chapters' property returns the COUNT of chapters.
          final countStr = await native.getProperty('chapters');
          final count = int.tryParse(countStr) ?? 0;

          if (count > 0) {
            final resultString = await native.getProperty('chapter-list');

            if (resultString.isNotEmpty) {
              final result = jsonDecode(resultString);
              if (result is List && result.isNotEmpty) {
                final List<Chapter> chapters = [];

                for (int j = 0; j < result.length; j++) {
                  final e = result[j];
                  if (e is! Map) continue;

                  final startTime = (e['time'] as num?)?.toDouble() ?? 0.0;
                  double? endTime;

                  // Try to get end time from next chapter
                  if (j < result.length - 1) {
                    final next = result[j + 1];
                    if (next is Map) {
                      endTime = (next['time'] as num?)?.toDouble();
                    }
                  } else {
                    // For last chapter, use total duration
                    final d = _player.state.duration.inMilliseconds / 1000.0;
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
                return chapters;
              }
            }
          }

          // If 0 chapters found, check if duration is loaded.
          // If duration is > 0 and no chapters after a few retries, maybe there ARE no chapters.
          final currentDuration = _player.state.duration.inMilliseconds;
          if (currentDuration > 0 && i > 4) {
            // We waited ~2.5 seconds and duration is known, but still no chapters?
            // Likely a book without chapters.
            return [];
          }

          // Wait and retry.
          await Future.delayed(const Duration(milliseconds: 500));
        }
      } catch (e, stack) {
        debugPrint('Error fetching/parsing chapters: $e\n$stack');
      }
    }
    return [];
  }

  /// Returns the total duration of the book.
  /// If it's a multi-file book, this is the sum of all files.
  /// Otherwise, it's the duration of the current file/stream.
  Stream<Duration> get totalDurationStream {
    if (_customTotalDuration != null) {
      return Stream.value(_customTotalDuration!);
    }
    return _player.stream.duration;
  }

  Future<void> jumpToChapter(int index) async {
    // If custom chapters exist, it means we are in multi-file mode where
    // each chapter corresponds to a playlist item.
    if (_customChapters != null) {
      await _player.jump(index);
      return;
    }

    if (_player.platform is NativePlayer) {
      final native = _player.platform as NativePlayer;
      await native.setProperty('chapter', index.toString());
    }
  }

  Future<void> jump(int index) async {
    await _player.jump(index);
  }

  Future<void> nextChapter() async {
    // If we have a playlist with multiple files (e.g. folder of MP3s),
    // next/prev usually means next file.
    if (_player.state.playlist.medias.length > 1) {
      await _player.next();
      return;
    }

    // Otherwise, for single files (M4B), we want to navigate internal chapters.
    if (_player.platform is NativePlayer) {
      final native = _player.platform as NativePlayer;
      await native.command(['add', 'chapter', '1']);
    } else {
      await _player.next();
    }
  }

  Future<void> previousChapter() async {
    if (_player.state.playlist.medias.length > 1) {
      await _player.previous();
      return;
    }

    if (_player.platform is NativePlayer) {
      final native = _player.platform as NativePlayer;
      await native.command(['add', 'chapter', '-1']);
    } else {
      await _player.previous();
    }
  }

  Duration get position => _player.state.position;
  Duration get duration => _player.state.duration;
  bool get isPlaying => _player.state.playing;
  double get volume => _player.state.volume;
  double get playRate => _player.state.rate;
  int get currentIndex => _player.state.playlist.index;
  Tracks get tracks => _player.state.tracks;
  Track get track => _player.state.track;

  void dispose() {
    _player.dispose();
  }
}

class Chapter {
  final String title;
  final double startTime;
  final double? endTime;

  Chapter({required this.title, required this.startTime, this.endTime});

  double? get durationSeconds =>
      endTime != null ? (endTime! - startTime) : null;
}
