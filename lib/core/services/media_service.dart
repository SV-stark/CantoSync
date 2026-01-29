import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

// Provider
final mediaServiceProvider = Provider<MediaService>((ref) {
  final service = MediaService();
  ref.onDispose(() => service.dispose());
  return service;
});

class MediaService {
  late final Player _player;

  // State Streams
  Stream<bool> get playingStream => _player.stream.playing;
  Stream<Duration> get positionStream => _player.stream.position;
  Stream<Duration> get durationStream => _player.stream.duration;
  Stream<double> get volumeStream => _player.stream.volume;
  Stream<Playlist> get playlistStream => _player.stream.playlist;

  MediaService() {
    // Determine configuration based on platform (Handled globally in main, but good to be safe)
    // Create a new player
    _player = Player();
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
    await _player.setVolume(volume);
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
        // libmpv returns chapters as a list of maps
        // We use 'chapter-list' property
        final resultString = await native.getProperty('chapter-list');
        if (resultString.isEmpty) return [];

        final result = jsonDecode(resultString);
        if (result is List) {
          final totalDuration = _player.state.duration.inMilliseconds / 1000.0;
          final List<Chapter> chapters = [];

          for (int i = 0; i < result.length; i++) {
            final e = result[i];
            if (e is! Map) continue; // Skip invalid entries

            final startTime = (e['time'] as num?)?.toDouble() ?? 0.0;
            double? endTime;

            if (i < result.length - 1) {
              final next = result[i + 1];
              if (next is Map) {
                endTime = (next['time'] as num?)?.toDouble();
              }
            } else if (totalDuration > 0) {
              endTime = totalDuration;
            }

            chapters.add(
              Chapter(
                title: e['title']?.toString() ?? 'Chapter ${i + 1}',
                startTime: startTime,
                endTime: endTime,
              ),
            );
          }
          return chapters;
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
  int get currentIndex => _player.state.playlist.index;
  Tracks get tracks => _player.state.tracks;
  Track get track => _player.state.track;

  Future<void> setAudioFilter(String filter) async {
    if (_player.platform is NativePlayer) {
      final native = _player.platform as NativePlayer;
      await native.setProperty('af', filter);
    }
  }

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
