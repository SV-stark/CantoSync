import 'dart:io';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:canto_sync/core/services/media_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:canto_sync/core/utils/logger.dart';

import 'package:canto_sync/core/services/playback_sync_service.dart';

part 'tray_service.g.dart';

@Riverpod(keepAlive: true)
TrayService trayService(Ref ref) {
  return TrayService(ref);
}

class TrayService extends TrayListener {
  TrayService(this._ref);
  final Ref _ref;

  /// Whether a usable tray icon was actually registered. The window's
  /// close-to-tray behaviour depends on this: if the tray failed to
  /// initialise, hiding the window would leave the app unreachable.
  bool _isAvailable = false;

  bool get isAvailable => _isAvailable;

  Future<void> init() async {
    _isAvailable = false;
    if (!Platform.isWindows && !Platform.isLinux) return;
    try {
      trayManager.addListener(this);

      String iconPath = Platform.isWindows
          ? 'assets/app_icon.ico'
          : 'assets/logo.png';

      await trayManager.setIcon(iconPath);

      List<MenuItem> items = [
        MenuItem(key: 'show_window', label: 'Show CantoSync'),
        MenuItem.separator(),
        MenuItem(key: 'play_pause', label: 'Play / Pause'),
        MenuItem.separator(),
        MenuItem(key: 'exit_app', label: 'Exit'),
      ];
      await trayManager.setContextMenu(Menu(items: items));
      _isAvailable = true;
    } catch (e, stack) {
      _isAvailable = false;
      logger.w(
        'Tray initialization failed; close will destroy the window instead '
        'of hiding it',
        error: e,
        stackTrace: stack,
      );
    }
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
  void onTrayMenuItemClick(MenuItem menuItem) async {
    if (menuItem.key == 'show_window') {
      windowManager.show();
      windowManager.focus();
    } else if (menuItem.key == 'play_pause') {
      _ref.read(mediaServiceProvider).playOrPause();
    } else if (menuItem.key == 'exit_app') {
      try {
        await _ref.read(playbackSyncProvider).forceSave();
        await windowManager.setPreventClose(false);
        await windowManager.destroy();
      } catch (e) {
        logger.e('Error during tray exit shutdown', error: e);
      } finally {
        exit(0);
      }
    }
  }
}
