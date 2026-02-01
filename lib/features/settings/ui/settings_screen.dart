import 'dart:ui';
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

final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return await PackageInfo.fromPlatform();
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

    return ScaffoldPage.withPadding(
      header: const PageHeader(
        title: Text('Settings'),
      ),
      content: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // Appearance Section
          _buildSectionCard(
            context,
            icon: FluentIcons.design,
            iconColor: Colors.blue,
            title: 'Appearance',
            subtitle: 'Customize the look and feel of CantoSync',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSettingItem(
                  context,
                  title: 'Theme Mode',
                  subtitle: 'Choose your preferred color theme',
                  child: ComboBox<ThemeMode>(
                    value: settings.themeMode,
                    items: ThemeMode.values.map((mode) {
                      final String label = switch (mode) {
                        ThemeMode.system => 'System',
                        ThemeMode.light => 'Light',
                        ThemeMode.dark => 'Dark',
                      };
                      return ComboBoxItem(
                        value: mode,
                        child: Text(label),
                      );
                    }).toList(),
                    onChanged: (mode) {
                      if (mode != null) {
                        ref.read(appSettingsProvider.notifier).setThemeMode(mode);
                      }
                    },
                  ),
                ),
                const Divider(),
                _buildSettingItem(
                  context,
                  title: 'Player Theme',
                  subtitle: 'Choose the player background style',
                  child: ComboBox<PlayerThemeMode>(
                    value: settings.playerThemeMode,
                    items: PlayerThemeMode.values.map((mode) {
                      return ComboBoxItem(
                        value: mode,
                        child: Text(mode.label),
                      );
                    }).toList(),
                    onChanged: (mode) {
                      if (mode != null) {
                        ref.read(appSettingsProvider.notifier).setPlayerThemeMode(mode);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Audio Section
          _buildSectionCard(
            context,
            icon: FluentIcons.equalizer,
            iconColor: Colors.purple,
            title: 'Audio',
            subtitle: 'Configure sound settings and effects',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSettingItem(
                  context,
                  title: 'Equalizer Preset',
                  subtitle: 'Default audio equalization profile',
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
                        ref.read(appSettingsProvider.notifier).setAudioPreset(preset);
                      }
                    },
                  ),
                ),
                const Divider(),
                _buildToggleItem(
                  context,
                  title: 'Silence Skipping',
                  subtitle: 'Automatically skip silent sections in audio',
                  icon: FluentIcons.forward,
                  value: settings.skipSilence,
                  onChanged: (v) {
                    ref.read(appSettingsProvider.notifier).setSkipSilence(v);
                  },
                ),
                const Divider(),
                _buildToggleItem(
                  context,
                  title: 'Loudness Normalization',
                  subtitle: 'Normalize audio volume across different books',
                  icon: FluentIcons.volume2,
                  value: settings.loudnessNormalization,
                  onChanged: (v) {
                    ref.read(appSettingsProvider.notifier).setLoudnessNormalization(v);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Player Display Section
          _buildSectionCard(
            context,
            icon: FluentIcons.play,
            iconColor: Colors.orange,
            title: 'Player Display',
            subtitle: 'Customize the audio player visual elements',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildToggleItem(
                  context,
                  title: 'Show Waveform',
                  subtitle: 'Display audio waveform visualization in player',
                  icon: FluentIcons.area_chart,
                  value: settings.showWaveform,
                  onChanged: (v) {
                    ref.read(appSettingsProvider.notifier).setShowWaveform(v);
                  },
                ),
                const Divider(),
                _buildToggleItem(
                  context,
                  title: 'Cover Art Reflection',
                  subtitle: 'Show reflective effect below album artwork',
                  icon: FluentIcons.photo2,
                  value: settings.showCoverReflection,
                  onChanged: (v) {
                    ref.read(appSettingsProvider.notifier).setShowCoverReflection(v);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Library Management Section
          _buildSectionCard(
            context,
            icon: FluentIcons.library,
            iconColor: Colors.green,
            title: 'Library Management',
            subtitle: 'Manage your audiobook collection folders',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FilledButton(
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(FluentIcons.add, size: 16),
                          SizedBox(width: 8),
                          Text('Add Folder'),
                        ],
                      ),
                      onPressed: () => _pickFolder(ref),
                    ),
                    const SizedBox(width: 12),
                    Button(
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(FluentIcons.refresh, size: 16),
                          SizedBox(width: 8),
                          Text('Rescan All'),
                        ],
                      ),
                      onPressed: () => _rescanAll(context, ref),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (settings.libraryPaths.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(FluentIcons.info, color: Colors.grey, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No library folders added. Add a folder to scan for audiobooks.',
                            style: FluentTheme.of(context).typography.body?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: settings.libraryPaths.map((path) {
                      return _buildLibraryPathItem(context, ref, path);
                    }).toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Keyboard Shortcuts Section
          _buildSectionCard(
            context,
            icon: FluentIcons.keyboard_classic,
            iconColor: Colors.teal,
            title: 'Keyboard Shortcuts',
            subtitle: 'Customize hotkeys for quick control',
            child: HoverButton(
              onPressed: () {
                Navigator.push(
                  context,
                  FluentPageRoute(
                    builder: (context) => const KeyboardShortcutsScreen(),
                  ),
                );
              },
              builder: (context, states) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: states.isHovered
                        ? FluentTheme.of(context).accentColor.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: states.isHovered
                          ? FluentTheme.of(context).accentColor.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          FluentIcons.keyboard_classic,
                          color: Colors.teal,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Configure Shortcuts',
                              style: FluentTheme.of(context).typography.body?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Customize hotkeys for playback and navigation',
                              style: FluentTheme.of(context).typography.caption?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        FluentIcons.chevron_right,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Updates Section
          _buildSectionCard(
            context,
            icon: FluentIcons.update_restore,
            iconColor: Colors.blue,
            title: 'Updates',
            subtitle: 'Check for new versions of CantoSync',
            child: Consumer(
              builder: (context, ref, child) {
                final appVersionAsync = ref.watch(appVersionProvider);
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: appVersionAsync.when(
                        data: (version) => Text(
                          version,
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        loading: () => const SizedBox(
                          width: 50,
                          child: ProgressRing(strokeWidth: 2),
                        ),
                        error: (error, _) => Text(
                          'v1.0.0',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Button(
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(FluentIcons.download, size: 16),
                          SizedBox(width: 8),
                          Text('Check for Updates'),
                        ],
                      ),
                      onPressed: () async {
                        final updateService = ref.read(updateServiceProvider);
                        final updateInfo = await updateService.checkForUpdates();

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
                );
              },
            ),
          ),
          const SizedBox(height: 40),

          // About Section
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: iconColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: FluentTheme.of(context).typography.subtitle?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: FluentTheme.of(context).typography.caption?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FluentTheme.of(context).typography.body?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: FluentTheme.of(context).typography.caption?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return HoverButton(
      onPressed: () => onChanged(!value),
      builder: (context, states) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: states.isHovered
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: value
                      ? FluentTheme.of(context).accentColor.withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: value
                      ? FluentTheme.of(context).accentColor
                      : Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: FluentTheme.of(context).typography.body?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: FluentTheme.of(context).typography.caption?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              ToggleSwitch(
                checked: value,
                onChanged: onChanged,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLibraryPathItem(BuildContext context, WidgetRef ref, String path) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              FluentIcons.folder_open,
              color: Colors.green,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              path,
              style: FluentTheme.of(context).typography.body?.copyWith(
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              FluentIcons.delete,
              color: Colors.red.withValues(alpha: 0.7),
              size: 18,
            ),
            onPressed: () {
              ref.read(appSettingsProvider.notifier).removeLibraryPath(path);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final appVersionAsync = ref.watch(appVersionProvider);
        final packageInfoAsync = ref.watch(packageInfoProvider);

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    FluentTheme.of(context).accentColor.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: FluentTheme.of(context).accentColor.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header with logo area
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: FluentTheme.of(context).accentColor.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        // App Icon Placeholder
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                FluentTheme.of(context).accentColor,
                                FluentTheme.of(context).accentColor.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: FluentTheme.of(context).accentColor.withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              FluentIcons.play_resume,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'CantoSync',
                          style: FluentTheme.of(context).typography.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        appVersionAsync.when(
                          data: (version) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: FluentTheme.of(context).accentColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: FluentTheme.of(context).accentColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              version,
                              style: TextStyle(
                                color: FluentTheme.of(context).accentColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          loading: () => const ProgressRing(strokeWidth: 2),
                          error: (error, stackTrace) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: FluentTheme.of(context).accentColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'v1.0.0',
                              style: TextStyle(
                                color: FluentTheme.of(context).accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'A production-grade audiobook player built with Flutter & Fluent UI',
                          style: FluentTheme.of(context).typography.body?.copyWith(
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // Links and Info
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildAboutLink(
                          context,
                          icon: FluentIcons.code,
                          title: 'GitHub Repository',
                          subtitle: 'View source code and contribute',
                          url: 'https://github.com/anomalyco/cantosync',
                        ),
                        const SizedBox(height: 12),
                        _buildAboutLink(
                          context,
                          icon: FluentIcons.globe,
                          title: 'Website',
                          subtitle: 'Visit our official website',
                          url: 'https://cantosync.app',
                        ),
                        const SizedBox(height: 12),
                        _buildAboutLink(
                          context,
                          icon: FluentIcons.issue_tracking,
                          title: 'Report an Issue',
                          subtitle: 'Help us improve by reporting bugs',
                          url: 'https://github.com/anomalyco/cantosync/issues',
                        ),
                        const Divider(),
                        // Build Info
                        packageInfoAsync.when(
                          data: (info) => Wrap(
                            spacing: 20,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildBuildInfoItem(context, 'Build', info.buildNumber),
                              _buildBuildInfoItem(context, 'Package', info.packageName.split('.').last),
                              _buildBuildInfoItem(context, 'Framework', 'Flutter'),
                            ],
                          ),
                          loading: () => const ProgressRing(strokeWidth: 2),
                          error: (error, stackTrace) => Wrap(
                            spacing: 20,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildBuildInfoItem(context, 'Build', 'Unknown'),
                              _buildBuildInfoItem(context, 'Framework', 'Flutter'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '© 2026 CantoSync. All rights reserved.',
                          style: FluentTheme.of(context).typography.caption?.copyWith(
                            color: Colors.grey.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAboutLink(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String url,
  }) {
    return HoverButton(
      onPressed: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      builder: (context, states) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: states.isHovered
                ? FluentTheme.of(context).accentColor.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: states.isHovered
                  ? FluentTheme.of(context).accentColor.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: FluentTheme.of(context).accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: FluentTheme.of(context).accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: FluentTheme.of(context).typography.body?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: FluentTheme.of(context).typography.caption?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                FluentIcons.open_in_new_window,
                color: Colors.grey,
                size: 16,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBuildInfoItem(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: FluentTheme.of(context).typography.caption?.copyWith(
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: FluentTheme.of(context).typography.caption?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
