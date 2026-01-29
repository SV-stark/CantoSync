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
import 'package:canto_sync/core/ui/window_buttons.dart';
import 'package:canto_sync/core/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  // ... existing init code ...

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize MediaKit (Audio/Video Engine)
  MediaKit.ensureInitialized();

  // Initialize Metadata Reader
  MetadataGod.initialize();

  // Initialize Hive (Database)
  await Hive.initFlutter();
  Hive.registerAdapter(BookAdapter());
  Hive.registerAdapter(BookmarkAdapter());

  try {
    await Hive.openBox<Book>(AppConstants.libraryBox);

    // Load System Theme Accent Color & Critical Boxes
    await SystemTheme.accentColor.load();
    await Hive.openBox<Book>(AppConstants.booksBox);
    await Hive.openBox(AppConstants.settingsBox);
  } catch (e) {
    debugPrint('Error opening Hive boxes: $e');
  }

  // Initialize Window Manager
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1000, 700),
    minimumSize: Size(400, 500),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  // Fix: Start UI immediately to prevent deadlock
  runApp(const ProviderScope(child: CantoSyncApp()));

  // Show window asynchronously when ready
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
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
    _initServices();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _initServices() async {
    // Prevent default close, we'll handle it for tray minimization
    await windowManager.setPreventClose(true);

    // Initialize production-grade services
    await ref.read(hotkeyServiceProvider).init();
    await ref.read(trayServiceProvider).init();

    // Check for updates
    _checkUpdates();
  }

  Future<void> _checkUpdates() async {
    final updateInfo = await ref.read(updateServiceProvider).checkForUpdates();
    if (updateInfo != null && mounted) {
      showDialog(
        context: context,
        builder: (context) => ContentDialog(
          title: const Text('Update Available'),
          content: Text(
            'A new version (${updateInfo.latestVersion}) is available. Would you like to download it now?\n\n${updateInfo.releaseNotes ?? ''}',
          ),
          actions: [
            Button(
              child: const Text('Later'),
              onPressed: () => Navigator.pop(context),
            ),
            FilledButton(
              child: const Text('Download'),
              onPressed: () async {
                final url = Uri.parse(updateInfo.downloadUrl);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
                if (!context.mounted) return;
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      await windowManager.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
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
          automaticallyImplyLeading: false,
          actions: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [Spacer(), WindowButtons()],
          ),
        ),
        pane: NavigationPane(
          selected: _index,
          onChanged: (i) => setState(() => _index = i),
          displayMode: PaneDisplayMode.auto,
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
