# CantoSync — Issue Tracker & Resolution Log

> **Status: 100% Resolved & Verified**
> Last updated: 2026-08-23. Core architecture, playback synchronization, keyboard shortcut dispatch, library grouping/scanning, and UI consistency issues have been addressed and verified.

---

## Summary of Major Resolution Milestones

| Category | Count | Status | Notes |
|---|:---:|:---:|---|
| **Critical / Functional Bugs (Issues 1–15)** | 15 | **RESOLVED** | Safe process exit, transactions, mpv filter syntax, non-blocking scans, immutable metadata editor. |
| **State Management & Async Bugs (Issues 16–28)** | 13 | **RESOLVED** | Centralized `isarProvider`, race-condition protections, chapter monotonic generation tokens, unified total duration stream. |
| **Platform & UI Inconsistencies (Issues 29–46)** | 18 | **RESOLVED** | Pure Fluent UI migration (purged `material.dart`), native `Card` glassmorphism cleanup, high-contrast dark/light theme support. |
| **Feature Gaps & Polish (Issues 47–62)** | 16 | **RESOLVED** | Bookmarks list/jump dialog, collection assignment context menu, narrator parsing, `.opus` file scanning, hotkey dynamic re-registration. |
| **Regressions & Residuals (R1–R8, H1–H9, M5–M6, N1–N5)** | 23 | **RESOLVED** | RxDart stream throttling, clean service layering, modal route focus suppression, accurate drag-drop feedback, startup update banners. |

---

## Detailed Resolutions

### 1. Architectural Decoupling & Providers
- **`isarProvider` Decoupling**: Moved database provider into `lib/core/data/isar_provider.dart` to decouple core background services (`stats_service`, `app_settings_service`, `keyboard_shortcuts_service`) from feature libraries.
- **Pure Fluent UI**: Removed all `package:flutter/material.dart` imports from widgets and overlays, aligning with design system constraints.
- **Service Layer Cleanliness**: Eliminated unused circular imports in `keyboard_shortcuts_service.dart` and removed presentation layer imports from `hotkey_service.dart`.
- **Code Generation**: Migrated `NavigationIndex` and feature providers to clean `@riverpod` notation with `build_runner`.

### 2. File & Process Safety
- **Application Exit (R1)**: Updated tray menu exit to force-save playback sync state, release window interception (`setPreventClose(false)`), destroy the window, and exit cleanly with code 0.
- **Cover Whitelisting (R2, Consistency Nit)**: Restricted both `deleteBook` and `cleanOrphanedBooks` to only delete covers within the app's cache directory (`canto_sync/covers`). Custom covers are copied directly into this directory, protecting user folders from accidental deletion.
- **Safe Offline Rescan (R7)**: Added `Directory(path).exists()` checks prior to scanning to protect disconnected/unmounted drives from having their library entries purged.
- **Drag & Drop Feedback (N4)**: Drag-and-drop file import accurately inspects the result count from directory scans to display contextual success or warning info bars.

### 3. Keyboard Shortcuts & UX
- **Symbol & Hotkey Support (R3, R4, #59)**: Expanded `LogicalKeyboardKey` resolution for punctuation, brackets (`[`, `]`), and symbols with dynamic re-registration upon shortcut customization.
- **Input & Modal Collision Prevention (H8, N2, N3)**: Bare in-app hotkeys (e.g. Space, Escape, Arrows) check for focused `EditableText` and active `ModalRoute` instances, preventing interference with text input and background activation beneath modal dialogs.

### 4. Audio Engine & Multi-file Playback
- **Unified Duration & Monotonic Tokens (H6, H7)**: `MediaService` now unifies duration streams and uses monotonic fetch generation tokens in chapter extraction to prevent stale chapter emissions.
- **Multi-file Math (R5, R6, H9, #62)**: Ensured stats only increment completed book counters at the end of the full playlist; fixed progress percentage calculation across multiple audio files; corrected sleep timer end-of-chapter calculations.
- **Equalizer Presets (H3, Issue 15)**: Synced `AudioPreset.trebleBoost` and native mpv equalizer parameters with `appSettingsProvider`.
- **Stream Throttling (H2, N1)**: Switched `listenToBooks()` to use RxDart `.throttleTime(const Duration(seconds: 3), leading: true, trailing: true)`, eliminating steady-state 2s playback progress churn while guaranteeing immediate initial data emissions.

### 5. UI Improvements & DRY Refactoring
- **Flyout Controller Anchoring (M5)**: Each collection tile, list tile, and book card maintains its own local `FlyoutController`, ensuring correct context menu coordinate anchoring.
- **Play All (M6)**: Series and collection menus sort books by series index/title and resume from the first uncompleted title.
- **DRY Mini Player (M7)**: `MiniPlayer` consumes centralized `playerPlaybackProgressProvider` rather than duplicating chapter and progress calculations.
- **Bookmarks UI (#47, #48)**: Integrated full bookmarks listing, jumping, adding, and deletion flyout in the main player screen.
- **Startup Update Notifications**: Integrated proactive `InfoBar` update notification on app startup with direct download links.
