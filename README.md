<p align="center">
  <img src="assets/logo.svg" height="120" alt="CantoSync Logo"/>
</p>

<h1 align="center">CantoSync</h1>

<p align="center">
  <strong>A modern, high-performance audiobook player for Windows and Linux.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white" alt="Windows"/>
  <img src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux"/>
  <img src="https://img.shields.io/badge/License-GPLv3-green.svg?style=for-the-badge" alt="License"/>
</p>

---

## 📖 About CantoSync

**CantoSync** is designed with a focus on aesthetics and functionality, bridging the gap between powerful audio engines and native user experiences. It provides an industry-leading playback experience for audiobook enthusiasts.

---

## ✨ Key Features

| Feature | Description |
| :--- | :--- |
| 🚀 **High-Performance** | Powered by `media_kit` (libmpv) with gapless playback, playlist prefetching, sample-accurate seeking (`hr-seek`), ReplayGain, pitch-corrected speed control, and broad format support (`.m4b`, `.m4a`, `.mp3`, `.flac`, `.ogg`, `.wav`, `.opus`). |
| 🔖 **Chapters & Multi-File** | Parses embedded M4B/ID3 chapters and automatically groups multi-file audiobook folders into chaptered playlists. |
| 🧠 **Smart Resume** | Remembers the exact track and second where you left off for every audiobook in your library. |
| 📑 **Bookmarks** | Save custom timestamped bookmarks to jump back to key moments across single-file and multi-file books. |
| 📚 **Series & Collections** | Organize audiobooks by author, series (with index-based ordering), or custom collections, with Grid/List views and search. |
| 📂 **Multi-Library & Drag-and-Drop** | Add multiple library folders or drag and drop audiobook folders and individual audio files directly into the library. |
| 🎨 **Fluent Design** | Built with `fluent_ui`, supporting Light, Dark, and System themes, plus customizable player themes, waveform, and cover reflection. |
| 🎵 **Mini-Player & System Tray** | Persistent mini-player across all screens and system tray controls (Windows & Linux). |
| ⏲️ **Sleep Timer** | Timed countdown or End-of-Chapter auto-pause with smooth volume fade-out. |
| ⌨️ **Keyboard Shortcuts** | Customizable in-app and global hotkeys with conflict detection. |
| 📊 **Listening Statistics** | Track daily listening activity, streaks, author analytics, average playback speed, and completion tracking. |
| 📝 **Metadata Editor** | Edit book titles, authors, series, descriptions, and custom cover art directly in the app. |
| 🎚️ **Audio Processing** | Playback speed control, equalizer presets (Flat, Spoken Word, Bass Boost, Treble Boost), skip silence, loudness & dynamic volume normalization, voice clarity, mono downmix, 200% volume boost, and output device selection. |
| 🧹 **Orphaned File Cleaner** | Scan and purge database records for missing or deleted audio files. |
| 🔄 **Update Checker** | Built-in GitHub Releases update checker that notifies you when a new version is available. |

---

## 📸 Screenshots

<div align="center">
  <img src="assets/screenshots/library.png" alt="Library View" width="45%" />
  <img src="assets/screenshots/player.png" alt="Player View" width="45%" />
  <br/><br/>
  <img src="assets/screenshots/stats.png" alt="Statistics" width="45%" />
  <img src="assets/screenshots/settings.png" alt="Settings" width="45%" />
</div>

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (Windows & Linux desktop)
- **UI Library**: [fluent_ui](https://pub.dev/packages/fluent_ui) & [skeletonizer](https://pub.dev/packages/skeletonizer)
- **Audio Engine**: [media_kit](https://pub.dev/packages/media_kit) (libmpv)
- **State & Codegen**: [hooks_riverpod](https://pub.dev/packages/hooks_riverpod), [riverpod_annotation](https://pub.dev/packages/riverpod_annotation), [flutter_hooks](https://pub.dev/packages/flutter_hooks), & [freezed](https://pub.dev/packages/freezed)
- **Database**: [Isar Community](https://pub.dev/packages/isar_community)
- **Metadata Extraction**: [metadata_audio](https://pub.dev/packages/metadata_audio)
- **Desktop Integration**: [window_manager](https://pub.dev/packages/window_manager), [hotkey_manager](https://pub.dev/packages/hotkey_manager), [tray_manager](https://pub.dev/packages/tray_manager), [desktop_drop](https://pub.dev/packages/desktop_drop), & [file_picker](https://pub.dev/packages/file_picker)
- **Streams & Utilities**: [rxdart](https://pub.dev/packages/rxdart), [gap](https://pub.dev/packages/gap), [fpdart](https://pub.dev/packages/fpdart), & [fast_immutable_collections](https://pub.dev/packages/fast_immutable_collections)

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK** with **Dart 3.10.7+**
- **Visual Studio Build Tools** (Windows)
- **Linux build & audio dependencies**: `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`, `libmpv-dev`, `libkeybinder-3.0-dev`, `libayatana-appindicator3-dev`, `libsecret-1-dev`

### Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/SV-stark/CantoSync.git

# 2. Install dependencies
cd CantoSync
flutter pub get

# 3. Run the app
flutter run -d windows # or linux
```

### Development & Testing

```bash
# Regenerate Riverpod / Freezed / Isar files after modifying annotated code
dart run build_runner build --delete-conflicting-outputs

# Run static analysis and unit tests
flutter analyze
flutter test
```

---

## 📦 Installation

### Windows

#### Option 1: Download Pre-built Release
1. Download the latest release from [GitHub Releases](https://github.com/SV-stark/CantoSync/releases)
2. Run the `.exe` installer
3. Launch CantoSync from the Start Menu or Desktop shortcut

#### Option 2: Build from Source
```bash
flutter build windows --release
```
The executable will be at `build/windows/x64/runner/Release/`

### Linux

#### Option 1: Download Pre-built Release
1. Download the latest AppImage from [GitHub Releases](https://github.com/SV-stark/CantoSync/releases)
2. Make it executable: `chmod +x cantosync-*.AppImage`
3. Run: `./cantosync-*.AppImage`

#### Option 2: Build from Source
```bash
flutter build linux --release
```

---

## 🗺️ Roadmap

- [x] **High-Performance Audio Engine**: Powered by libmpv for native M4B/M4A support.
- [x] **Native Chapter Navigation**: Direct interface for embedded chapter markers.
- [x] **Smart Library Management**: Recursive folder scanning and metadata extraction.
- [x] **Visual Grid View**: Elegant cover-art-first library layout.
- [x] **Information & Context**: Detailed info screens with description & custom cover overrides.
- [x] **Integrated Sleep Timer**: Advanced auto-pause (timed or end-of-chapter).
- [x] **System Integration**: Global hotkeys, Tray control, and Window state persistence.
- [x] **Bookmarks**: Save and navigate to custom timestamps.
- [x] **Series Support**: Organize books by series with index ordering.
- [x] **Listening Statistics**: Track daily stats, author analytics, and completion rates.
- [x] **Mini-Player**: Persistent playback controls across all screens.
- [x] **Metadata Editor**: Edit titles, authors, descriptions, and cover art.
- [x] **Equalizer & Audio Filters**: Built-in audio presets, skip silence, loudness & dynamic normalization, voice clarity, mono downmix, 200% volume boost, and output device switching.
- [x] **Library Grouping & Search**: Group by Author, Series, or Collections with search and Grid/List views.
- [x] **Auto-Updater**: Automatic update checking and notifications.
- [ ] **Cloud Sync**: Cross-device progress synchronization (NextCloud/WebDAV).
- [ ] **Per-Book Audio DSP**: Per-book equalizer presets and playback speed memory.
- [ ] **OS Media Controls**: Native Windows SMTC & Linux MPRIS integration.

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/SV-stark">SV-Stark</a>
</p>
