import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:media_kit/media_kit.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:canto_sync/features/library/data/book.dart';
import 'package:canto_sync/features/player/ui/player_screen.dart';
import 'package:canto_sync/features/library/ui/library_screen.dart';

void main() async {
  // ... existing init code ...

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize MediaKit (Audio/Video Engine)
  MediaKit.ensureInitialized();

  // Initialize Hive (Database)
  await Hive.initFlutter();
  Hive.registerAdapter(BookAdapter());
  await Hive.openBox<Book>('library');

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

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // Load System Theme Accent Color
  await SystemTheme.accentColor.load();

  runApp(const ProviderScope(child: CantoSyncApp()));
}

class CantoSyncApp extends ConsumerWidget {
  const CantoSyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Basic Theme based on System Accent
    final accentColor = SystemTheme.accentColor.accent.toAccentColor();

    return FluentApp(
      title: 'CantoSync',
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      color: accentColor,
      darkTheme: FluentThemeData(
        brightness: Brightness.dark,
        accentColor: accentColor,
        visualDensity: VisualDensity.standard,
        focusTheme: FocusThemeData(
          glowFactor: is10footScreen(context) ? 2.0 : 0.0,
        ),
      ),
      theme: FluentThemeData(
        accentColor: accentColor,
        visualDensity: VisualDensity.standard,
        focusTheme: FocusThemeData(
          glowFactor: is10footScreen(context) ? 2.0 : 0.0,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: const NavigationAppBar(
        title: Text('CantoSync'),
        automaticallyImplyLeading: false,
      ),
      pane: NavigationPane(
        selected: 0,
        onChanged: (index) {},
        displayMode: PaneDisplayMode.auto,
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.library),
            title: const Text('Library'),
            body: const LibraryScreen(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.play),
            title: const Text('Now Playing'),
            body: const PlayerScreen(),
          ),
        ],
        footerItems: [
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text('Settings'),
            body: const Center(child: Text('Settings Content')),
          ),
        ],
      ),
    );
  }
}
