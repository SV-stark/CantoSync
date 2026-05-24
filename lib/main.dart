import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:media_kit/media_kit.dart';
import 'package:system_theme/system_theme.dart';
import 'package:canto_sync/core/services/app_settings_service.dart';
import 'package:canto_sync/core/services/hotkey_service.dart';
import 'package:canto_sync/core/services/tray_service.dart';
import 'package:canto_sync/core/services/update_service.dart';
import 'package:canto_sync/core/services/playback_sync_service.dart';
import 'package:canto_sync/features/library/data/library_service.dart';
import 'package:canto_sync/features/library/data/book.dart';
import 'package:canto_sync/features/library/ui/library_screen.dart';
import 'package:canto_sync/features/player/ui/player_screen.dart';
import 'package:canto_sync/features/player/ui/widgets/mini_player.dart';
import 'package:canto_sync/features/settings/ui/settings_screen.dart';
import 'package:canto_sync/features/stats/ui/stats_screen.dart';
import 'package:canto_sync/core/ui/window_buttons.dart';
import 'package:canto_sync/core/utils/logger.dart';
import 'package:canto_sync/features/stats/data/listening_stats.dart';
import 'package:canto_sync/core/data/keyboard_shortcuts.dart';
import 'package:canto_sync/core/services/keyboard_shortcuts_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized(libmpv: 'libmpv2.dll');

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 800),
    minimumSize: Size(900, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'CantoSync',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setPreventClose(true);
  });

  final dir = await getApplicationSupportDirectory();
  final isar = await Isar.open([
    BookSchema,
    IsarAppSettingsSchema,
    DailyListeningStatsSchema,
    AuthorStatsSchema,
    BookCompletionStatsSchema,
    ListeningSpeedPreferenceSchema,
    KeyboardShortcutSchema,
  ], directory: dir.path);

  runApp(
    ProviderScope(
      overrides: [isarProvider.overrideWithValue(isar)],
      child: const CantoSyncApp(),
    ),
  );
}

class NavigationIndex extends Notifier<int> {
  @override
  int build() => 0;

  @override
  set state(int i) => super.state = i;
}

final navigationIndexProvider = NotifierProvider<NavigationIndex, int>(
  NavigationIndex.new,
);

class CantoSyncApp extends ConsumerStatefulWidget {
  const CantoSyncApp({super.key});

  @override
  ConsumerState<CantoSyncApp> createState() => _CantoSyncAppState();
}

class _CantoSyncAppState extends ConsumerState<CantoSyncApp>
    with WindowListener {
  bool _servicesInitialized = false;

  void _openLibraryCallback() {
    ref.read(navigationIndexProvider.notifier).state = 0;
  }

  void _openPlayerCallback() {
    ref.read(navigationIndexProvider.notifier).state = 1;
  }

  void _openSettingsCallback() {
    ref.read(navigationIndexProvider.notifier).state = 3;
  }

  void _registerNavigationCallbacks() {
    final notifier = ref.read(shortcutActionCallbacksProvider.notifier);
    notifier.register(ShortcutAction.openLibrary, _openLibraryCallback);
    notifier.register(ShortcutAction.openPlayer, _openPlayerCallback);
    notifier.register(ShortcutAction.openSettings, _openSettingsCallback);
  }

  void _unregisterNavigationCallbacks() {
    final notifier = ref.read(shortcutActionCallbacksProvider.notifier);
    notifier.unregister(ShortcutAction.openLibrary, _openLibraryCallback);
    notifier.unregister(ShortcutAction.openPlayer, _openPlayerCallback);
    notifier.unregister(ShortcutAction.openSettings, _openSettingsCallback);
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _initServices();
    _registerNavigationCallbacks();
  }

  @override
  void dispose() {
    _unregisterNavigationCallbacks();
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _initServices() async {
    if (_servicesInitialized) return;
    _servicesInitialized = true;

    // Hotkeys
    try {
      await ref.read(hotkeyServiceProvider).init();
    } catch (e) {
      logger.e('Error initializing hotkeys', error: e);
    }

    // Tray
    try {
      await ref.read(trayServiceProvider).init();
    } catch (e) {
      logger.e('Error initializing tray', error: e);
    }

    // Playback Sync
    try {
      ref.read(playbackSyncProvider);
    } catch (e) {
      logger.e('Error initializing playback sync', error: e);
    }

    // Library Scan
    try {
      ref.read(libraryServiceProvider).rescanLibraries();
    } catch (e) {
      logger.e('Error starting library rescan', error: e);
    }

    // Updates
    try {
      _checkUpdates();
    } catch (e) {
      logger.e('Error checking for updates', error: e);
    }
  }

  Future<void> _checkUpdates() async {
    try {
      final updateInfo = await ref
          .read(updateServiceProvider)
          .checkForUpdates();
      if (updateInfo != null) {
        logger.i('New version available: ${updateInfo.latestVersion}');
        // In a real app, we'd trigger a global state to show a badge or dialog
      }
    } catch (e) {
      logger.e('Update check failed', error: e);
    }
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      await ref.read(playbackSyncProvider).forceSave();
      await windowManager.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      final settings = ref.watch(appSettingsProvider);
      final index = ref.watch(navigationIndexProvider);

      return FluentApp(
        title: 'CantoSync',
        themeMode: settings.themeMode,
        debugShowCheckedModeBanner: false,
        theme: FluentThemeData(
          accentColor: SystemTheme.accentColor.accent.toAccentColor(),
          visualDensity: VisualDensity.standard,
          focusTheme: FocusThemeData(
            glowFactor: is10footScreen(context) ? 2.0 : 0.0,
          ),
        ),
        darkTheme: FluentThemeData(
          brightness: Brightness.dark,
          accentColor: SystemTheme.accentColor.accent.toAccentColor(),
          visualDensity: VisualDensity.standard,
          focusTheme: FocusThemeData(
            glowFactor: is10footScreen(context) ? 2.0 : 0.0,
          ),
        ),
        home: Stack(
          children: [
            NavigationView(
              titleBar: const TitleBar(
                height: 32,
                title: DragToMoveArea(
                  child: Row(
                    children: [
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Text(
                            'CantoSync',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              pane: NavigationPane(
                selected: index,
                onChanged: (i) =>
                    ref.read(navigationIndexProvider.notifier).state = i,
                displayMode: PaneDisplayMode.compact,
                items: [
                  PaneItem(
                    icon: const Icon(FluentIcons.library),
                    title: const Text('Library'),
                    body: const LibraryScreen(),
                  ),
                  PaneItem(
                    icon: const Icon(FluentIcons.music_in_collection),
                    title: const Text('Player'),
                    body: const PlayerScreen(),
                  ),
                  PaneItem(
                    icon: const Icon(FluentIcons.pie_double),
                    title: const Text('Statistics'),
                    body: const StatsScreen(),
                  ),
                ],
                footerItems: [
                  PaneItem(
                    icon: const Icon(FluentIcons.settings),
                    title: const Text('Settings'),
                    body: const SettingsScreen(),
                  ),
                ],
              ),
            ),
            const Align(
              alignment: Alignment.topRight,
              child: SizedBox(width: 138, height: 32, child: WindowButtons()),
            ),
            if (index != 1)
              Align(
                alignment: Alignment.bottomCenter,
                child: MiniPlayer(
                  onTap: () =>
                      ref.read(navigationIndexProvider.notifier).state = 1,
                ),
              ),
          ],
        ),
      );
    } catch (e, stack) {
      logger.e('UI BUILD ERROR', error: e, stackTrace: stack);
      return Center(child: Text('Fatal UI Error: $e'));
    }
  }
}
