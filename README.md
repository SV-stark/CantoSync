# CantoSync 🎧

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)

**CantoSync** is a modern, high-performance audiobook player built for Windows and Linux. Designed with a focus on aesthetics and functionality, it bridges the gap between powerful audio engines and native user experiences.

---

## ✨ Key Features

### 🚀 **High-Performance Audio Engine**
Powered by **`media_kit`** (libmpv), CantoSync enables industry-leading playback stability and supports virtually all audio formats, including:
-   **M4B** (Audiobooks)
-   **MP3, FLAC, OGG, WAV**
-   **OPUS, AAC**

### 🔖 **Native Chapter Support**
Navigate complex audiobooks with ease. CantoSync directly interfaces with the underlying engine to parse **embedded chapters** (ID3/M4B), offering:
-   Instant chapter access via a dedicated sidebar.
-   Precise timestamps and duration display.
-   No external dependency bloat—it just works.

### 🧠 **Smart Resume (Persistence)**
Never lose your place again.
-   **Per-File Memory**: CantoSync remembers the exact second where you left off for *every* audio file in your library.
-   **Instant Resume**: Re-opening the app automatically cues up your last played book.

### 🎨 **Beautiful Fluent Design**
Built with **`fluent_ui`**, the interface feels right at home on Windows 11.
-   **Mica & Acrylic** effects (Windows).
-   Clean, distraction-free "Now Playing" mode.
-   Dark & Light theme support.

---

## 🛠️ Tech Stack

-   **Framework**: [Flutter](https://flutter.dev)
-   **UI Library**: [fluent_ui](https://pub.dev/packages/fluent_ui)
-   **Audio Engine**: [media_kit](https://pub.dev/packages/media_kit) (libmpv)
-   **State Management**: [Riverpod](https://riverpod.dev)
-   **Database**: [Hive](https://docs.hivedb.dev/) (NoSQL)

---

## 🚀 Getting Started

### Prerequisites
-   [Flutter SDK](https://docs.flutter.dev/get-started/install/windows) (3.10+)
-   Visual Studio Build Tools (for Windows C++ compilation)
-   MPV dependencies (Linux only)

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/yourusername/cantosync.git
    cd cantosync
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Run the app**
    ```bash
    # For Windows
    flutter run -d windows

    # For Linux
    flutter run -d linux
    ```

---

## 🗺️ Roadmap

-   [x] Core Playback & Seek
-   [x] Native Chapter Navigation
-   [x] Position Persistence
-   [ ] **Library Management**: Scan folders recursively & extract metadata
-   [ ] **Cover Art**: Visual grid view for your collection
-   [ ] **Sleep Timer**: Auto-pause after set duration
-   [ ] **Sync**: Cloud progress synchronization

---

Made with ❤️ by SV-Stark