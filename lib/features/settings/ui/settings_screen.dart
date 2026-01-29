import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canto_sync/core/services/app_settings_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return ScaffoldPage.withPadding(
      header: const PageHeader(title: Text('Settings')),
      content: ListView(
        children: [
          Text(
            'Appearance',
            style: FluentTheme.of(context).typography.subtitle,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Theme Mode'),
                const SizedBox(height: 8),
                ComboBox<ThemeMode>(
                  value: settings.themeMode,
                  items: ThemeMode.values.map((mode) {
                    return ComboBoxItem(
                      value: mode,
                      child: Text(mode.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (mode) {
                    if (mode != null) {
                      ref.read(appSettingsProvider.notifier).setThemeMode(mode);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Text('Audio', style: FluentTheme.of(context).typography.subtitle),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Default Equalizer Preset'),
                const SizedBox(height: 8),
                ComboBox<AudioPreset>(
                  value: settings.audioPreset,
                  items: AudioPreset.values.map((preset) {
                    return ComboBoxItem(
                      value: preset,
                      child: Text(preset.label),
                    );
                  }).toList(),
                  onChanged: (preset) {
                    if (preset != null) {
                      ref
                          .read(appSettingsProvider.notifier)
                          .setAudioPreset(preset);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Divider(),
          const SizedBox(height: 20),
          const Text(
            'About CantoSync',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text('Version 1.0.0'),
          const Text(
            'A production-grade audiobook player built with Flutter & Fluent UI.',
          ),
        ],
      ),
    );
  }
}
