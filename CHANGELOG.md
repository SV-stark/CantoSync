# Changelog

All notable changes to CantoSync are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Bug-fix pass covering playback synchronization, library scanning, listening
statistics, keyboard shortcuts, and UI/lifecycle issues. 55 issues were
reported; 53 were fixed and 2 report claims were retracted as inaccurate.
See the "Corrections" section below.

### Fixed

#### Data Integrity

- **Concurrent writes no longer clobber each other.** `updateProgress`,
  `addBookmark`, `removeBookmark`, and the new `saveChapters` now perform
  read-modify-write inside a single Isar transaction. Previously each loaded a
  book outside the transaction and wrote the stale snapshot back, so a chapter
  save could revert a newer playback position.
- **Listening stat lists were a shared immutable instance.** `booksListened`
  and `bookTitles` defaulted to `const []`, a single canonical immutable list,
  so the first `.add()` on a new `DailyListeningStats` or `AuthorStats` row
  would throw. Both are now per-instance growable lists.
- **Rescans no longer revert hand-edited metadata.** `_addBookIfNotExists`
  keeps existing values whenever the file supplies none, so a cleaned-up title,
  hand-written series, or chosen cover art survives a forced rescan.
- **Cached cover art is no longer leaked on disk.** `rescanLibraries` and
  `cleanOrphanedBooks` now collect cover paths and delete them through a shared
  `_deleteCachedCovers` helper.
- **Cover deletion is now safe against path confusion.** `isDeletableCover`
  normalises both sides before comparing, so mixed separators no longer
  silently skip deletion, and a sibling directory sharing a name prefix
  (e.g. `covers_old`) can never match.
- **Removing a library folder no longer orphans its books.** Books whose path
  falls under no configured library are now removed. The database is preserved
  when no library paths are configured, and offline/unmounted drives are still
  never pruned.
- **Series numbering preserves user-set indices.** Unindexed titles continue
  from the highest existing index instead of being numbered from the title sort.
- **Local cover detection handles real filenames.** Matching covers
  `cover.jpg` only; now also matches `folder`, `front`, `albumart`, `artwork`,
  `thumb` and similar, and falls back to a folder's single image.
- **Metadata cleaning no longer mangles titles.** The blanket `-`/`_` to space
  replacement turned "Spider-Man" into "Spider Man"; only whitespace runs are
  collapsed now.

#### Playback & Chapters

- **`previousChapter` restarts the current chapter.** Pressing previous more
  than 3 seconds into a chapter now seeks to that chapter's start instead of
  always stepping back, matching standard media-player behaviour.
- **The end-of-chapter sleep timer fires at the right time.** The single-file
  branch matched against a chapter index that was effectively always 0, so it
  waited for the whole book. It now resolves the chapter from the current
  position via the new `MediaService.currentChapterIndex`, and clamps a
  malformed negative remaining time to zero.
- **Concurrent chapter reads no longer wipe a good chapter list.** The
  `_isFetchingChapters` flag reported "no chapters" to a second caller while a
  read was already in flight. Replaced with a de-duplicated in-flight future.
- **A stale chapter fetch can no longer clear the current book's chapters.**
  Results are only published when the generation still matches and the result
  is non-empty.
- **Switching books no longer leaks the previous total duration.**
  `_totalDurationController` emits zero when a book has no known total.
- **Multi-file playback is detected explicitly** via an `_isPlaylistOpen` flag
  set on open, replacing a duration-delta heuristic that misfired.
- **Multi-file chapter start times stay aligned** when a file has no duration.
- **Books are only marked complete at the end of the last file.** Completion
  now also requires the position to reach `AppConstants.bookCompletionThreshold`
  of the whole book, so scrubbing to the end of an early file no longer
  completes the book.
- **`_currentBook` is cleared when its book is missing**, so listening time and
  chapters are no longer attributed to a deleted or moved book.
- **`_pendingSave` is always cleared**, so `dispose` no longer re-saves stale
  data indefinitely.
- **Negative seeks are clamped.** Skipping backward within the first seconds of
  a track threw; `seek` now clamps to zero and caps at the known duration.
- **`setVolume` clamps to 0-100** as its comment always claimed.
- **Non-native platforms no longer silently no-op** on next/previous chapter,
  and out-of-range chapter jumps are warned about instead of throwing.
- **`MediaService._init` is re-entrancy safe.** A retried init no longer
  overwrites and leaks a native player handle.

#### Statistics

- **Listening sessions count continuous stretches, not 30-second samples.** A
  two-hour listen was recorded as 240 sessions; sessions now start when
  playback resumes after being idle.
- **Seconds accumulated before a pause are flushed to stats** instead of being
  dropped, so short sessions are no longer lost.
- **Author stats key on book path, not title.** Two same-titled books no longer
  collapse into one, and a rename no longer registers as a new book.
- **Completing a book no longer drops the author stat.** When no `AuthorStats`
  row exists yet, one is created instead of the completion being discarded.
- **Streaks de-duplicate dates** before being walked, fixing understated longest
  streaks.

#### Keyboard Shortcuts & Hotkeys

- **`MediaPlayPause` now maps to `mediaPlayPause`** rather than `mediaPlay`.
- **The default stop shortcut is `Ctrl+Escape`.** Bare `Escape` was captured
  globally and fought with dialogs, text fields, and the title bar.
- **Editing a shortcut no longer inserts a duplicate row.** `updateShortcut`
  now preserves the existing id instead of writing the auto-increment sentinel.
- **Modifier shortcuts no longer fire while typing.** The editable-field guard
  applied only to unmodified keys, so `Ctrl+B` and `Ctrl+1` triggered while
  editing metadata. Media keys are still always allowed.
- **In-app hotkey scope is not used on Linux**, where it is unimplemented and
  silently swallowed every key; modifier and media keys are registered
  system-wide on that platform.
- **Dead `loadShortcuts()` removed** along with a `try`/`catch` around a
  `firstWhere` that could not throw.

#### UI & Lifecycle

- **Window caption buttons no longer overflow** the 32px title bar.
- **The mini player is inset** from the navigation pane and the window's bottom
  padding instead of covering them.
- **Fast-forward no longer appears to jump to the start** when a track's duration
  is not yet known.
- **Scrolling long titles use measured overflow** with a duration proportional
  to the overflow, so long and short titles scroll at the same speed.
- **`PlayerThemeMode` is now honoured.** The stored setting was dead; the
  player background applies the standard, adaptive, or true-black treatment.
- **Ambient background decodes covers at 48px** instead of full resolution, is
  wrapped in a repaint boundary, and no longer blurs per frame.
- **The sleep timer overlay fades out** instead of remaining on screen.
- **The waveform animates at 25fps** rather than synthesising at 60fps.
- **The pulsing play button no longer recomputes a 30px-blur shadow per frame.**
- **Library shortcut callbacks no longer leak.** Each build created new
  closures while the cleanup list was empty, accumulating duplicate live
  callbacks.
- **Folder picking and scanning report failures.** Unhandled async exceptions
  are caught, logged, and surfaced as an `InfoBar`.
- **Startup rescan is awaited**, so its error handling can actually run; the
  update check is explicitly unawaited.
- **Closing the window can no longer make the app unreachable.** If the tray
  failed to initialise, close destroys the window instead of hiding it.
- **The tray exposes `isAvailable`**, and initialises before hotkeys so close
  handling can consult it.
- **Hard-coded Material colours removed** from the library and stats screens via
  a new `SemanticColors` theme extension wired into `main.dart`, including a
  shared contribution-heatmap ramp.
- **Search covers series and description**, not just title, author, narrator,
  and album.
- **"Continue Listening" shows only played books** rather than filling with
  never-opened titles.
- **The update service closes its HTTP client** and logs non-2xx responses.
- **Version comparison no longer swallows unparseable tags** in a bare
  `catch`; unparseable versions are logged and treated as not newer.
- **Settings seed exactly once.** The synchronous seed write in `build()` ran on
  every rebuild.

### Added

- `MediaService.currentChapterIndex`, the shared helper behind the
  previous-chapter and end-of-chapter-sleep-timer behaviour.
- `stats_service.startListeningSession`, used to count one session per
  continuous stretch of playback.
- `LibraryService.saveChapters`, which writes only `internalChapters` and so
  cannot clobber concurrent progress writes.
- `HotKeyService.resolveHotKeyScope`, encapsulating the platform-specific
  in-app versus system scope decision.
- `TrayService.isAvailable`, used to decide whether close should hide or
  destroy the window.
- `SemanticColors`, a `ThemeExtension` providing destructive, success, warning,
  highlight, sessions, overlay, and heatmap tokens for light and dark.
- 17 unit tests covering the new chapter-index helper and the cover-path guard.

### Corrections

Two claims from the original report were inaccurate and are retracted:

- **`IsarAppSettings` id `0` was reported as never persisting.** This was wrong.
  `isarAutoIncrementId` is `-9223372036854775808`, so `0` is a valid explicit id
  that round-trips correctly. Settings were persisting all along. A real but
  different issue nearby — `ListeningSpeedPreference` mixing the auto-increment
  sentinel with a hand-assigned id — is fixed, now via a named
  `kSpeedPreferenceId` constant.
- **`update_service` and `sleep_timer_service` were reported as untested.**
  Both already had test files covering `isNewerVersion`, `checkForUpdates`,
  `stepSleepTimer`, and `calculateEndOfChapterRemaining`.

### Known Issues

- `lib/core/services/playback_sync_service.dart` imports from
  `features/library` and `features/stats`, which AGENTS.md forbids for
  `core/`. Left in place: moving it under a feature would only trade this for
  a forbidden feature-to-feature import, since it genuinely coordinates three
  features. Resolving it properly needs interfaces extracted into `core/`.
