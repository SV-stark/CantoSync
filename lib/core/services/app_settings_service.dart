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

class AppSettings {
  final ThemeMode themeMode;
  final AudioPreset audioPreset;
  final List<String> libraryPaths;

  AppSettings({
    this.themeMode = ThemeMode.system,
    this.audioPreset = AudioPreset.flat,
    this.libraryPaths = const [],
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    AudioPreset? audioPreset,
    List<String>? libraryPaths,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      audioPreset: audioPreset ?? this.audioPreset,
      libraryPaths: libraryPaths ?? this.libraryPaths,
    );
  }
}

class AppSettingsNotifier extends Notifier<AppSettings> {
  late Box _box;

  @override
  AppSettings build() {
    _box = Hive.box(AppConstants.settingsBox);

    final themeIndex = _box.get(
      'themeMode',
      defaultValue: ThemeMode.system.index,
    );
    final presetIndex = _box.get(
      'audioPreset',
      defaultValue: AudioPreset.flat.index,
    );
    final paths = _box.get('libraryPaths', defaultValue: <String>[]);

    return AppSettings(
      themeMode: ThemeMode.values[themeIndex],
      audioPreset: AudioPreset.values[presetIndex],
      libraryPaths: List<String>.from(paths),
    );
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
}

final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);
