# CantoSync — Issue Tracker

> Generated from full codebase analysis on 2026-05-19. Covers all 36 source `.dart` files across `lib/`.

---

## Critical / Functional Bugs (15)

### Issue 1: Empty `writeTxnSync` block in `MediaService._init()`
- **File**: `lib/core/services/media_service.dart:38`
- **Severity**: Critical
- **Description**: The `_init()` catch block calls `_ref.read(isarProvider).writeTxnSync()` with an empty body. This is a no-op and may throw if Isar isn't ready during initialization.
- **Fix**: Remove the empty transaction block or add actual error-logging logic inside it.

### Issue 2: `_recordStatsSession` marked `async` but return type is `void`
- **File**: `lib/core/services/playback_sync_service.dart:86`
- **Severity**: Critical
- **Description**: Method signature is `void _recordStatsSession(int seconds) async`. Since it uses `await`, it should return `Future<void>`. The current signature means callers cannot await completion.
- **Fix**: Change signature to `Future<void> _recordStatsSession(int seconds) async`.

### Issue 3: `dispose()` has unawaited async `updateProgress`
- **File**: `lib/core/services/playback_sync_service.dart:341-348`
- **Severity**: Critical
- **Description**: The best-effort save in `dispose()` calls `_libraryService.updateProgress(...)` without `await`. The save may never complete before the service is torn down, causing lost playback progress.
- **Fix**: Add `await` before the call. Note: `dispose` can't be async, so use `unawaited()` with a comment or make it `Future<void> dispose()` if the lifecycle permits.

### Issue 4: Lazy `_p` getter can cause infinite recursion
- **File**: `lib/core/services/media_service.dart:26-31`
- **Severity**: Critical
- **Description**: If `_player` is null, `_init()` is called. If `_init()` fails (catches the exception), `_player` stays null. The next access to `_p` calls `_init()` again, potentially creating an infinite loop or repeated failures.
- **Fix**: Add a `_initFailed` flag to prevent re-initialization after a failure, or throw on subsequent accesses.

### Issue 5: Stream getters use `_p` which can throw if uninitialized
- **File**: `lib/core/services/media_service.dart:50-55`
- **Severity**: Critical
- **Description**: All stream getters (`playingStream`, `positionStream`, `durationStream`, `volumeStream`, `playlistStream`, `completedStream`) access `_p` directly. If `_player` was never initialized successfully, every access throws.
- **Fix**: Return empty/error streams or `Stream.empty()` when `_player` is null, or guard each getter with a null check.

### Issue 6: `rescanLibraries` creates a raw `Player` bypassing `MediaService`
- **File**: `lib/features/library/data/library_service.dart:161`
- **Severity**: Critical
- **Description**: `rescanLibraries` instantiates `Player(configuration: const PlayerConfiguration(vo: 'null'))` directly. This bypasses the service layer and can crash if `media_kit` isn't initialized yet.
- **Fix**: Ensure `MediaKit.ensureInitialized()` is called before this, or use a shared probe player from `MediaService`.

### Issue 7: `mini_player.dart` imports `material.dart`
- **File**: `lib/features/player/ui/widgets/mini_player.dart:3`
- **Severity**: Critical
- **Description**: Violates AGENTS.md rule: "Do not mix in Material widgets." Uses `material.RenderBox` and `material.TextPainter` for marquee text measurement.
- **Fix**: Import `package:flutter/rendering.dart` instead, or use `dart:ui` equivalents.

### Issue 8: "Stop" action calls `pause()` instead of stopping
- **File**: `lib/core/services/hotkey_service.dart:37`
- **Severity**: High
- **Description**: `ShortcutAction.stop` callback calls `mediaServiceProvider.pause()` which only pauses playback, not stops it. The action is misleading.
- **Fix**: Either implement actual stop (seek to 0 + pause) or rename the action to "Pause".

### Issue 9: Bookmark timestamp double-counts chapter start time
- **File**: `lib/features/player/ui/player_screen.dart:758-767`
- **Severity**: High
- **Description**: `globalPositionSecondsWrapper` adds `currentChapter.startTime` to the position. But the `position` Duration passed from the slider may already include chapter offset depending on context, causing double-counting for multi-file books.
- **Fix**: Clarify whether the incoming `pos` is local or global, and only add chapter offset when it's local.

### Issue 10: `scanDirectory` runs on main isolate
- **File**: `lib/features/library/data/library_service.dart:263-307`
- **Severity**: High
- **Description**: Full recursive filesystem scanning with metadata parsing is I/O-bound. Per AGENTS.md section 8, this should run in `Isolate.run()` or `compute()` to avoid blocking the UI thread.
- **Fix**: Wrap `_scanDirectory` body in `Isolate.run()` or `compute()`.

### Issue 11: Sequential metadata parsing in loop
- **File**: `lib/features/library/data/library_service.dart:405-433`
- **Severity**: High
- **Description**: For multi-file books, each file's metadata is parsed sequentially with `await parseFile()`. Should be batched with `Future.wait()` for parallelism.
- **Fix**: Map all files to futures and use `await Future.wait(futures)`.

### Issue 12: Position listener fires on every tick, running stats on each
- **File**: `lib/core/services/playback_sync_service.dart:50-72`
- **Severity**: High
- **Description**: The position stream fires multiple times per second. While debouncing helps the save, the stats delta calculation runs on every tick too.
- **Fix**: Throttle the stats calculation separately, or batch it on a timer independent of position events.

### Issue 13: `exit(0)` bypasses cleanup
- **File**: `lib/core/services/tray_service.dart:60`
- **Severity**: Critical
- **Description**: Calling `exit(0)` from the tray menu doesn't trigger `dispose()` on services, meaning playback position may not be saved.
- **Fix**: Call `playbackSyncProvider.forceSave()` before `exit(0)`, or use `windowManager.close()` to trigger the close handler.

### Issue 14: `Book.lastPlayed` set in constructor even if never played
- **File**: `lib/features/library/data/book.dart:28`
- **Severity**: Medium
- **Description**: `lastPlayed ??= DateTime.now()` means a book gets a "last played" timestamp when created during a scan, even if the user has never opened it.
- **Fix**: Remove the default assignment in the constructor. Set `lastPlayed` only when playback actually starts.

### Issue 15: EQ dialog uses `lavfi=` filter syntax incompatible with mpv `af`
- **File**: `lib/features/player/ui/player_screen.dart:697`
- **Severity**: High
- **Description**: The EQ menu in `player_screen.dart` uses `lavfi=[...]` syntax, but `media_service.dart` applies filters via mpv's `af` property which expects native mpv filter syntax (e.g., `equalizer=f=...`). These are different systems and may not work.
- **Fix**: Convert `lavfi=` filters to mpv-native syntax, or use `--af=lavfi=[...]` as the property value.

---

## Architecture / Design Issues (10)

### Issue 16: `_initServices` uses bare `ref.read` in `initState`
- **File**: `lib/main.dart:91-106`
- **Severity**: Medium
- **Description**: Services are initialized via `ref.read` synchronously in `initState`. Fire-and-forget async calls like `rescanLibraries()` lack error handling and lifecycle awareness.
- **Fix**: Use `ref.listen` for side-effect initialization, or wrap async calls with proper error handling and cancellation on dispose.

### Issue 17: Navigation index uses `setState` in a Riverpod app
- **File**: `lib/main.dart:179`
- **Severity**: Medium
- **Description**: The `_index` state for navigation is managed with `setState` instead of a Riverpod provider. Navigation state can't be observed or changed from outside the widget.
- **Fix**: Create a `@riverpod` provider for `navigationIndex` and use `ref.watch`/`ref.read`.

### Issue 18: `app_settings_service.dart` imports `flutter/material.dart`
- **File**: `lib/core/services/app_settings_service.dart:1`
- **Severity**: Low
- **Description**: Only needed for `ThemeMode` enum. Should import `package:flutter/widgets.dart` to avoid Material dependency.
- **Fix**: Change import to `package:flutter/widgets.dart`.

### Issue 19: `FlyoutController` disposal uses method reference incorrectly
- **File**: `lib/features/library/ui/library_screen.dart:33`
- **Severity**: Medium
- **Description**: `useEffect(() => flyoutController.dispose, [flyoutController])` passes the method reference without calling it. `dispose` is a method, not a zero-arg function in all contexts.
- **Fix**: Change to `useEffect(() { flyoutController.dispose(); return null; }, [flyoutController])`.

### Issue 20: `_init()` called in Riverpod `build()`
- **File**: `lib/core/services/keyboard_shortcuts_service.dart:21`
- **Severity**: Medium
- **Description**: `build()` calls `_init()` which is async and calls `loadShortcuts()`. Every time the provider is watched, `_init()` is triggered (though Riverpod caches, the pattern is fragile).
- **Fix**: Use `ref.onDispose` and `ref.initState` patterns, or make `_init` part of the constructor.

### Issue 21: `Rx.combineLatest4` discards all emitted values
- **File**: `lib/features/stats/data/stats_service.dart:69`
- **Severity**: Medium
- **Description**: The combiner function `(_, _, _, _) => null` ignores all emitted values, then `asyncMap` recalculates stats from scratch via `_calculateStats()`. Inefficient.
- **Fix**: Use the emitted values directly in the combiner, or use `switchMap` with individual queries.

### Issue 22: Multiple `StreamProvider.autoDispose` for media streams
- **File**: `lib/features/player/ui/player_screen.dart:22-52`
- **Severity**: Medium
- **Description**: Providers like `playerPositionProvider`, `playerDurationProvider`, `playerPlayingProvider` are `autoDispose`, meaning stream subscriptions are torn down and rebuilt when unwatched. This causes unnecessary churn.
- **Fix**: Make them non-autoDispose or consolidate into a single `PlaybackState` provider.

### Issue 23: `playerChaptersProvider` uses `Future.delayed(200ms)` as a hack
- **File**: `lib/features/player/ui/player_screen.dart:54-62`
- **Severity**: Medium
- **Description**: This is a race-condition workaround for chapter loading. Not reliable.
- **Fix**: Use a proper event-based approach or listen to a chapters-loaded stream from `MediaService`.

### Issue 24: No single source of truth for `isPlaying` state
- **File**: `lib/features/player/ui/player_screen.dart`, `lib/features/player/ui/widgets/mini_player.dart`
- **Severity**: Low
- **Description**: Both files independently compute `isPlaying` from streams and `mediaService.isPlaying`. No single provider combines these.
- **Fix**: Create a `playbackStateProvider` that combines playing, position, duration, and current book into one state object.

### Issue 25: `libraryBooks` provider type is confusing
- **File**: `lib/features/library/data/library_service.dart:55`
- **Severity**: Low
- **Description**: Provider returns `Stream<List<Book>>` but Riverpod wraps it in `AsyncValue`. Callers must use `.maybeWhen` on `AsyncValue` rather than working with the stream directly.
- **Fix**: Either return `List<Book>` from a `StreamProvider` and let Riverpod handle the wrapping, or rename to clarify.

---

## Code Quality / Style Violations (11)

### Issue 26: Generic `pubspec.yaml` description
- **File**: `pubspec.yaml:2`
- **Severity**: Low
- **Description**: `"A new Flutter project."` — should describe CantoSync.
- **Fix**: Change to `"A modern, high-performance audiobook player for Windows and Linux."`

### Issue 27: Catch without stack trace in `library_service.dart` (4 instances)
- **Files**: `lib/features/library/data/library_service.dart:439`, `560`, `573`, `587`
- **Severity**: Low
- **Description**: Multiple `catch (e)` blocks should be `catch (e, stack)` per AGENTS.md logging conventions.
- **Fix**: Add stack trace parameter to all catches and pass to logger.

### Issue 28: Inconsistent alpha usage (`withValues` vs `withAlpha`)
- **File**: `lib/features/player/ui/player_screen.dart:339`
- **Severity**: Low
- **Description**: Uses `Colors.white.withValues(alpha: 0.7)` while rest of codebase uses `withAlpha(179)`.
- **Fix**: Standardize on one approach across the codebase.

### Issue 29: `SleepTimerState` is not immutable/freezed
- **File**: `lib/core/services/sleep_timer_service.dart:7-18`
- **Severity**: Low
- **Description**: Plain mutable class with manual `copyWith`. Per AGENTS.md conventions, state classes should use Freezed.
- **Fix**: Convert to a `@freezed` class.

### Issue 30: `UpdateInfo` is not freezed
- **File**: `lib/core/services/update_service.dart:61-69`
- **Severity**: Low
- **Description**: Plain class instead of Freezed.
- **Fix**: Convert to a `@freezed` class.

### Issue 31: GitHub URL mismatch — `anomalyco` vs `SV-stark`
- **File**: `lib/features/settings/ui/settings_screen.dart:904`
- **Severity**: Medium
- **Description**: README and update service reference `SV-stark/CantoSync`, but settings about section links to `github.com/anomalyco/cantosync`.
- **Fix**: Update all URLs to match the canonical repo owner.

### Issue 32: Empty string uses double quotes
- **File**: `lib/features/player/ui/widgets/bookmark_flyout.dart:243`
- **Severity**: Low
- **Description**: `bookmark.label ?? ""` should use single quotes per AGENTS.md: `''`.
- **Fix**: Change to `''`.

### Issue 33: US-specific date format
- **File**: `lib/features/player/ui/widgets/bookmark_flyout.dart:38`
- **Severity**: Low
- **Description**: `'${date.month}/${date.day}/${date.year}'` is US-specific. Should use `intl` for locale-aware formatting.
- **Fix**: Use `DateFormat.yMd().format(date)` from `package:intl`.

### Issue 34: `_ContributionCalendar` takes `List<dynamic>`
- **File**: `lib/features/stats/ui/stats_screen.dart:428`
- **Severity**: Low
- **Description**: Should be properly typed as `List<DailyListeningStats>`.
- **Fix**: Change parameter type.

### Issue 35: Hardcoded colors in glass/flyout widgets
- **Files**: `lib/features/player/ui/widgets/glass_player_card.dart:16`, `lib/features/player/ui/widgets/bookmark_flyout.dart:58`
- **Severity**: Low
- **Description**: Uses `Colors.white.withValues(alpha: 0.08)` instead of `FluentTheme.of(context)` for theme-aware colors.
- **Fix**: Use theme resources for background fills.

### Issue 36: `metadata_editor.dart` series index reset logic bug
- **File**: `lib/features/library/ui/metadata_editor.dart:70`
- **Severity**: High
- **Description**: `oldSeries != widget.book.series` compares after `widget.book.series` has already been mutated on line 57. The comparison checks the new value against itself, so the series index reset logic never triggers.
- **Fix**: Compare `oldSeries` to the new series value from the controller, not `widget.book.series`.

---

## Performance Issues (7)

### Issue 37: `WaveformVisualizer` creates 30 `AnimationController` instances
- **File**: `lib/features/player/ui/widgets/waveform_visualizer.dart:28-47`
- **Severity**: High
- **Description**: Each bar gets its own `AnimationController`. Extremely heavy for a decorative widget.
- **Fix**: Use a single `CustomPainter` with `RepaintBoundary` and animate bar heights in the paint method.

### Issue 38: Cover art loaded twice (main + reflection)
- **File**: `lib/features/player/ui/widgets/cover_art_with_reflection.dart:41-48`
- **Severity**: Medium
- **Description**: The same image file is loaded into memory twice — once for the main cover and once for the reflection.
- **Fix**: Cache the image using a shared `ImageProvider` or `MemoryImage`.

### Issue 39: Player screen `build()` does heavy computation every rebuild
- **File**: `lib/features/player/ui/player_screen.dart:78-109`
- **Severity**: Medium
- **Description**: Chapter matching, position calculation, and percentage logic runs on every build.
- **Fix**: Extract to a computed provider or memoize with `useMemoized`.

### Issue 40: Library collections set rebuilt on every build
- **File**: `lib/features/library/ui/library_screen.dart:40-51`
- **Severity**: Low
- **Description**: The `collections` set is computed from `allBooks` on every rebuild.
- **Fix**: Memoize or derive from a provider.

### Issue 41: `WaveformVisualizer` delayed futures not cancelled on dispose
- **File**: `lib/features/player/ui/widgets/waveform_visualizer.dart:56-59`
- **Severity**: Medium
- **Description**: `_startAnimation()` fires `barCount` delayed futures. If the widget is disposed before they fire, they still execute (wasted work).
- **Fix**: Track futures and cancel them in `dispose()`, or use a single timer-based approach.

### Issue 42: `WaveformVisualizer` doesn't handle `barCount` changes
- **File**: `lib/features/player/ui/widgets/waveform_visualizer.dart:72-81`
- **Severity**: Medium
- **Description**: If `barCount` prop changes, the existing `_controllers` and `_animations` lists have the wrong length, causing index out of bounds.
- **Fix**: Reinitialize animations in `didUpdateWidget` when `barCount` changes.

### Issue 43: Library scan not run in isolate
- **File**: `lib/features/library/data/library_service.dart:263-307`
- **Severity**: High
- **Description**: (Also listed as Issue 10) Full recursive filesystem scanning with metadata parsing blocks the UI thread.
- **Fix**: Wrap in `Isolate.run()` or `compute()`.

---

## Missing Features / Gaps (7)

### Issue 44: No search input widget in Library UI
- **File**: `lib/features/library/ui/library_screen.dart`
- **Severity**: Medium
- **Description**: `LibrarySearchQuery` provider exists but there's no search input widget in the library screen UI. Users cannot search.
- **Fix**: Add a `TextBox` or search bar that updates `librarySearchQueryProvider`.

### Issue 45: Navigation shortcuts have no callback registration
- **File**: `lib/core/services/keyboard_shortcuts_service.dart:189-203`
- **Severity**: High
- **Description**: `executeAction` calls `_executeCallbacks()` which reads from `shortcutActionCallbacksProvider`, but no code ever registers callbacks. Navigation shortcuts (`openLibrary`, `openPlayer`, `openSettings`, `focusSearch`, `toggleViewMode`, `addBookmark`) do nothing.
- **Fix**: Register callbacks in `main.dart` or respective screens using `ref.read(shortcutActionCallbacksProvider.notifier)`.

### Issue 46: No Linux platform guards for tray/hotkeys
- **Files**: `lib/core/services/tray_service.dart`, `lib/core/services/hotkey_service.dart`
- **Severity**: Medium
- **Description**: Neither service checks `Platform.isWindows` / `Platform.isLinux` before initializing platform-specific features. Per AGENTS.md section 9, platform features should be guarded.
- **Fix**: Add platform checks and graceful fallbacks.

### Issue 47: `BookmarkFlyout` is dead code
- **File**: `lib/features/player/ui/widgets/bookmark_flyout.dart`
- **Severity**: Low
- **Description**: `BookmarkFlyout` and `BookmarkFlyoutButton` are defined but never used. `player_screen.dart` uses a custom `_showAddBookmarkDialog` instead.
- **Fix**: Either integrate `BookmarkFlyout` into the player screen or remove the dead code.

### Issue 48: No bookmark viewing/jumping UI in player
- **File**: `lib/features/player/ui/player_screen.dart:722-777`
- **Severity**: Medium
- **Description**: The bookmark button only opens the add dialog. There's no UI to view or jump to existing bookmarks.
- **Fix**: Integrate `BookmarkFlyout` to show existing bookmarks with jump functionality.

### Issue 49: Narrator field never populated from metadata
- **File**: `lib/features/library/data/library_service.dart`
- **Severity**: Low
- **Description**: The `Book` model has a `narrator` field and the metadata editor allows editing it, but the library scan never extracts it from file metadata.
- **Fix**: Extract narrator from `metadata.common.albumArtist` or similar metadata field during scan.

### Issue 50: No UI for adding books to collections
- **File**: `lib/features/library/ui/library_screen.dart`
- **Severity**: Medium
- **Description**: The sidebar shows collections and the `Book` model has a `collections` field, but there's no UI to add a book to a collection. Collections can only be deleted.
- **Fix**: Add a context menu option or dialog to assign books to collections.

### Issue 51: Settings rescan is incomplete vs library rescan
- **File**: `lib/features/settings/ui/settings_screen.dart:42-59`
- **Severity**: Medium
- **Description**: `_rescanAll` loops through paths calling `scanDirectory` individually, while `library_screen.dart` calls `rescanLibraries()` which handles deduplication and stale book removal. The settings rescan doesn't remove books from deleted paths.
- **Fix**: Call `rescanLibraries()` instead of individual `scanDirectory` calls.

### Issue 52: No cleanup of cached cover art for deleted books
- **File**: `lib/features/library/data/library_service.dart`
- **Severity**: Low
- **Description**: When a book is removed (file deleted/moved), the cached cover art in `canto_sync/covers/` is not cleaned up.
- **Fix**: Delete the cover file when removing a book from the database.

### Issue 53: No `narrator` extraction during library scan
- **File**: `lib/features/library/data/library_service.dart:345-398`
- **Severity**: Low
- **Description**: (Related to Issue 49) The metadata parsing block extracts title, author, album, description, chapters, and cover, but skips narrator entirely.
- **Fix**: Add `narrator = metadata.common.albumArtist` or `metadata.common.performer` during scan.

### Issue 54: `_rescanAll` does not handle stale book removal
- **File**: `lib/features/settings/ui/settings_screen.dart:42-59`
- **Severity**: Medium
- **Description**: (Related to Issue 51) Unlike `rescanLibraries()`, the settings rescan doesn't detect and remove books whose files have been deleted outside the app.
- **Fix**: Use `rescanLibraries()` which already implements stale detection.

### Issue 55: No handling for cover art cleanup on book delete
- **File**: `lib/features/library/data/library_service.dart:135-139`
- **Severity**: Low
- **Description**: `deleteBook` removes the book from Isar but doesn't delete the associated cover file from disk.
- **Fix**: Before deleting the book, read `book.coverPath` and delete the file if it exists.

### Issue 56: No keyboard shortcut for search focus
- **File**: `lib/features/library/ui/library_screen.dart`
- **Severity**: Low
- **Description**: `ShortcutAction.focusSearch` exists but there's no search box to focus.
- **Fix**: Add search box first (Issue 44), then register the callback.

---

## Additional Issues from Second Pass

### Issue 57: `book_info_dialog.dart` — `setState` doesn't rebuild parent
- **File**: `lib/features/library/ui/book_info_dialog.dart:27`
- **Severity**: Low
- **Description**: `BookInfoDialog` updates the book's cover in the database but only calls `setState` on itself. The parent `LibraryScreen` won't see the updated cover until it rebuilds from the Isar watch stream.
- **Fix**: Rely on the Isar stream to propagate changes, or notify parent explicitly.

### Issue 58: `metadata_editor.dart` — mutates `widget.book` directly
- **File**: `lib/features/library/ui/metadata_editor.dart:52-77`
- **Severity**: Medium
- **Description**: Direct mutation of the `Book` object passed as a widget parameter. Violates immutability principles and can cause stale state.
- **Fix**: Create a copy of the book, mutate the copy, then save.

### Issue 59: `keyboard_shortcuts_screen.dart` — reads notifier without watching
- **File**: `lib/features/library/ui/keyboard_shortcuts_screen.dart:18`
- **Severity**: Medium
- **Description**: `ref.read(keyboardShortcutsProvider.notifier)` in `build()` means conflict state won't update reactively when shortcuts change.
- **Fix**: Use `ref.watch(keyboardShortcutsProvider)` and derive conflicts from the watched state.

### Issue 60: `cover_art_with_reflection.dart` — reflection transform distorts
- **File**: `lib/features/player/ui/widgets/cover_art_with_reflection.dart:66-88`
- **Severity**: Medium
- **Description**: `Matrix4.setEntry(1, 1, -0.3)` flips vertically but also scales/distorts. Should use `scale(1, -1)` for a proper reflection.
- **Fix**: Use `Matrix4.identity()..scale(1, -1)` or a `Transform.flip` widget.

### Issue 61: `sleep_timer_overlay.dart` — imports `material.IgnorePointer`
- **File**: `lib/features/player/ui/widgets/sleep_timer_overlay.dart:1`
- **Severity**: Low
- **Description**: Violates "no Material widgets" rule.
- **Fix**: Use `dart:ui`'s `IgnorePointer` or wrap in an `AbsorbPointer`.

### Issue 62: `bookmark_flyout.dart` — uses `Function(Bookmark)` instead of typed callbacks
- **File**: `lib/features/player/ui/widgets/bookmark_flyout.dart:19-20`
- **Severity**: Low
- **Description**: Should use `ValueChanged<Bookmark>` or `void Function(Bookmark)`.
- **Fix**: Change to typed function signatures.

### Issue 63: `mini_player.dart` — rewind seek negative Duration handling
- **File**: `lib/features/player/ui/widgets/mini_player.dart:238-241`
- **Severity**: Medium
- **Description**: `position - const Duration(seconds: 15)` can produce a negative Duration. The `.isNegative` check exists but `media_kit` may not handle negative durations gracefully.
- **Fix**: Clamp to `Duration.zero` before seeking: `newPos < Duration.zero ? Duration.zero : newPos`.

### Issue 64: `mini_player.dart` — forward seek clamps to wrong duration
- **File**: `lib/features/player/ui/widgets/mini_player.dart:262-265`
- **Severity**: Medium
- **Description**: For multi-file books, seeking forward clamps to the current file's `duration` instead of the total book duration.
- **Fix**: Clamp to `totalDuration` for multi-file books.

### Issue 65: `cover_art_with_reflection.dart` — imports `material.dart`
- **File**: `lib/features/player/ui/widgets/cover_art_with_reflection.dart:2`
- **Severity**: Low
- **Description**: Uses `material.LinearGradient` and `material.BlendMode.dstIn`.
- **Fix**: Use `dart:ui` equivalents (`Gradient.linear`, `BlendMode.dstIn` from `dart:ui`).

### Issue 66: `waveform_visualizer.dart` — `didUpdateWidget` doesn't reinitialize for `barCount` changes
- **File**: `lib/features/player/ui/widgets/waveform_visualizer.dart:72-81`
- **Severity**: Medium
- **Description**: (Also listed as Issue 42) If `barCount` prop changes, existing animation lists have wrong length.
- **Fix**: Dispose old controllers and reinitialize when `barCount` changes.

### Issue 67: `bookmark_flyout.dart` — `BookmarkFlyout` is dead code
- **File**: `lib/features/player/ui/widgets/bookmark_flyout.dart`
- **Severity**: Low
- **Description**: (Also listed as Issue 47) Defined but never used in the app.
- **Fix**: Integrate or remove.

### Issue 68: `player_screen.dart` — no bookmark viewing/jumping UI
- **File**: `lib/features/player/ui/player_screen.dart:350-362`
- **Severity**: Medium
- **Description**: (Also listed as Issue 48) Bookmark button only opens add dialog.
- **Fix**: Use `BookmarkFlyout` for viewing and jumping.

### Issue 69: `library_service.dart` — narrator never extracted
- **File**: `lib/features/library/data/library_service.dart:345-398`
- **Severity**: Low
- **Description**: (Also listed as Issue 49/53) Narrator field skipped during metadata extraction.
- **Fix**: Extract from `metadata.common.albumArtist` or similar.

### Issue 70: `settings_screen.dart` — rescan doesn't remove stale books
- **File**: `lib/features/settings/ui/settings_screen.dart:42-59`
- **Severity**: Medium
- **Description**: (Also listed as Issue 51/54) Uses individual `scanDirectory` calls instead of `rescanLibraries()`.
- **Fix**: Call `rescanLibraries()`.

### Issue 71: `library_service.dart` — no cover art cleanup on delete
- **File**: `lib/features/library/data/library_service.dart:135-139`
- **Severity**: Low
- **Description**: (Also listed as Issue 52/55) `deleteBook` doesn't delete the cached cover file.
- **Fix**: Delete `book.coverPath` file before removing from database.

---

## Quick Reference Table

| # | Severity | Category | File | Description |
|---|---|---|---|---|
| 1 | Critical | Bug | `media_service.dart:38` | Empty `writeTxnSync` block |
| 2 | Critical | Bug | `playback_sync_service.dart:86` | `void async` method |
| 3 | Critical | Bug | `playback_sync_service.dart:341` | Unawaited save in dispose |
| 4 | Critical | Bug | `media_service.dart:26` | Infinite recursion in `_p` getter |
| 5 | Critical | Bug | `media_service.dart:50` | Stream getters throw if uninitialized |
| 6 | Critical | Bug | `library_service.dart:161` | Raw `Player` creation bypasses service |
| 7 | Critical | Bug | `mini_player.dart:3` | Imports `material.dart` |
| 8 | High | Bug | `hotkey_service.dart:37` | Stop action only pauses |
| 9 | High | Bug | `player_screen.dart:758` | Bookmark timestamp double-counts |
| 10 | High | Bug | `library_service.dart:263` | Scan runs on main isolate |
| 11 | High | Bug | `library_service.dart:405` | Sequential metadata parsing |
| 12 | High | Bug | `playback_sync_service.dart:50` | Stats calc on every position tick |
| 13 | Critical | Bug | `tray_service.dart:60` | `exit(0)` bypasses cleanup |
| 14 | Medium | Bug | `book.dart:28` | `lastPlayed` set on creation |
| 15 | High | Bug | `player_screen.dart:697` | EQ filter syntax incompatible |
| 16 | Medium | Architecture | `main.dart:91` | Bare `ref.read` in initState |
| 17 | Medium | Architecture | `main.dart:179` | Navigation uses `setState` |
| 18 | Low | Architecture | `app_settings_service.dart:1` | Imports `material.dart` |
| 19 | Medium | Architecture | `library_screen.dart:33` | FlyoutController dispose bug |
| 20 | Medium | Architecture | `keyboard_shortcuts_service.dart:21` | `_init()` in `build()` |
| 21 | Medium | Architecture | `stats_service.dart:69` | `combineLatest4` discards values |
| 22 | Medium | Architecture | `player_screen.dart:22` | AutoDispose stream providers |
| 23 | Medium | Architecture | `player_screen.dart:54` | `Future.delayed` race-condition hack |
| 24 | Low | Architecture | `player_screen.dart` | No single `isPlaying` provider |
| 25 | Low | Architecture | `library_service.dart:55` | Confusing provider type |
| 26 | Low | Style | `pubspec.yaml:2` | Generic description |
| 27 | Low | Style | `library_service.dart` | 4 catches missing stack trace |
| 28 | Low | Style | `player_screen.dart:339` | Inconsistent alpha usage |
| 29 | Low | Style | `sleep_timer_service.dart:7` | State not freezed |
| 30 | Low | Style | `update_service.dart:61` | `UpdateInfo` not freezed |
| 31 | Medium | Style | `settings_screen.dart:904` | GitHub URL mismatch |
| 32 | Low | Style | `bookmark_flyout.dart:243` | Double quotes instead of single |
| 33 | Low | Style | `bookmark_flyout.dart:38` | US-specific date format |
| 34 | Low | Style | `stats_screen.dart:428` | `List<dynamic>` instead of typed |
| 35 | Low | Style | `glass_player_card.dart:16` | Hardcoded colors |
| 36 | High | Style | `metadata_editor.dart:70` | Series index reset logic bug |
| 37 | High | Performance | `waveform_visualizer.dart:28` | 30 AnimationControllers |
| 38 | Medium | Performance | `cover_art_with_reflection.dart:41` | Image loaded twice |
| 39 | Medium | Performance | `player_screen.dart:78` | Heavy computation in build |
| 40 | Low | Performance | `library_screen.dart:40` | Collections set rebuilt every build |
| 41 | Medium | Performance | `waveform_visualizer.dart:56` | Delayed futures not cancelled |
| 42 | Medium | Performance | `waveform_visualizer.dart:72` | `barCount` change not handled |
| 43 | High | Performance | `library_service.dart:263` | Scan not in isolate |
| 44 | Medium | Missing | `library_screen.dart` | No search input widget |
| 45 | High | Missing | `keyboard_shortcuts_service.dart:189` | Navigation shortcuts do nothing |
| 46 | Medium | Missing | `tray_service.dart`, `hotkey_service.dart` | No Linux platform guards |
| 47 | Low | Missing | `bookmark_flyout.dart` | Dead code |
| 48 | Medium | Missing | `player_screen.dart:722` | No bookmark viewing/jumping UI |
| 49 | Low | Missing | `library_service.dart` | Narrator never extracted |
| 50 | Medium | Missing | `library_screen.dart` | No collection assignment UI |
| 51 | Medium | Missing | `settings_screen.dart:42` | Incomplete rescan |
| 52 | Low | Missing | `library_service.dart` | No cover art cleanup on delete |
| 53 | Low | Missing | `library_service.dart:345` | Narrator extraction skipped |
| 54 | Medium | Missing | `settings_screen.dart:42` | Stale book removal missing |
| 55 | Low | Missing | `library_service.dart:135` | Cover file not deleted with book |
| 56 | Low | Missing | `library_screen.dart` | No search box for focusSearch |
| 57 | Low | Additional | `book_info_dialog.dart:27` | setState doesn't rebuild parent |
| 58 | Medium | Additional | `metadata_editor.dart:52` | Direct widget.book mutation |
| 59 | Medium | Additional | `keyboard_shortcuts_screen.dart:18` | Reads notifier without watching |
| 60 | Medium | Additional | `cover_art_with_reflection.dart:66` | Reflection transform distorts |
| 61 | Low | Additional | `sleep_timer_overlay.dart:1` | Imports `material.IgnorePointer` |
| 62 | Low | Additional | `bookmark_flyout.dart:19` | Untyped Function callbacks |
| 63 | Medium | Additional | `mini_player.dart:238` | Negative Duration seek |
| 64 | Medium | Additional | `mini_player.dart:262` | Wrong duration clamp for multi-file |
| 65 | Low | Additional | `cover_art_with_reflection.dart:2` | Imports `material.dart` |
| 66 | Medium | Additional | `waveform_visualizer.dart:72` | barCount change not handled |
| 67 | Low | Additional | `bookmark_flyout.dart` | Dead code (duplicate) |
| 68 | Medium | Additional | `player_screen.dart:350` | No bookmark viewing UI (duplicate) |
| 69 | Low | Additional | `library_service.dart:345` | Narrator not extracted (duplicate) |
| 70 | Medium | Additional | `settings_screen.dart:42` | Incomplete rescan (duplicate) |
| 71 | Low | Additional | `library_service.dart:135` | Cover cleanup missing (duplicate) |

---

## Severity Breakdown

| Severity | Count |
|---|---|
| Critical | 7 |
| High | 12 |
| Medium | 22 |
| Low | 30 |
| **Total** | **71** |

## Recommended Fix Priority

### Phase 1 — Critical (prevent data loss and crashes)
Issues: 1, 2, 3, 4, 5, 13, 36

### Phase 2 — High (fix broken features and performance)
Issues: 8, 9, 10, 11, 12, 15, 37, 43, 45, 63, 64

### Phase 3 — Medium (architecture and UX gaps)
Issues: 14, 16, 17, 19, 20, 21, 22, 23, 31, 38, 39, 41, 42, 44, 46, 48, 50, 51, 54, 58, 59, 60

### Phase 4 — Low (style, cleanup, polish)
Issues: 18, 24, 25, 26, 27, 28, 29, 30, 32, 33, 34, 35, 40, 47, 49, 52, 53, 55, 56, 57, 61, 62, 65, 66, 67, 68, 69, 70, 71
