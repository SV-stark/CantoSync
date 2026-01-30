import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:media_kit/media_kit.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:canto_sync/features/library/data/book.dart';
import 'package:canto_sync/features/player/ui/player_screen.dart';
import 'package:canto_sync/features/library/ui/library_screen.dart';
import 'package:canto_sync/features/settings/ui/settings_screen.dart';
import 'package:canto_sync/core/services/hotkey_service.dart';
import 'package:canto_sync/core/services/tray_service.dart';
import 'package:canto_sync/core/services/update_service.dart';
import 'package:canto_sync/core/services/app_settings_service.dart';
import 'package:canto_sync/core/services/playback_sync_service.dart';
import 'package:canto_sync/core/ui/window_buttons.dart';
import 'package:canto_sync/core/constants/app_constants.dart';

void main() async {
  // [DEBUG] Start of main
  debugPrint('DEBUG: App starting...');
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('DEBUG: WidgetsFlutterBinding initialized');

  await windowManager.ensureInitialized();
  debugPrint('DEBUG: WindowManager initialized');

  // Best-effort initialization to ensure process doesn't exit silently
  try {
    MediaKit.ensureInitialized();
    debugPrint('DEBUG: MediaKit initialized');

    MetadataGod.initialize();
    debugPrint('DEBUG: MetadataGod initialized');

    await Hive.initFlutter();
    debugPrint('DEBUG: Hive initialized');

    Hive.registerAdapter(BookAdapter());
    Hive.registerAdapter(BookmarkAdapter());

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

    debugPrint('DEBUG: Hive boxes opened');
  } catch (e) {
    debugPrint('Critical Initialization Error: $e');
    // Continue anyway so the user sees a window/UI, even if broken
  }

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1000, 700),
    minimumSize: Size(400, 500),
    center: true,
    backgroundColor: Colors.black,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  // Configure window but don't wait for it to show
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    // We handle showing in initState to ensure Flutter is painting first
    debugPrint('DEBUG: waitUntilReadyToShow callback');
  });

  debugPrint('DEBUG: Running App');
  runApp(const ProviderScope(child: CantoSyncApp()));
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
      debugPrint('DEBUG: PostFrameCallback showing window');
      await windowManager.show();
      await windowManager.focus();
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
      debugPrint('DEBUG: InitServices start');
      // Prevent default close, we'll handle it for tray minimization
      await windowManager.setPreventClose(true);

      // Initialize production-grade services
      await ref.read(hotkeyServiceProvider).init();
      debugPrint('DEBUG: Hotkey initialized');

      await ref.read(trayServiceProvider).init();
      debugPrint('DEBUG: Tray initialized');

      // Check for updates
      _checkUpdates();
    } catch (e) {
      debugPrint('DEBUG: Error in _initServices: $e');
    }
  }

  Future<void> _checkUpdates() async {
    // ... (existing code, seemingly safe)
    try {
      await ref.read(updateServiceProvider).checkForUpdates();
      // ... implementation hidden for brevity
    } catch (e) {
      debugPrint('DEBUG: Update check failed: $e');
    }
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      // Check if we should minimize to tray or actually close
      // For now, let's assume close behavior needs to save data.
      // If the setting is 'minimize to tray', we hide.
      // If 'close app', we save and close.
      // But standard window close button usually triggers this.

      // Let's implement the Safety Fix: Force Save.
      await ref.read(playbackSyncProvider).forceSave();

      // Currently, default behavior in this app seems to be "Hide to tray" on close?
      // "await windowManager.hide();"
      // If so, the app is not terminating, so data is safe in memory.
      // BUT if the user quits via Tray or Taskbar => different flow.
      // If this is the main close event:
      await windowManager.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('DEBUG: Building UI');
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
      home: NavigationView(
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
    );
  }
}
