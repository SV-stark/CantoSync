import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

part 'keyboard_shortcuts.g.dart';

  @HiveType(typeId: 7)
class KeyboardShortcut extends HiveObject {
  @HiveField(0)
  String action;

  @HiveField(1)
  String keyValue;

  @HiveField(2)
  bool ctrl;

  @HiveField(3)
  bool alt;

  @HiveField(4)
  bool shift;

  @HiveField(5)
  String description;

  KeyboardShortcut({
    required this.action,
    required this.keyValue,
    this.ctrl = false,
    this.alt = false,
    this.shift = false,
    required this.description,
  });

  String get shortcutString {
    final parts = <String>[];
    if (ctrl) parts.add('Ctrl');
    if (alt) parts.add('Alt');
    if (shift) parts.add('Shift');
    parts.add(keyValue);
    return parts.join('+');
  }

  Set<LogicalKeyboardKey>? get logicalKeys {
    final keys = <LogicalKeyboardKey>[];
    if (ctrl) keys.add(LogicalKeyboardKey.control);
    if (alt) keys.add(LogicalKeyboardKey.alt);
    if (shift) keys.add(LogicalKeyboardKey.shift);

    final mainKey = _getLogicalKey(keyValue);
    if (mainKey != null) {
      keys.add(mainKey);
      return keys.toSet();
    }
    return null;
  }

  LogicalKeyboardKey? _getLogicalKey(String key) {
    final keyMap = {
      'Space': LogicalKeyboardKey.space,
      'Enter': LogicalKeyboardKey.enter,
      'Escape': LogicalKeyboardKey.escape,
      'Tab': LogicalKeyboardKey.tab,
      'ArrowUp': LogicalKeyboardKey.arrowUp,
      'ArrowDown': LogicalKeyboardKey.arrowDown,
      'ArrowLeft': LogicalKeyboardKey.arrowLeft,
      'ArrowRight': LogicalKeyboardKey.arrowRight,
      'Home': LogicalKeyboardKey.home,
      'End': LogicalKeyboardKey.end,
      'PageUp': LogicalKeyboardKey.pageUp,
      'PageDown': LogicalKeyboardKey.pageDown,
      'Insert': LogicalKeyboardKey.insert,
      'Delete': LogicalKeyboardKey.delete,
      'Backspace': LogicalKeyboardKey.backspace,
      'F1': LogicalKeyboardKey.f1,
      'F2': LogicalKeyboardKey.f2,
      'F3': LogicalKeyboardKey.f3,
      'F4': LogicalKeyboardKey.f4,
      'F5': LogicalKeyboardKey.f5,
      'F6': LogicalKeyboardKey.f6,
      'F7': LogicalKeyboardKey.f7,
      'F8': LogicalKeyboardKey.f8,
      'F9': LogicalKeyboardKey.f9,
      'F10': LogicalKeyboardKey.f10,
      'F11': LogicalKeyboardKey.f11,
      'F12': LogicalKeyboardKey.f12,
      'MediaPlayPause': LogicalKeyboardKey.mediaPlay,
      'MediaStop': LogicalKeyboardKey.mediaStop,
      'MediaTrackNext': LogicalKeyboardKey.mediaTrackNext,
      'MediaTrackPrevious': LogicalKeyboardKey.mediaTrackPrevious,
      'MediaRewind': LogicalKeyboardKey.mediaRewind,
      'MediaFastForward': LogicalKeyboardKey.mediaFastForward,
      'VolumeUp': LogicalKeyboardKey.audioVolumeUp,
      'VolumeDown': LogicalKeyboardKey.audioVolumeDown,
      'VolumeMute': LogicalKeyboardKey.audioVolumeMute,
    };

    if (keyMap.containsKey(key)) {
      return keyMap[key];
    }

    // Single character keys
    if (key.length == 1) {
      final codePoint = key.codeUnitAt(0);
      if (codePoint >= 65 && codePoint <= 90) {
        // A-Z
        return LogicalKeyboardKey(0x00070004 + (codePoint - 65));
      } else if (codePoint >= 48 && codePoint <= 57) {
        // 0-9
        return LogicalKeyboardKey(0x0007001e + (codePoint - 48));
      }
    }

    return null;
  }
}

class ShortcutAction {
  static const String playPause = 'play_pause';
  static const String stop = 'stop';
  static const String nextTrack = 'next_track';
  static const String previousTrack = 'previous_track';
  static const String skipForward = 'skip_forward';
  static const String skipBackward = 'skip_backward';
  static const String volumeUp = 'volume_up';
  static const String volumeDown = 'volume_down';
  static const String volumeMute = 'volume_mute';
  static const String toggleFullscreen = 'toggle_fullscreen';
  static const String increaseSpeed = 'increase_speed';
  static const String decreaseSpeed = 'decrease_speed';
  static const String toggleSleepTimer = 'toggle_sleep_timer';
  static const String addBookmark = 'add_bookmark';
  static const String openLibrary = 'open_library';
  static const String openPlayer = 'open_player';
  static const String openSettings = 'open_settings';
  static const String focusSearch = 'focus_search';
  static const String toggleViewMode = 'toggle_view_mode';

  static const Map<String, String> descriptions = {
    playPause: 'Play/Pause',
    stop: 'Stop',
    nextTrack: 'Next Track/Chapter',
    previousTrack: 'Previous Track/Chapter',
    skipForward: 'Skip Forward 15s',
    skipBackward: 'Skip Backward 15s',
    volumeUp: 'Volume Up',
    volumeDown: 'Volume Down',
    volumeMute: 'Mute',
    toggleFullscreen: 'Toggle Fullscreen',
    increaseSpeed: 'Increase Playback Speed',
    decreaseSpeed: 'Decrease Playback Speed',
    toggleSleepTimer: 'Toggle Sleep Timer',
    addBookmark: 'Add Bookmark',
    openLibrary: 'Open Library',
    openPlayer: 'Open Player',
    openSettings: 'Open Settings',
    focusSearch: 'Focus Search',
    toggleViewMode: 'Toggle View Mode',
  };
}

List<KeyboardShortcut> getDefaultShortcuts() {
  return [
    KeyboardShortcut(
      action: ShortcutAction.playPause,
      keyValue: 'Space',
      description: ShortcutAction.descriptions[ShortcutAction.playPause]!,
    ),
    KeyboardShortcut(
      action: ShortcutAction.stop,
      keyValue: 'Escape',
      description: ShortcutAction.descriptions[ShortcutAction.stop]!,
    ),
    KeyboardShortcut(
      action: ShortcutAction.nextTrack,
      keyValue: 'ArrowRight',
      description: ShortcutAction.descriptions[ShortcutAction.nextTrack]!,
    ),
    KeyboardShortcut(
      action: ShortcutAction.previousTrack,
      keyValue: 'ArrowLeft',
      description: ShortcutAction.descriptions[ShortcutAction.previousTrack]!,
    ),
    KeyboardShortcut(
      action: ShortcutAction.skipForward,
      keyValue: 'ArrowRight',
      shift: true,
      description: ShortcutAction.descriptions[ShortcutAction.skipForward]!,
    ),
    KeyboardShortcut(
      action: ShortcutAction.skipBackward,
      keyValue: 'ArrowLeft',
      shift: true,
      description: ShortcutAction.descriptions[ShortcutAction.skipBackward]!,
    ),
    KeyboardShortcut(
      action: ShortcutAction.volumeUp,
      keyValue: 'ArrowUp',
      description: ShortcutAction.descriptions[ShortcutAction.volumeUp]!,
    ),
    KeyboardShortcut(
      action: ShortcutAction.volumeDown,
      keyValue: 'ArrowDown',
      description: ShortcutAction.descriptions[ShortcutAction.volumeDown]!,
    ),
    KeyboardShortcut(
      action: ShortcutAction.volumeMute,
      keyValue: 'M',
      ctrl: true,
      description: ShortcutAction.descriptions[ShortcutAction.volumeMute]!,
    ),
    KeyboardShortcut(
      action: ShortcutAction.increaseSpeed,
      keyValue: ']',
      description: ShortcutAction.descriptions[ShortcutAction.increaseSpeed]!,
    ),
    KeyboardShortcut(
      action: ShortcutAction.decreaseSpeed,
      keyValue: '[',
      description: ShortcutAction.descriptions[ShortcutAction.decreaseSpeed]!,
    ),
    KeyboardShortcut(
      action: ShortcutAction.toggleSleepTimer,
      keyValue: 'T',
      ctrl: true,
      description:
          ShortcutAction.descriptions[ShortcutAction.toggleSleepTimer]!,
    ),
    KeyboardShortcut(
      action: ShortcutAction.addBookmark,
      keyValue: 'B',
      ctrl: true,
      description: ShortcutAction.descriptions[ShortcutAction.addBookmark]!,
    ),
    KeyboardShortcut(
      action: ShortcutAction.openLibrary,
      keyValue: '1',
      ctrl: true,
      description: ShortcutAction.descriptions[ShortcutAction.openLibrary]!,
    ),
    KeyboardShortcut(
      action: ShortcutAction.openPlayer,
      keyValue: '2',
      ctrl: true,
      description: ShortcutAction.descriptions[ShortcutAction.openPlayer]!,
    ),
    KeyboardShortcut(
      action: ShortcutAction.openSettings,
      keyValue: '3',
      ctrl: true,
      description: ShortcutAction.descriptions[ShortcutAction.openSettings]!,
    ),
    KeyboardShortcut(
      action: ShortcutAction.focusSearch,
      keyValue: 'F',
      ctrl: true,
      description: ShortcutAction.descriptions[ShortcutAction.focusSearch]!,
    ),
    KeyboardShortcut(
      action: ShortcutAction.toggleViewMode,
      keyValue: 'V',
      ctrl: true,
      description: ShortcutAction.descriptions[ShortcutAction.toggleViewMode]!,
    ),
  ];
}
