# VocalBridge (kasa_me)

VocalBridge is a privacy-first, offline-capable Flutter application designed to provide seamless audio transcription and accessibility features. Built with a strong emphasis on user privacy, all audio processing and storage occur entirely on-device.

## 🚀 Features

* **Offline Speech-to-Text**: Transcription models run completely locally, ensuring your raw audio never leaves your device.
* **Accessible UI**: Designed with high-contrast themes, large typography, and motor-accessible controls (e.g., Large Push-to-Talk button) to accommodate all users.
* **High-Fidelity Audio**: Optimized `AudioRecorderService` configured specifically for transcription engines (16kHz, mono, PCM16).
* **Local Storage**: Reliable offline data persistence powered by `sqlite3` and `drift`.
* **Modern Architecture**: Uses `flutter_riverpod` for robust state management and `go_router` for declarative navigation.

## 🛠 Tech Stack

* **Framework**: Flutter / Dart
* **State Management**: [Riverpod](https://riverpod.dev/)
* **Routing**: [GoRouter](https://pub.dev/packages/go_router)
* **Database**: [Drift](https://drift.simonbinder.eu/) (SQLite)
* **Audio**: [record](https://pub.dev/packages/record)

## 📦 Getting Started

### Prerequisites

* Flutter SDK (latest stable)
* Android Studio / Xcode for emulators and compilation

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/BuiltByDennis/VocalBridge.git
   cd VocalBridge/kasa_me
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run Code Generation (Drift/Riverpod):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the App:**
   ```bash
   flutter run
   ```

## 🔒 Privacy Guarantee

VocalBridge is fundamentally designed for privacy. We do not use third-party cloud transcription APIs. All voice-to-text processing happens locally on the user's hardware.

## 🤝 Contributing

When contributing to this repository, please first discuss the change you wish to make via issue, email, or any other method with the owners of this repository before making a change.

Ensure your code passes the linting standards:
```bash
flutter analyze
```

## 📄 License

This project is proprietary and confidential. All rights reserved by BuiltByDennis.
