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
| 🚀 **High-Performance** | Powered by `media_kit` (libmpv) for unmatched stability and format support (M4B, MP3, FLAC, OPUS, and more). |
| 🔖 **Native Chapters** | Direct interface with the audio engine to parse embedded chapters (ID3/M4B) for easy navigation. |
| 🧠 **Smart Resume** | Remembers the exact second where you left off for *every* audio file in your library. |
| 🎨 **Fluent Design** | A beautiful interface built with `fluent_ui`, featuring Mica and Acrylic effects on Windows. |

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev)
- **UI Library**: [fluent_ui](https://pub.dev/packages/fluent_ui)
- **Audio Engine**: [media_kit](https://pub.dev/packages/media_kit)
- **State Management**: [Riverpod](https://riverpod.dev)
- **Database**: [Hive](https://docs.hivedb.dev/)

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK** (3.10+)
- **Visual Studio Build Tools** (Windows)
- **MPV dependencies** (Linux)

### Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/cantosync.git

# 2. Install dependencies
cd cantosync
flutter pub get

# 3. Run the app
flutter run -d windows # or linux
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
- [ ] **Cloud Sync**: Cross-device progress synchronization (NextCloud/WebDAV).
- [ ] **Audio DSP**: Per-file equalizer presets and playback rate optimization.
- [ ] **Smart Filters**: Dynamic grouping and advanced library search.

---

<p align="center">
  Made with ❤️ by SV-Stark
</p>
