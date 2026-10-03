# Galaxy AI — Production Flutter Desktop Frontend

Galaxy AI is a production-quality Flutter Desktop voice assistant frontend designed for Windows, macOS, and Linux. It interfaces cleanly with a Python FastAPI backend over WebSocket and HTTP.

---

## 🏗️ Project Architecture

```
lib/
├── main.dart                      # Application bootstrap & dependency injection
├── api/
│   ├── api_config.dart            # Central backend URL configuration (http://127.0.0.1:8080)
│   └── backend_client.dart        # Abstract backend client & FastAPI implementation
├── models/
│   ├── assistant_state.dart       # Strongly typed assistant states (listening, thinking, etc.)
│   ├── audio_packet.dart          # Multi-band frequency and amplitude model
│   └── backend_event.dart         # Incoming/outgoing FastAPI WebSocket event envelope
├── services/
│   ├── audio_service.dart         # Abstract audio contract + desktop amplitude provider
│   └── connection_service.dart    # Network lifecycle & auto-reconnection manager
├── state/
│   └── assistant_controller.dart  # Central state coordinator with ChangeNotifier
├── screens/
│   └── main_screen.dart           # Primary desktop voice screen
└── widgets/
    ├── ai_orb.dart                # Multi-layered pulsating glowing AI core CustomPainter
    ├── waveform_visualizer.dart   # Responsive 32-bar audio spectrum visualizer
    ├── top_bar.dart               # Minimal branding and connection indicator
    ├── status_bar.dart            # State label, human-readable tool execution feedback
    └── controls_bar.dart          # Microphone toggle, interrupt, and shortcut badges
```

---

## 🚀 Running on Desktop

Ensure Flutter is installed and desktop support is enabled:

```bash
# Enable desktop platform for your OS:
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop

# Install Dart/Flutter dependencies
flutter pub get

# Run natively on your desktop platform:
flutter run -d windows
flutter run -d macos
flutter run -d linux
```

---

## 🔌 Backend Configuration

The Python FastAPI backend URL is centralized in `lib/api/api_config.dart`:

```dart
static const String defaultBaseUrl = 'http://127.0.0.1:8080';
```

When connected to FastAPI, Galaxy AI automatically establishes a WebSocket connection to `ws://127.0.0.1:8080/ws/assistant`.

### Desktop Keyboard Shortcuts
- **Space**: Toggle microphone mute / listening
- **Esc**: Interrupt assistant speech
- **R**: Trigger immediate reconnection to backend
