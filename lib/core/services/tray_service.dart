import 'dart:io';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:canto_sync/core/services/media_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tray_service.g.dart';

@Riverpod(keepAlive: true)
TrayService trayService(Ref ref) {
  return TrayService(ref);
}

class TrayService extends TrayListener {

  TrayService(this._ref);
  final Ref _ref;

  Future<void> init() async {
    trayManager.addListener(this);

    // Set tray icon (using the same logo.png we updated earlier)
    String iconPath = Platform.isWindows
        ? 'assets/app_icon.ico'
        : 'assets/logo.png';
    // Note: tray_manager on Windows needs an .ico usually or a png in the actual assets folder
    // But it can load from file system if path is absolute or from assets.
    // For now we'll use the relative path which tray_manager handles if in pubspec.

    await trayManager.setIcon(iconPath);

    List<MenuItem> items = [
      MenuItem(key: 'show_window', label: 'Show CantoSync'),
      MenuItem.separator(),
      MenuItem(key: 'play_pause', label: 'Play / Pause'),
      MenuItem.separator(),
      MenuItem(key: 'exit_app', label: 'Exit'),
    ];
    await trayManager.setContextMenu(Menu(items: items));
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
    windowManager.focus();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'show_window') {
      windowManager.show();
      windowManager.focus();
    } else if (menuItem.key == 'play_pause') {
      _ref.read(mediaServiceProvider).playOrPause();
    } else if (menuItem.key == 'exit_app') {
      exit(0);
    }
  }
}
