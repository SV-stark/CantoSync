import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:canto_sync/core/services/media_service.dart';
import 'package:canto_sync/core/constants/app_constants.dart';
import 'package:canto_sync/core/utils/logger.dart';

part 'app_settings_service.freezed.dart';
part 'app_settings_service.g.dart';

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

@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(AudioPreset.flat) AudioPreset audioPreset,
    @Default([]) List<String> libraryPaths,
    @Default(false) bool skipSilence,
    @Default(false) bool loudnessNormalization,
    @Default(PlayerThemeMode.standard) PlayerThemeMode playerThemeMode,
    @Default(true) bool showWaveform,
    @Default(true) bool showCoverReflection,
  }) = _AppSettings;
}

@riverpod
class AppSettingsNotifier extends _$AppSettingsNotifier {
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
        themeMode: ThemeMode.values[themeIndex % ThemeMode.values.length],
        audioPreset: AudioPreset.values[presetIndex % AudioPreset.values.length],
        libraryPaths: paths,
        skipSilence: skipSilence,
        loudnessNormalization: loudnessNormalization,
        playerThemeMode: PlayerThemeMode.values[playerThemeModeIndex % PlayerThemeMode.values.length],
        showWaveform: showWaveform,
        showCoverReflection: showCoverReflection,
      );
    } catch (e, stack) {
      logger.e('Error loading AppSettings', error: e, stackTrace: stack);
      // Fallback to default
      return const AppSettings();
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
