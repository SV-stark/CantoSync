import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:canto_sync/core/services/media_service.dart';
import 'package:canto_sync/core/services/keyboard_shortcuts_service.dart';
import 'package:canto_sync/core/data/keyboard_shortcuts.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hotkey_service.g.dart';

@Riverpod(keepAlive: true)
HotkeyService hotkeyService(Ref ref) {
  return HotkeyService(ref);
}

class HotkeyService {
  HotkeyService(this._ref);
  final Ref _ref;

  Future<void> init() async {
    try {
      await hotKeyManager.unregisterAll();
    } catch (e) {
      debugPrint('Error unregistering hotkeys: $e');
    }

    final shortcuts = _ref.read(keyboardShortcutsProvider);

    for (final shortcut in shortcuts) {
      VoidCallback? callback;

      switch (shortcut.action) {
        case ShortcutAction.playPause:
          callback = () => _ref.read(mediaServiceProvider).playOrPause();
          break;
        case ShortcutAction.stop:
          callback = () => _ref.read(mediaServiceProvider).pause();
          break;
        case ShortcutAction.nextTrack:
          callback = () => _ref.read(mediaServiceProvider).nextChapter();
          break;
        case ShortcutAction.previousTrack:
          callback = () => _ref.read(mediaServiceProvider).previousChapter();
          break;
        case ShortcutAction.skipForward:
          callback = () {
            final media = _ref.read(mediaServiceProvider);
            media.seek(media.position + const Duration(seconds: 15));
          };
          break;
        case ShortcutAction.skipBackward:
          callback = () {
            final media = _ref.read(mediaServiceProvider);
            media.seek(media.position - const Duration(seconds: 15));
          };
          break;
        case ShortcutAction.volumeUp:
          callback = () {
            final media = _ref.read(mediaServiceProvider);
            media.setVolume((media.volume + 5).clamp(0, 100));
          };
          break;
        case ShortcutAction.volumeDown:
          callback = () {
            final media = _ref.read(mediaServiceProvider);
            media.setVolume((media.volume - 5).clamp(0, 100));
          };
          break;
        case ShortcutAction.increaseSpeed:
          callback = () {
            final media = _ref.read(mediaServiceProvider);
            media.setRate((media.playRate + 0.1).clamp(0.5, 3.0));
          };
          break;
        case ShortcutAction.decreaseSpeed:
          callback = () {
            final media = _ref.read(mediaServiceProvider);
            media.setRate((media.playRate - 0.1).clamp(0.5, 3.0));
          };
          break;
      }

      if (callback != null) {
        await _registerHotKeyFromShortcut(shortcut, callback);
      }
    }
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
        scope: (modifiers.isNotEmpty || _isMediaKey(mainKey))
            ? HotKeyScope.system
            : HotKeyScope.inapp,
      );
      await hotKeyManager.register(hotKey, keyDownHandler: (_) => onDown());
    } catch (e) {
      debugPrint('Failed to register hotkey ${shortcut.shortcutString}: $e');
    }
  }

  bool _isMediaKey(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.mediaPlay ||
        key == LogicalKeyboardKey.mediaPause ||
        key == LogicalKeyboardKey.mediaPlayPause ||
        key == LogicalKeyboardKey.mediaTrackNext ||
        key == LogicalKeyboardKey.mediaTrackPrevious ||
        key == LogicalKeyboardKey.mediaStop ||
        key == LogicalKeyboardKey.mediaRewind ||
        key == LogicalKeyboardKey.mediaFastForward ||
        key == LogicalKeyboardKey.audioVolumeUp ||
        key == LogicalKeyboardKey.audioVolumeDown ||
        key == LogicalKeyboardKey.audioVolumeMute;
  }
}
