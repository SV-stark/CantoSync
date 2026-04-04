import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:canto_sync/core/services/media_service.dart';
import 'package:canto_sync/core/services/keyboard_shortcuts_service.dart';
import 'package:canto_sync/core/data/keyboard_shortcuts.dart';

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

    final shortcuts = _ref.read(keyboardShortcutsProvider);
    final playPauseShortcut = shortcuts.firstWhere(
      (s) => s.action == ShortcutAction.playPause,
      orElse: () => shortcuts.first,
    );
    final skipForwardShortcut = shortcuts.firstWhere(
      (s) => s.action == ShortcutAction.skipForward,
      orElse: () => shortcuts.first,
    );
    final skipBackwardShortcut = shortcuts.firstWhere(
      (s) => s.action == ShortcutAction.skipBackward,
      orElse: () => shortcuts.first,
    );

    await _registerHotKeyFromShortcut(
      playPauseShortcut,
      () => _ref.read(mediaServiceProvider).playOrPause(),
    );

    await _registerHotKeyFromShortcut(skipForwardShortcut, () {
      final media = _ref.read(mediaServiceProvider);
      media.seek(media.position + const Duration(seconds: 15));
    });

    await _registerHotKeyFromShortcut(skipBackwardShortcut, () {
      final media = _ref.read(mediaServiceProvider);
      media.seek(media.position - const Duration(seconds: 15));
    });
  }

  Future<void> _registerHotKeyFromShortcut(
    KeyboardShortcut shortcut,
    VoidCallback onDown,
  ) async {
    final logicalKeys = shortcut.logicalKeys;
    if (logicalKeys == null || logicalKeys.isEmpty) return;

    final mainKey = logicalKeys.last;
    final modifiers = <HotKeyModifier>[];
    for (final key in logicalKeys) {
      if (key == LogicalKeyboardKey.control) {
        modifiers.add(HotKeyModifier.control);
      } else if (key == LogicalKeyboardKey.alt) {
        modifiers.add(HotKeyModifier.alt);
      } else if (key == LogicalKeyboardKey.shift) {
        modifiers.add(HotKeyModifier.shift);
      }
    }

    try {
      final hotKey = HotKey(
        key: mainKey,
        modifiers: modifiers,
        scope: HotKeyScope.system,
      );
      await hotKeyManager.register(hotKey, keyDownHandler: (_) => onDown());
    } catch (e) {
      debugPrint('Failed to register hotkey ${shortcut.shortcutString}: $e');
    }
  }

  Future<void> _registerHotKey(HotKey hotKey, VoidCallback onDown) async {
    try {
      await hotKeyManager.register(hotKey, keyDownHandler: (_) => onDown());
    } catch (e) {
      debugPrint('Failed to register hotkey ${hotKey.key}: $e');
    }
  }
}
