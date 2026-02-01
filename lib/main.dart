import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:media_kit/media_kit.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:canto_sync/features/library/data/book.dart';
import 'package:canto_sync/features/stats/data/listening_stats.dart';
import 'package:canto_sync/core/data/keyboard_shortcuts.dart';
import 'package:canto_sync/features/player/ui/player_screen.dart';
import 'package:canto_sync/features/library/ui/library_screen.dart';
import 'package:canto_sync/features/settings/ui/settings_screen.dart';
import 'package:canto_sync/features/stats/ui/stats_screen.dart';
import 'package:canto_sync/features/player/ui/widgets/mini_player.dart';
import 'package:canto_sync/core/services/hotkey_service.dart';
import 'package:canto_sync/core/services/tray_service.dart';
import 'package:canto_sync/core/services/update_service.dart';
import 'package:canto_sync/core/services/app_settings_service.dart';
import 'package:canto_sync/core/services/playback_sync_service.dart';
import 'package:canto_sync/core/ui/window_buttons.dart';
import 'package:canto_sync/core/constants/app_constants.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        debugPrint('FLUTTER ERROR: ${details.exception}');
        debugPrint('${details.stack}');
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        debugPrint('PLATFORM ERROR: $error');
        debugPrint('$stack');
        return true;
      };

      await windowManager.ensureInitialized();

      try {
        MediaKit.ensureInitialized();
        MetadataGod.initialize();
        final appDir = await getApplicationDocumentsDirectory();
        final cantoSyncDir = Directory(p.join(appDir.path, 'CantoSync'));
        if (!await cantoSyncDir.exists()) {
          await cantoSyncDir.create(recursive: true);
        }
        await Hive.initFlutter(cantoSyncDir.path);

        Hive.registerAdapter(BookAdapter());
        Hive.registerAdapter(BookmarkAdapter());
        Hive.registerAdapter(FileMetadataAdapter());

        // Register stats adapters
        Hive.registerAdapter(DailyListeningStatsAdapter());
        Hive.registerAdapter(AuthorStatsAdapter());
        Hive.registerAdapter(BookCompletionStatsAdapter());
        Hive.registerAdapter(ListeningSpeedPreferenceAdapter());

        // Register keyboard shortcuts adapter
        Hive.registerAdapter(KeyboardShortcutAdapter());

        // Open boxes with corruption recovery
        try {
          await Hive.openBox<Book>(AppConstants.libraryBox);
        } catch (e) {
          debugPrint('Error opening libraryBox: $e. Reseting...');
          await Hive.deleteBoxFromDisk(AppConstants.libraryBox);
          await Hive.openBox<Book>(AppConstants.libraryBox);
        }

        await SystemTheme.accentColor.load();

        try {
          await Hive.openBox<Book>(AppConstants.booksBox);
        } catch (e) {
          debugPrint('Error opening booksBox: $e. Reseting...');
          await Hive.deleteBoxFromDisk(AppConstants.booksBox);
          await Hive.openBox<Book>(AppConstants.booksBox);
        }

        try {
          await Hive.openBox(AppConstants.settingsBox);
        } catch (e) {
          debugPrint('Error opening settingsBox: $e. Reseting...');
          await Hive.deleteBoxFromDisk(AppConstants.settingsBox);
          await Hive.openBox(AppConstants.settingsBox);
        }

        // Open stats boxes with corruption recovery
        try {
          await Hive.openBox<DailyListeningStats>(AppConstants.dailyStatsBox);
        } catch (e) {
          debugPrint('Error opening dailyStatsBox: $e. Reseting...');
          await Hive.deleteBoxFromDisk(AppConstants.dailyStatsBox);
          await Hive.openBox<DailyListeningStats>(AppConstants.dailyStatsBox);
        }

        try {
          await Hive.openBox<AuthorStats>(AppConstants.authorStatsBox);
        } catch (e) {
          debugPrint('Error opening authorStatsBox: $e. Reseting...');
          await Hive.deleteBoxFromDisk(AppConstants.authorStatsBox);
          await Hive.openBox<AuthorStats>(AppConstants.authorStatsBox);
        }

        try {
          await Hive.openBox<BookCompletionStats>(AppConstants.bookStatsBox);
        } catch (e) {
          debugPrint('Error opening bookStatsBox: $e. Reseting...');
          await Hive.deleteBoxFromDisk(AppConstants.bookStatsBox);
          await Hive.openBox<BookCompletionStats>(AppConstants.bookStatsBox);
        }

        try {
          await Hive.openBox<ListeningSpeedPreference>(
            AppConstants.speedStatsBox,
          );
        } catch (e) {
          debugPrint('Error opening speedStatsBox: $e. Reseting...');
          await Hive.deleteBoxFromDisk(AppConstants.speedStatsBox);
          await Hive.openBox<ListeningSpeedPreference>(
            AppConstants.speedStatsBox,
          );
        }

        // Open keyboard shortcuts box with corruption recovery
        try {
          await Hive.openBox<KeyboardShortcut>(
            AppConstants.keyboardShortcutsBox,
          );
        } catch (e) {
          debugPrint('Error opening keyboardShortcutsBox: $e. Reseting...');
          await Hive.deleteBoxFromDisk(AppConstants.keyboardShortcutsBox);
          await Hive.openBox<KeyboardShortcut>(
            AppConstants.keyboardShortcutsBox,
          );
        }
      } catch (e) {
        debugPrint('Critical Initialization Error: $e');
      }

      WindowOptions windowOptions = const WindowOptions(
        size: Size(1000, 700),
        minimumSize: Size(400, 500),
        center: true,
        backgroundColor: Colors.black,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden,
      );

      await windowManager.waitUntilReadyToShow(windowOptions);
      runApp(const ProviderScope(child: CantoSyncApp()));
    },
    (error, stack) {
      debugPrint('CRITICAL GLOBAL ERROR: $error');
      debugPrint('$stack');
    },
  );
}

class CantoSyncApp extends ConsumerStatefulWidget {
  const CantoSyncApp({super.key});

  @override
  ConsumerState<CantoSyncApp> createState() => _CantoSyncAppState();
}

class _CantoSyncAppState extends ConsumerState<CantoSyncApp>
    with WindowListener {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);

    // Force show window once the frame is definitely ready
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await windowManager.show();
        await windowManager.focus();
      } catch (e) {
        debugPrint('Error showing window: $e');
      }
    });

    _initServices();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _initServices() async {
    try {
      await windowManager.setPreventClose(true);
      await ref.read(hotkeyServiceProvider).init();
      await ref.read(trayServiceProvider).init();
      _checkUpdates();
    } catch (e) {
      debugPrint('Error in _initServices: $e');
    }
  }

  Future<void> _checkUpdates() async {
    try {
      await ref.read(updateServiceProvider).checkForUpdates();
    } catch (e) {
      debugPrint('Update check failed: $e');
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
        home: Column(
          children: [
            Expanded(
              child: NavigationView(
                appBar: const NavigationAppBar(
                  title: DragToMoveArea(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text('CantoSync'),
                    ),
                  ),
                  automaticallyImplyLeading: true,
                  actions: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [Spacer(), WindowButtons()],
                  ),
                ),
                pane: NavigationPane(
                  selected: _index,
                  onChanged: (i) => setState(() => _index = i),
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
            ),
            if (_index != 1)
              MiniPlayer(onTap: () => setState(() => _index = 1)),
          ],
        ),
      );
    } catch (e, stack) {
      debugPrint('UI BUILD ERROR: $e');
      debugPrint('$stack');
      return Center(child: Text('Fatal UI Error: $e'));
    }
  }
}
