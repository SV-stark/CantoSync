import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:canto_sync/core/services/app_settings_service.dart';
import 'package:canto_sync/core/services/update_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:canto_sync/features/library/data/library_service.dart';
import 'package:canto_sync/features/settings/ui/keyboard_shortcuts_screen.dart';

final appVersionProvider = FutureProvider<String>((ref) async {
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    return 'v${packageInfo.version}';
  } catch (e) {
    debugPrint('Error getting app version: $e');
    return 'v1.0.0';
  }
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _pickFolder(WidgetRef ref) async {
    final String? result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      ref.read(appSettingsProvider.notifier).addLibraryPath(result);
      ref.read(libraryServiceProvider).scanDirectory(result);
    }
  }

  Future<void> _rescanAll(BuildContext context, WidgetRef ref) async {
    final paths = ref.read(appSettingsProvider).libraryPaths;
    for (final path in paths) {
      await ref.read(libraryServiceProvider).scanDirectory(path);
    }
    if (!context.mounted) return;
    displayInfoBar(
      context,
      builder: (context, close) {
        return InfoBar(
          title: const Text('Library Scanned'),
          content: const Text('All library folders have been rescanned.'),
          action: IconButton(
            icon: const Icon(FluentIcons.clear),
            onPressed: close,
          ),
          severity: InfoBarSeverity.success,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final appVersionAsync = ref.watch(appVersionProvider);

    return ScaffoldPage.withPadding(
      header: const PageHeader(title: Text('Settings')),
      content: ListView(
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          // Appearance Section
          Expander(
            header: const Text('Appearance'),
            leading: const Icon(FluentIcons.design),
            initiallyExpanded: true,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoLabel(
                  label: 'Theme Mode',
                  child: ComboBox<ThemeMode>(
                    value: settings.themeMode,
                    items: ThemeMode.values.map((mode) {
                      return ComboBoxItem(
                        value: mode,
                        child: Text(mode.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (mode) {
                      if (mode != null) {
                        ref
                            .read(appSettingsProvider.notifier)
                            .setThemeMode(mode);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Audio Section
          Expander(
            header: const Text('Audio'),
            leading: const Icon(FluentIcons.equalizer),
            initiallyExpanded: true,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoLabel(
                  label: 'Default Equalizer Preset',
                  child: ComboBox<AudioPreset>(
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
                ),
                const SizedBox(height: 20),
                ToggleSwitch(
                  checked: settings.skipSilence,
                  onChanged: (v) {
                    ref.read(appSettingsProvider.notifier).setSkipSilence(v);
                  },
                  content: const Text('Silence Skipping'),
                ),
                const SizedBox(height: 10),
                ToggleSwitch(
                  checked: settings.loudnessNormalization,
                  onChanged: (v) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .setLoudnessNormalization(v);
                  },
                  content: const Text('Loudness Normalization'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Library Management Section
          Expander(
            header: const Text('Library Management'),
            leading: const Icon(FluentIcons.library),
            initiallyExpanded: true,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FilledButton(
                      child: const Text('Add Folder'),
                      onPressed: () => _pickFolder(ref),
                    ),
                    const SizedBox(width: 10),
                    Button(
                      child: const Text('Rescan All'),
                      onPressed: () => _rescanAll(context, ref),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                if (settings.libraryPaths.isEmpty)
                  const Text(
                    'No library folders added. Add a folder to scan for audiobooks.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  )
                else
                  Column(
                    children: settings.libraryPaths.map((path) {
                      return ListTile(
                        leading: const Icon(FluentIcons.folder_open),
                        title: Text(path),
                        trailing: IconButton(
                          icon: const Icon(FluentIcons.delete),
                          onPressed: () {
                            ref
                                .read(appSettingsProvider.notifier)
                                .removeLibraryPath(path);
                          },
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Text('Updates', style: FluentTheme.of(context).typography.subtitle),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Application Version'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    appVersionAsync.when(
                      data: (version) => Text(
                        version,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      loading: () => const SizedBox(
                        width: 50,
                        child: ProgressRing(strokeWidth: 2),
                      ),
                      error: (error, _) => const Text(
                        'v1.0.0',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Button(
                      child: const Text('Check for Updates'),
                      onPressed: () async {
                        final updateService = ref.read(updateServiceProvider);
                        // Show progress ring or similar? For now, just wait.
                        final updateInfo = await updateService
                            .checkForUpdates();

                        if (context.mounted) {
                          if (updateInfo != null) {
                            showDialog(
                              context: context,
                              builder: (context) => ContentDialog(
                                title: const Text('Update Available'),
                                content: Text(
                                  'A new version (${updateInfo.latestVersion}) is available.\n\n${updateInfo.releaseNotes ?? ''}',
                                ),
                                actions: [
                                  Button(
                                    child: const Text('Later'),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  FilledButton(
                                    child: const Text('Download'),
                                    onPressed: () async {
                                      final url = Uri.parse(
                                        updateInfo.downloadUrl,
                                      );
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url);
                                      }
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          } else {
                            displayInfoBar(
                              context,
                              builder: (context, close) {
                                return InfoBar(
                                  title: const Text('No Updates'),
                                  content: const Text(
                                    'You are using the latest version of CantoSync.',
                                  ),
                                  severity: InfoBarSeverity.success,
                                  onClose: close,
                                );
                              },
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Keyboard Shortcuts Section
          Expander(
            header: const Text('Keyboard Shortcuts'),
            leading: const Icon(FluentIcons.keyboard_classic),
            initiallyExpanded: false,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(FluentIcons.keyboard_classic),
                  title: const Text('Configure Keyboard Shortcuts'),
                  subtitle: const Text('Customize hotkeys for playback and navigation'),
                  trailing: const Icon(FluentIcons.chevron_right),
                  onPressed: () {
                    Navigator.push(
                      context,
                      FluentPageRoute(
                        builder: (context) => const KeyboardShortcutsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Divider(),
          const SizedBox(height: 20),

          // About Section
          InfoLabel(
            label: 'About CantoSync',
            child: appVersionAsync.when(
              data: (version) => Text(
                '$version\nA production-grade audiobook player built with Flutter & Fluent UI.',
                style: TextStyle(color: Colors.grey),
              ),
              loading: () => const Text(
                'Loading version...\nA production-grade audiobook player built with Flutter & Fluent UI.',
                style: TextStyle(color: Colors.grey),
              ),
              error: (error, _) => Text(
                'v1.0.0\nA production-grade audiobook player built with Flutter & Fluent UI.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
