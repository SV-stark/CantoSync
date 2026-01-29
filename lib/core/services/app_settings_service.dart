import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:canto_sync/core/services/media_service.dart';

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

  AppSettings({
    this.themeMode = ThemeMode.system,
    this.audioPreset = AudioPreset.flat,
  });

  AppSettings copyWith({ThemeMode? themeMode, AudioPreset? audioPreset}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      audioPreset: audioPreset ?? this.audioPreset,
    );
  }
}

class AppSettingsNotifier extends Notifier<AppSettings> {
  late Box _box;

  @override
  AppSettings build() {
    _box = Hive.box('settings');

    final themeIndex = _box.get(
      'themeMode',
      defaultValue: ThemeMode.system.index,
    );
    final presetIndex = _box.get(
      'audioPreset',
      defaultValue: AudioPreset.flat.index,
    );

    return AppSettings(
      themeMode: ThemeMode.values[themeIndex],
      audioPreset: AudioPreset.values[presetIndex],
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
}

final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);
