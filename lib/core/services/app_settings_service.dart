import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:canto_sync/core/services/media_service.dart';
import 'package:canto_sync/core/constants/app_constants.dart';

enum AudioPreset {
  flat('Flat', ''),
  voiceEnhance(
    'Voice Enhance',
    'equalizer=f=100:width_type=h:width=100:g=-10,equalizer=f=1000:width_type=h:width=500:g=4,equalizer=f=3000:width_type=h:width=1000:g=6',
  ),
  bassBoost('Bass Boost', 'bass=g=6');

  final String label;
  final String filter;
  const AudioPreset(this.label, this.filter);
}

enum PlayerThemeMode {
  standard('Standard'),
  trueBlack('True Black (OLED)'),
  adaptive('Adaptive (Cover Art)');

  final String label;
  const PlayerThemeMode(this.label);
}

class AppSettings {
  final ThemeMode themeMode;
  final AudioPreset audioPreset;
  final List<String> libraryPaths;
  final bool skipSilence;
  final bool loudnessNormalization;
  final PlayerThemeMode playerThemeMode;
  final bool showWaveform;
  final bool showCoverReflection;

  AppSettings({
    this.themeMode = ThemeMode.system,
    this.audioPreset = AudioPreset.flat,
    this.libraryPaths = const [],
    this.skipSilence = false,
    this.loudnessNormalization = false,
    this.playerThemeMode = PlayerThemeMode.standard,
    this.showWaveform = true,
    this.showCoverReflection = true,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    AudioPreset? audioPreset,
    List<String>? libraryPaths,
    bool? skipSilence,
    bool? loudnessNormalization,
    PlayerThemeMode? playerThemeMode,
    bool? showWaveform,
    bool? showCoverReflection,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      audioPreset: audioPreset ?? this.audioPreset,
      libraryPaths: libraryPaths ?? this.libraryPaths,
      skipSilence: skipSilence ?? this.skipSilence,
      loudnessNormalization:
          loudnessNormalization ?? this.loudnessNormalization,
      playerThemeMode: playerThemeMode ?? this.playerThemeMode,
      showWaveform: showWaveform ?? this.showWaveform,
      showCoverReflection: showCoverReflection ?? this.showCoverReflection,
    );
  }
}

class AppSettingsNotifier extends Notifier<AppSettings> {
  late Box _box;

  @override
  AppSettings build() {
    try {
      _box = Hive.box(AppConstants.settingsBox);

      final themeIndex = _box.get(
        'themeMode',
        defaultValue: ThemeMode.system.index,
      );
      final presetIndex = _box.get(
        'audioPreset',
        defaultValue: AudioPreset.flat.index,
      );
      final pathsRaw = _box.get('libraryPaths', defaultValue: <String>[]);
      List<String> paths = [];
      if (pathsRaw is List) {
        paths = pathsRaw.cast<String>().toList();
      } else {
        // Corrupted data, reset
        _box.delete('libraryPaths');
      }

      final skipSilence = _box.get('skipSilence', defaultValue: false);
      final loudnessNormalization = _box.get(
        'loudnessNormalization',
        defaultValue: false,
      );
      
      final playerThemeModeIndex = _box.get(
        'playerThemeMode',
        defaultValue: PlayerThemeMode.standard.index,
      );
      final showWaveform = _box.get('showWaveform', defaultValue: true);
      final showCoverReflection = _box.get('showCoverReflection', defaultValue: true);

      return AppSettings(
        themeMode: ThemeMode.values[themeIndex],
        audioPreset: AudioPreset.values[presetIndex],
        libraryPaths: paths,
        skipSilence: skipSilence,
        loudnessNormalization: loudnessNormalization,
        playerThemeMode: PlayerThemeMode.values[playerThemeModeIndex],
        showWaveform: showWaveform,
        showCoverReflection: showCoverReflection,
      );
    } catch (e) {
      debugPrint('Error loading AppSettings: $e');
      // Fallback to default
      return AppSettings();
    }
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _box.put('themeMode', mode.index);
  }

  void setAudioPreset(AudioPreset preset) {
    state = state.copyWith(audioPreset: preset);
    _box.put('audioPreset', preset.index);

    // Apply filter immediately
    ref.read(mediaServiceProvider).setAudioFilter(preset.filter);
  }

  void setSkipSilence(bool enabled) {
    state = state.copyWith(skipSilence: enabled);
    _box.put('skipSilence', enabled);
    ref.read(mediaServiceProvider).setSkipSilence(enabled);
  }

  void setLoudnessNormalization(bool enabled) {
    state = state.copyWith(loudnessNormalization: enabled);
    _box.put('loudnessNormalization', enabled);
    ref.read(mediaServiceProvider).setLoudnessNormalization(enabled);
  }

  void addLibraryPath(String path) {
    if (!state.libraryPaths.contains(path)) {
      final newPaths = [...state.libraryPaths, path];
      state = state.copyWith(libraryPaths: newPaths);
      _box.put('libraryPaths', newPaths);
    }
  }

  void removeLibraryPath(String path) {
    final newPaths = state.libraryPaths.where((p) => p != path).toList();
    state = state.copyWith(libraryPaths: newPaths);
    _box.put('libraryPaths', newPaths);
  }

  void setPlayerThemeMode(PlayerThemeMode mode) {
    state = state.copyWith(playerThemeMode: mode);
    _box.put('playerThemeMode', mode.index);
  }

  void setShowWaveform(bool enabled) {
    state = state.copyWith(showWaveform: enabled);
    _box.put('showWaveform', enabled);
  }

  void setShowCoverReflection(bool enabled) {
    state = state.copyWith(showCoverReflection: enabled);
    _box.put('showCoverReflection', enabled);
  }
}

final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);
