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
  <img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" alt="License"/>
</p>

---

## 📖 About CantoSync

**CantoSync** is designed with a focus on aesthetics and functionality, bridging the gap between powerful audio engines and native user experiences. It provides an industry-leading playback experience for audiobook enthusiasts.

---

## ✨ Key Features

| Feature | Description |
| :--- | :--- |
| 🚀 **High-Performance** | Powered by `media_kit` (libmpv) for unmatched stability and format support (M4B, MP3, FLAC, OPUS, and more). |
| 📚 **Smart Library** | Recursive folder scanning with automatic metadata extraction (Title, Artist, Album) and cover art caching. |
| 🔖 **Native Chapters** | Instant access to embedded chapters (ID3/M4B) via a dedicated sidebar for seamless navigation. |
| 🧠 **Smart Resume** | Persistent storage of your playback position for every file—never lose your place again. |
| 🎨 **Fluent Design** | Premium UI built with `fluent_ui`, featuring Mica/Acrylic effects and full Dark/Light theme support. |

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev)
- **UI Library**: [fluent_ui](https://pub.dev/packages/fluent_ui)
- **Audio Engine**: [media_kit](https://pub.dev/packages/media_kit)
- **Metadata**: [metadata_god](https://pub.dev/packages/metadata_god)
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

- [x] Core Playback & Seek
- [x] Native Chapter Navigation
- [x] Position Persistence
- [x] **Smart Library**: Recursive scanning & Metadata extraction
- [x] **Cover Art**: Automatic extraction & caching
- [ ] **Grid View**: Visual library browser for your collection
- [ ] **Sleep Timer**: Auto-pause functionality
- [ ] **Sync**: Cloud progress synchronization

---

<p align="center">
  Made with ❤️ by SV-Stark
</p>
