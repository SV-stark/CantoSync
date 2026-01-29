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

  Future<void> open(String filePath) async {
    await _player.open(Media(filePath));
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
    if (_player.platform is NativePlayer) {
      final native = _player.platform as NativePlayer;
      try {
        // libmpv returns chapters as a list of maps
        // We use 'chapter-list' property
        // The return type of getProperty can be somewhat dynamic in the wrapper
        // but typically for complex types it might be a List<dynamic>
        // Let's assume it returns a list of maps based on standard JSON IPC / mpv behavior
        final resultString = await native.getProperty('chapter-list');
        if (resultString.isEmpty) return [];

        final result = jsonDecode(resultString);
        if (result is List) {
          return result
              .map(
                (e) => Chapter(
                  title: e['title'] ?? 'Chapter ${result.indexOf(e) + 1}',
                  startTime: (e['time'] as num).toDouble(),
                ),
              )
              .toList();
        }
      } catch (e) {
        debugPrint('Error fetching chapters: $e');
      }
    }
    return [];
  }

  Future<void> jumpToChapter(int index) async {
    if (_player.platform is NativePlayer) {
      final native = _player.platform as NativePlayer;
      await native.setProperty('chapter', index.toString());
    }
  }

  Future<void> nextChapter() async {
    // Rely on native next
    await _player.next();
  }

  Future<void> previousChapter() async {
    // Rely on native previous
    await _player.previous();
  }

  Duration get position => _player.state.position;
  Duration get duration => _player.state.duration;
  bool get isPlaying => _player.state.playing;
  Tracks get tracks => _player.state.tracks;
  Track get track => _player.state.track;

  void dispose() {
    _player.dispose();
  }
}

class Chapter {
  final String title;
  final double startTime;

  Chapter({required this.title, required this.startTime});
}
