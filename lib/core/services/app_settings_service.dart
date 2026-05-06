import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar_community/isar.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:canto_sync/features/library/data/library_service.dart';
import 'package:canto_sync/core/services/media_service.dart';

part 'app_settings_service.freezed.dart';
part 'app_settings_service.g.dart';

enum AudioPreset {
  flat('Flat', ''),
  voiceEnhance(
    'Voice Enhance',
    'equalizer=f=100:width_type=h:width=100:g=-10,equalizer=f=1000:width_type=h:width=500:g=4,equalizer=f=3000:width_type=h:width=1000:g=6',
  ),
  bassBoost('Bass Boost', 'bass=g=6');

  const AudioPreset(this.label, this.filter);

  final String label;
  final String filter;
}

enum PlayerThemeMode {
  standard('Standard'),
  trueBlack('True Black (OLED)'),
  adaptive('Adaptive (Cover Art)');

  const PlayerThemeMode(this.label);

  final String label;
}

@freezed
abstract class AppSettings with _$AppSettings {
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

@collection
class IsarAppSettings {
  Id id = 0; // Always 0 for the single settings document

  @enumerated
  ThemeMode themeMode = ThemeMode.system;

  @enumerated
  AudioPreset audioPreset = AudioPreset.flat;

  List<String> libraryPaths = [];
  bool skipSilence = false;
  bool loudnessNormalization = false;

  @enumerated
  PlayerThemeMode playerThemeMode = PlayerThemeMode.standard;

  bool showWaveform = true;
  bool showCoverReflection = true;
}

@riverpod
class AppSettingsNotifier extends _$AppSettingsNotifier {
  late Isar _isar;

  @override
  AppSettings build() {
    _isar = ref.watch(isarProvider);

    final isarSettings = _isar.isarAppSettings.getSync(0);

    if (isarSettings == null) {
      return const AppSettings();
    }

    return AppSettings(
      themeMode: isarSettings.themeMode,
      audioPreset: isarSettings.audioPreset,
      libraryPaths: isarSettings.libraryPaths,
      skipSilence: isarSettings.skipSilence,
      loudnessNormalization: isarSettings.loudnessNormalization,
      playerThemeMode: isarSettings.playerThemeMode,
      showWaveform: isarSettings.showWaveform,
      showCoverReflection: isarSettings.showCoverReflection,
    );
  }

  void _updateIsar(void Function(IsarAppSettings) update) {
    _isar.writeTxnSync(() {
      final settings = _isar.isarAppSettings.getSync(0) ?? IsarAppSettings();
      update(settings);
      _isar.isarAppSettings.putSync(settings);
    });
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _updateIsar((s) => s.themeMode = mode);
  }

  void setAudioPreset(AudioPreset preset) {
    state = state.copyWith(audioPreset: preset);
    _updateIsar((s) => s.audioPreset = preset);

    // Apply filter immediately
    ref.read(mediaServiceProvider).setAudioFilter(preset.filter);
  }

  void setSkipSilence(bool enabled) {
    state = state.copyWith(skipSilence: enabled);
    _updateIsar((s) => s.skipSilence = enabled);
    ref.read(mediaServiceProvider).setSkipSilence(enabled);
  }

  void setLoudnessNormalization(bool enabled) {
    state = state.copyWith(loudnessNormalization: enabled);
    _updateIsar((s) => s.loudnessNormalization = enabled);
    ref.read(mediaServiceProvider).setLoudnessNormalization(enabled);
  }

  void addLibraryPath(String path) {
    if (!state.libraryPaths.contains(path)) {
      final newPaths = [...state.libraryPaths, path];
      state = state.copyWith(libraryPaths: newPaths);
      _updateIsar((s) => s.libraryPaths = newPaths);
    }
  }

  void removeLibraryPath(String path) {
    final newPaths = state.libraryPaths.where((p) => p != path).toList();
    state = state.copyWith(libraryPaths: newPaths);
    _updateIsar((s) => s.libraryPaths = newPaths);
  }

  void setPlayerThemeMode(PlayerThemeMode mode) {
    state = state.copyWith(playerThemeMode: mode);
    _updateIsar((s) => s.playerThemeMode = mode);
  }

  void setShowWaveform(bool enabled) {
    state = state.copyWith(showWaveform: enabled);
    _updateIsar((s) => s.showWaveform = enabled);
  }

  void setShowCoverReflection(bool enabled) {
    state = state.copyWith(showCoverReflection: enabled);
    _updateIsar((s) => s.showCoverReflection = enabled);
  }
}
