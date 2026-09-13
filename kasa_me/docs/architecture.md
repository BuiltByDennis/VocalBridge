# Architecture
- Presentation Layer: Flutter UI with Riverpod for state management
- Domain Layer: Language, Profile, Audio interfaces
- Data Layer: Drift (SQLite) for local storage, Secure Storage for keys
- Speech Engine: Abstracted behind SpeechEngine interface (target: Sherpa-ONNX)
- Audio Capture: Using `record` package for PCM16 16kHz mono capture.
