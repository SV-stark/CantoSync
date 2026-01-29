import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:canto_sync/core/services/media_service.dart';

final hotkeyServiceProvider = Provider<HotkeyService>((ref) {
  return HotkeyService(ref);
});

class HotkeyService {
  final Ref _ref;

  HotkeyService(this._ref);

  Future<void> init() async {
    await hotKeyManager.unregisterAll();

    // Play/Pause: Alt + Space
    await hotKeyManager.register(
      HotKey(
        key: LogicalKeyboardKey.space,
        modifiers: [HotKeyModifier.alt],
        scope: HotKeyScope.system,
      ),
      keyDownHandler: (hotKey) {
        _ref.read(mediaServiceProvider).playOrPause();
      },
    );

    // Skip Forward: Alt + ArrowRight
    await hotKeyManager.register(
      HotKey(
        key: LogicalKeyboardKey.arrowRight,
        modifiers: [HotKeyModifier.alt],
        scope: HotKeyScope.system,
      ),
      keyDownHandler: (hotKey) {
        final media = _ref.read(mediaServiceProvider);
        media.seek(media.position + const Duration(seconds: 15));
      },
    );

    // Skip Backward: Alt + ArrowLeft
    await hotKeyManager.register(
      HotKey(
        key: LogicalKeyboardKey.arrowLeft,
        modifiers: [HotKeyModifier.alt],
        scope: HotKeyScope.system,
      ),
      keyDownHandler: (hotKey) {
        final media = _ref.read(mediaServiceProvider);
        media.seek(media.position - const Duration(seconds: 15));
      },
    );
  }
}
