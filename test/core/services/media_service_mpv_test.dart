import 'package:canto_sync/core/services/media_service.dart';
import 'package:canto_sync/core/services/playback_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MediaService.buildAudioFilterChain', () {
    test('returns empty string when all filters are disabled', () {
      expect(MediaService.buildAudioFilterChain(), isEmpty);
    });

    test('labels preset filters and enabled audiobook filters cleanly', () {
      final chain = MediaService.buildAudioFilterChain(
        presetFilter: 'equalizer=f=100:g=-10, equalizer=f=3000:g=6',
        voiceClarity: true,
        skipSilence: true,
        loudnessNormalization: true,
        dynamicNormalization: true,
      );

      expect(
        chain,
        '@eq0:equalizer=f=100:g=-10,'
        '@eq1:equalizer=f=3000:g=6,'
        '@highpass:highpass=f=80,'
        '@comp:acompressor=threshold=-20dB:ratio=3:attack=5:release=50,'
        '@silence:silenceremove=stop_periods=-1:stop_duration=0.5:stop_threshold=-50dB,'
        '@loudnorm:loudnorm,'
        '@dynaudnorm:dynaudnorm=f=150:g=15',
      );
    });

    test('preserves already-labeled filters in presetFilter', () {
      final chain = MediaService.buildAudioFilterChain(
        presetFilter: '@custom:bass=g=6',
      );

      expect(chain, '@custom:bass=g=6');
    });
  });

  group('MediaService.parseAudioDeviceList', () {
    test('parses valid mpv audio-device-list entries', () {
      final devices = MediaService.parseAudioDeviceList([
        {'name': 'auto', 'description': 'Autoselect device'},
        {
          'name': 'wasapi/{123}',
          'description': 'Speakers (Realtek Audio)',
        },
        {'name': '', 'description': 'Invalid empty name'},
        'not-a-map',
      ]);

      expect(devices, hasLength(2));
      expect(devices[0].name, 'auto');
      expect(devices[0].description, 'Autoselect device');
      expect(devices[1].name, 'wasapi/{123}');
      expect(devices[1].description, 'Speakers (Realtek Audio)');
    });

    test('returns empty list for non-list inputs', () {
      expect(MediaService.parseAudioDeviceList(null), isEmpty);
      expect(MediaService.parseAudioDeviceList({}), isEmpty);
    });
  });

  group('PlaybackState.currentChapter', () {
    final chapters = [
      Chapter(title: 'Chapter 1', startTime: 0, endTime: 100),
      Chapter(title: 'Chapter 2', startTime: 100, endTime: 250),
      Chapter(title: 'Chapter 3', startTime: 250, endTime: 400),
    ];

    test('uses observed currentChapterIndex for single-file books', () {
      final state = PlaybackState(
        chapters: chapters,
        currentChapterIndex: 1,
        position: const Duration(seconds: 10),
      );

      expect(state.currentChapter?.title, 'Chapter 2');
    });

    test('falls back to position matching when currentChapterIndex is -1', () {
      final state = PlaybackState(
        chapters: chapters,
        currentChapterIndex: -1,
        position: const Duration(seconds: 260),
      );

      expect(state.currentChapter?.title, 'Chapter 3');
    });

    test('uses playlist currentIndex for multi-file books', () {
      final state = PlaybackState(
        chapters: chapters,
        isPlaylistOpen: true,
        currentIndex: 2,
        currentChapterIndex: 0,
      );

      expect(state.currentChapter?.title, 'Chapter 3');
    });
  });
}
