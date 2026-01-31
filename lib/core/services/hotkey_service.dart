import 'package:flutter/foundation.dart';
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
    try {
      await hotKeyManager.unregisterAll();
    } catch (e) {
      debugPrint('Error unregistering hotkeys: $e');
    }

    // Play/Pause: Alt + Space
    await _registerHotKey(
      HotKey(
        key: LogicalKeyboardKey.space,
        modifiers: [HotKeyModifier.alt],
        scope: HotKeyScope.system,
      ),
      () => _ref.read(mediaServiceProvider).playOrPause(),
    );

    // Skip Forward: Alt + ArrowRight
    await _registerHotKey(
      HotKey(
        key: LogicalKeyboardKey.arrowRight,
        modifiers: [HotKeyModifier.alt],
        scope: HotKeyScope.system,
      ),
      () {
        final media = _ref.read(mediaServiceProvider);
        media.seek(media.position + const Duration(seconds: 15));
      },
    );

    // Skip Backward: Alt + ArrowLeft
    await _registerHotKey(
      HotKey(
        key: LogicalKeyboardKey.arrowLeft,
        modifiers: [HotKeyModifier.alt],
        scope: HotKeyScope.system,
      ),
      () {
        final media = _ref.read(mediaServiceProvider);
        media.seek(media.position - const Duration(seconds: 15));
      },
    );

    // Standard Media Keys
    await _registerHotKey(
      HotKey(key: LogicalKeyboardKey.mediaPlayPause, scope: HotKeyScope.system),
      () => _ref.read(mediaServiceProvider).playOrPause(),
    );

    await _registerHotKey(
      HotKey(key: LogicalKeyboardKey.mediaTrackNext, scope: HotKeyScope.system),
      () => _ref.read(mediaServiceProvider).nextChapter(),
    );

    await _registerHotKey(
      HotKey(
        key: LogicalKeyboardKey.mediaTrackPrevious,
        scope: HotKeyScope.system,
      ),
      () => _ref.read(mediaServiceProvider).previousChapter(),
    );
  }

  Future<void> _registerHotKey(HotKey hotKey, VoidCallback onDown) async {
    try {
      await hotKeyManager.register(hotKey, keyDownHandler: (_) => onDown());
    } catch (e) {
      debugPrint('Failed to register hotkey ${hotKey.key}: $e');
    }
  }
}
