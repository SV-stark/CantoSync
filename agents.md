# 🤖 Agent Guidelines — CantoSync

> **Purpose**: This document provides authoritative instructions for AI coding agents working on CantoSync. Follow every section before writing a single line of code.

---

## 0. Before You Start — Mandatory Pre-Flight

1. **Read `README.md`** — understand the product, its feature surface, and target platforms (Windows & Linux desktop only).
2. **Read `pubspec.yaml`** — know the exact package versions in use. **Never introduce a dependency that duplicates existing functionality.**
3. **Run `flutter analyze`** — confirm the codebase is clean before you make any changes.
4. **Run `flutter test`** — confirm all tests pass before you make any changes.
5. **Check `analysis_options.yaml`** — every rule defined there is enforced. Your code must pass `flutter analyze` with zero new warnings or errors.

---

## 1. Project Architecture

CantoSync uses a **feature-first, layered architecture**. Every feature is a self-contained vertical slice.

```
lib/
├── main.dart              # App bootstrap only — no business logic
├── core/                  # Shared across all features
│   ├── constants/         # App-wide constants (colors, sizes, durations)
│   ├── data/              # Shared Isar schemas and DB helpers
│   ├── services/          # Long-lived singleton services (media, hotkeys, tray, etc.)
│   ├── ui/                # Shared widgets, layouts, and theme extensions
│   └── utils/             # Pure utility functions (formatting, extensions)
└── features/              # One directory per product feature
    ├── library/
    │   ├── data/          # Isar models + service (LibraryService)
    │   └── ui/            # Screens, dialogs, sub-widgets for this feature
    ├── player/
    ├── settings/
    └── stats/
```

### Rules
- **`core/` is shared — `features/` is isolated.** A feature may import from `core/` freely but **must never import from another feature's directory**.
- **`main.dart`** bootstraps `ProviderScope`, window config, and the root widget. Keep it lean.
- **New features** get their own top-level directory under `features/` with the same `data/` + `ui/` structure.
- **Shared models** (used by more than one feature) live in `core/data/`.
- **Shared widgets** (used by more than one feature) live in `core/ui/`.

---

## 2. State Management — Riverpod

All state is managed with **Riverpod** using code generation (`riverpod_annotation`).

### Conventions

| Scenario | Tool |
|---|---|
| Singleton service (long-lived) | `@Riverpod(keepAlive: true)` on a class |
| Scoped / feature state | `@riverpod` on a class or function |
| Watching UI state | `ConsumerWidget` or `HookConsumerWidget` |
| One-shot side effects | `ref.read(provider.notifier).method()` |

### Rules

- **Never use `StateProvider` or `ChangeNotifier`.** Use `@riverpod` code-gen.
- **Never call `ref.read` inside a build method.** Use `ref.watch` for reactive state.
- **Async providers** (`AsyncNotifier`, `FutureProvider`) must handle loading and error states explicitly — never show a blank screen.
- Generated files (`*.g.dart`) are auto-created by `build_runner`. **Never hand-edit them.**
- After any annotation change, run: `dart run build_runner build --delete-conflicting-outputs`

---

## 3. Database — Isar

Isar is the local database. All persistent models are Isar collections.

### Conventions

- Each Isar collection is defined in the feature's `data/` folder (e.g., `features/library/data/book.dart`).
- Collections that are shared across features live in `core/data/`.
- Annotate models with `@Collection()` and generate with `build_runner`.
- **All DB write operations must occur inside an Isar `writeTxn`** — reads can be direct.
- **Never perform DB operations on the UI thread without `async/await`.**

### Model Pattern

```dart
// features/library/data/book.dart
import 'package:isar/isar.dart';
part 'book.g.dart';

@Collection()
class Book {
  Id id = Isar.autoIncrement;

  @Index()
  late String title;
  // ... fields
}
```

---

## 4. Code Style & Quality

### Dart

- Follow all rules in `analysis_options.yaml`. The most important ones:
  - `prefer_const_constructors` — use `const` everywhere possible.
  - `require_trailing_commas` — every multi-line argument list **must** have a trailing comma.
  - `prefer_single_quotes` — always use `'single quotes'` for strings.
  - `avoid_print` — use the `logger` package (`AppLogger`) for all logging.
  - `avoid_dynamic_calls` — always type your variables.
- Use `final` for all local variables that are not reassigned.
- Prefer named constructors and factory constructors for clarity.

### Naming

| Entity | Convention | Example |
|---|---|---|
| Files | `snake_case` | `library_service.dart` |
| Classes | `PascalCase` | `LibraryService` |
| Variables / methods | `camelCase` | `fetchBooks()` |
| Constants | `camelCase` prefixed with `k` | `kDefaultPadding` |
| Private members | `_camelCase` | `_isar` |

### Widget Rules

- **Never put business logic in a widget.** Widgets observe providers; providers hold logic.
- Split large screens into smaller private widgets or `part` files within the same `ui/` folder.
- Always pass a `Key` to top-level page widgets.
- Use `HookConsumerWidget` only when local ephemeral state (`useState`, `useEffect`) is needed alongside Riverpod.

---

## 5. UI — Fluent Design System

The app uses `fluent_ui` exclusively. **Do not mix in Material widgets.**

### Rules

- Use `fluent_ui` equivalents: `Button`, `NavigationView`, `Pane`, `CommandBar`, `ContentDialog`, `Flyout`, `InfoBar`, etc.
- For platform-adaptive effects (Mica/Acrylic on Windows), use the existing `WindowEffect` setup in `main.dart`. Do not override it.
- Use `FluentTheme.of(context)` for colors and typography — never hard-code hex values.
- Custom theme extensions should be placed in `core/ui/theme/`.
- Icons come from `FluentIcons` (the `fluent_ui` icon set) first. Use `package:phosphor_flutter` only if a specific icon has no Fluent equivalent.

### Layout

- The root layout (`NavigationView` with `PaneItems`) is declared in `main.dart`. New top-level screens are registered as `PaneItem` entries there.
- Sub-pages/dialogs within a feature must be navigated to using `Navigator.of(context).push(...)` with a `FluentPageRoute`.

---

## 6. Services (Core Layer)

Long-lived services in `core/services/` are initialized once at startup and kept alive.

| Service | Responsibility |
|---|---|
| `MediaService` | libmpv playback, chapter parsing, position events |
| `PlaybackSyncService` | persists resume position to Isar on a timer |
| `AppSettingsService` | user preferences (Freezed + Isar-backed) |
| `HotkeyService` | global hotkey registration/deregistration |
| `SleepTimerService` | countdown logic for sleep timer |
| `TrayService` | system tray icon and menu |
| `UpdateService` | GitHub Releases API polling |

### Rules

- A new service belongs in `core/services/` only if it is used by **two or more features** or is a singleton that manages hardware/OS resources.
- Feature-local data fetching logic belongs in the feature's own `data/` directory (as a `LibraryService`, `StatsService`, etc.).
- Services must **never import from a `features/` directory**.
- Service providers must be `keepAlive: true` and initialized via `ref.listen` or `ref.read` in `main.dart` during startup.

---

## 7. Error Handling & Logging

- Use the `logger` package. The `AppLogger` singleton is available app-wide.
- **Log levels**:
  - `logger.d(...)` — debug / trace (verbose, filtered in production)
  - `logger.i(...)` — significant lifecycle events (app start, library scan complete)
  - `logger.w(...)` — recoverable errors (file not found, network timeout)
  - `logger.e(...)` — unrecoverable errors (always include the stack trace as second argument)
- **Never swallow exceptions.** Either handle them gracefully (show an `InfoBar`) or rethrow.
- Async providers must map errors to UI states using `AsyncValue.error` — do not use try/catch that discards errors silently.

---

## 8. Performance

- **Library scans are expensive.** Always run them in `Isolate.run(...)` or via `compute()`. Never block the UI thread.
- **Metadata extraction** (`metadata_audio`) is I/O-bound. Batch operations and update UI progressively. Use `parseFile` with `ParseOptions(duration: true)` for best results.
- Use `skeletonizer` for loading states — never show an empty screen while data loads.
- `const` widgets are free. Make everything `const` that can be.
- Avoid rebuilding parent widgets to update a child — use fine-grained providers scoped to the data that changes.

---

## 9. Platform Differences (Windows vs Linux)

| Concern | Windows | Linux |
|---|---|---|
| Audio libs | `media_kit_libs_windows_video` | `media_kit_libs_linux` |
| Window effects | Mica / Acrylic via `window_manager` | No-op (plain background) |
| System tray | `tray_manager` (full support) | `tray_manager` (limited) |
| Global hotkeys | `hotkey_manager` (full support) | `hotkey_manager` (partial) |

- Wrap platform-specific code with `Platform.isWindows` / `Platform.isLinux` checks.
- **Never assume a platform feature is available.** Guard with `kIsWeb == false` and platform checks, and provide a graceful fallback or hide the UI element.

---

## 10. Code Generation

This project uses three code generators:

| Generator | Annotation | Output suffix |
|---|---|---|
| `riverpod_generator` | `@riverpod` | `.g.dart` |
| `freezed` | `@freezed` | `.freezed.dart` + `.g.dart` |
| `isar_generator` | `@Collection()` | `.g.dart` |

**Workflow:**

```bash
# Run once after changing any annotated file
dart run build_runner build --delete-conflicting-outputs

# Or watch mode during active development
dart run build_runner watch --delete-conflicting-outputs
```

**Never commit a state where generated files are out of sync with their sources.**

---

## 11. Testing

- Unit tests live in `test/` mirroring the `lib/` structure.
- Test **pure logic first**: formatters, parsers, utility functions, and state notifier logic.
- Use `ProviderContainer` for testing Riverpod notifiers in isolation — do not spin up Flutter.
- Integration tests for UI flows use `flutter_test`.
- **Every new service or utility function must have a corresponding test file.**
- Run before every commit: `flutter test && flutter analyze`

---

## 12. Git & Commit Conventions

Commits follow the format: `component: imperative description`

- `component` is the affected area: `library`, `player`, `settings`, `stats`, `core`, `ci`, `docs`
- The description is imperative, lowercase, no period
- The body (if present) explains **why**, not what

```
library: add series index sort to scan pipeline

Isar queries previously returned books in insertion order, which broke
multi-part series ordering. This sorts by `seriesIndex` after the initial
query.
```

- **One logical change per commit.** Do not bundle unrelated fixes.
- **Never force-push to `main`.** Use feature branches and PRs.

---

## 13. Adding a New Feature — Checklist

When implementing a new product feature, work through this checklist in order:

- [ ] Create `lib/features/<feature_name>/data/` and `lib/features/<feature_name>/ui/`
- [ ] Define any new Isar models in `data/`, add `@Collection()`, run `build_runner`
- [ ] Create a `<feature_name>_service.dart` provider (`@riverpod`) in `data/` for all data operations
- [ ] Build the UI in `ui/` using only `fluent_ui` widgets and `ref.watch`
- [ ] Register the new screen as a `PaneItem` in `main.dart` (if it's a top-level nav destination)
- [ ] Add any required shared widgets to `core/ui/`
- [ ] Add any required shared utilities to `core/utils/`
- [ ] Write unit tests for the service and any non-trivial utility logic
- [ ] Run `flutter analyze` — zero warnings allowed
- [ ] Run `flutter test` — all tests must pass
- [ ] Update `README.md` roadmap if the feature was listed as pending

---

## 14. What NOT To Do

| ❌ Don't | ✅ Do instead |
|---|---|
| Import `material.dart` | Use `fluent_ui` equivalents |
| Use `print()` | Use `logger.d/i/w/e()` |
| Hard-code colors | Use `FluentTheme.of(context)` tokens |
| Write to Isar outside `writeTxn` | Always wrap writes in a transaction |
| Add a new package without checking existing deps | Check `pubspec.yaml` first |
| Hand-edit `*.g.dart` or `*.freezed.dart` | Re-run `build_runner` |
| Put business logic in `build()` | Move it to a Riverpod notifier |
| Use `dynamic` | Always type your variables |
| Swallow exceptions with empty `catch {}` | Log and surface errors to the UI |
| Cross-import between feature directories | Promote shared code to `core/` |
