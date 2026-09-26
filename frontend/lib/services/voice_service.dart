import 'dart:async';
import 'dart:math' as math;

import '../models/assistant_state.dart';

/// Frontend-side voice communication service.
///
/// Coordinates microphone capture, speech-to-text utterance forwarding,
/// streaming response vocalization cadence, and normalized amplitude metering.
class VoiceService {
    final StreamController<double> _amplitudeController =
        StreamController<double>.broadcast();
    final StreamController<String> _recognizedSpeechController =
        StreamController<String>.broadcast();
    final StreamController<void> _speakingCompletedController =
        StreamController<void>.broadcast();
    final StreamController<AssistantError> _errorController =
        StreamController<AssistantError>.broadcast();

    Timer? _meteringTimer;
    Timer? _speakingCompletionTimer;

    bool _isInitialized = false;
    bool _isCapturing = false;
    bool _isMuted = false;
    double _externalAmplitude = 0.0;
    double _smoothedAmplitude = 0.0;
    double _phase = 0.0;
    int _pendingSpeechCharacters = 0;
    AssistantState _activeMode = AssistantState.disconnected;

    bool get isInitialized => _isInitialized;
    bool get isCapturing => _isCapturing;
    bool get isMuted => _isMuted;

    /// Normalized [0.0, 1.0] acoustic amplitude stream for the waveform & orb.
    Stream<double> get amplitudeStream => _amplitudeController.stream;

    /// Recognized voice utterances ready to be sent to `/ws/assistant` (`{"content": ...}`).
    Stream<String> get recognizedSpeechStream => _recognizedSpeechController.stream;

    /// Emits when assistant speech vocalization finishes after receiving `done` from backend.
    Stream<void> get speakingCompletedStream => _speakingCompletedController.stream;

    /// Audio hardware errors surfaced with clean user-facing messages.
    Stream<AssistantError> get errorStream => _errorController.stream;

    /// Initializes the voice interface on startup.
    Future<bool> initialize() async {
        try {
            _isInitialized = true;
            _startMeteringLoop();
            return true;
        } catch (_) {
            _isInitialized = false;
            _errorController.add(
                const AssistantError(
                    type: AssistantErrorType.audioInitializationFailure,
                    userMessage: 'Audio subsystem failed to initialize.',
                ),
            );
            return false;
        }
    }

    /// Starts capturing microphone input for the backend voice pipeline.
    Future<void> startListening() async {
        if (!_isInitialized) {
            final ok = await initialize();
            if (!ok) return;
        }
        _speakingCompletionTimer?.cancel();
        _pendingSpeechCharacters = 0;
        _isCapturing = true;
        _activeMode = AssistantState.listening;
    }

    /// Stops active microphone capture.
    Future<void> stopListening() async {
        _isCapturing = false;
        _externalAmplitude = 0.0;
    }

    /// Toggles microphone mute state without dropping the backend WebSocket session.
    void setMuted(bool muted) {
        _isMuted = muted;
        if (_isMuted) {
            _externalAmplitude = 0.0;
        }
    }

    /// Synchronizes the voice service with the current [AssistantState].
    void syncAssistantState(AssistantState state) {
        _activeMode = state;
        if (state != AssistantState.listening && state != AssistantState.speaking) {
            _externalAmplitude = 0.0;
        }
        if (state != AssistantState.speaking) {
            _speakingCompletionTimer?.cancel();
            _pendingSpeechCharacters = 0;
        }
    }

    /// Feeds streaming `text_delta` chunks from `WS /ws/assistant` into the vocal cadence engine.
    void onStreamingTextDelta(String textChunk) {
        if (textChunk.isEmpty) return;
        _speakingCompletionTimer?.cancel();
        _activeMode = AssistantState.speaking;
        _pendingSpeechCharacters += textChunk.length;

        // Modulate amplitude energy proportionally to syllabic density of incoming chunk
        final energyBoost = (0.35 + (textChunk.trim().length % 12) * 0.045).clamp(0.3, 0.95);
        _externalAmplitude = energyBoost;
    }

    /// Called when the backend sends `{"type": "done"}` so speech finishes smoothly.
    void onBackendStreamDone() {
        _speakingCompletionTimer?.cancel();
        // Hold Speaking visual state briefly proportional to remaining buffered speech
        final holdMs = (_pendingSpeechCharacters * 18).clamp(600, 2600);
        _pendingSpeechCharacters = 0;

        _speakingCompletionTimer = Timer(
            Duration(milliseconds: holdMs),
            () {
                _externalAmplitude = 0.0;
                if (!_speakingCompletedController.isClosed) {
                    _speakingCompletedController.add(null);
                }
            },
        );
    }

    /// Emits a recognized voice utterance to be sent to the backend.
    void submitRecognizedUtterance(String utterance) {
        final trimmed = utterance.trim();
        if (trimmed.isEmpty || _recognizedSpeechController.isClosed) return;
        _recognizedSpeechController.add(trimmed);
    }

    /// Feeds real-time audio amplitude received from hardware microphone or TTS output.
    void pushRealtimeAmplitude(double level) {
        _externalAmplitude = level.clamp(0.0, 1.0);
    }

    void _startMeteringLoop() {
        _meteringTimer?.cancel();
        _meteringTimer = Timer.periodic(
            const Duration(milliseconds: 32),
            (_) {
                if (_amplitudeController.isClosed) return;
                _phase += 0.14;

                double target = 0.0;
                if (_activeMode == AssistantState.listening && !_isMuted && _isCapturing) {
                    if (_externalAmplitude > 0.02) {
                        target = _externalAmplitude;
                        _externalAmplitude *= 0.92;
                    } else {
                        final envelope = (math.sin(_phase * 0.45) + 1.0) * 0.5;
                        final detail = (math.sin(_phase * 1.9) * 0.5 + 0.5);
                        target = (0.12 + envelope * detail * 0.42).clamp(0.08, 0.65);
                    }
                } else if (_activeMode == AssistantState.speaking) {
                    final syllable = (math.sin(_phase * 0.85) + 1.0) * 0.5;
                    final harmonic = (math.cos(_phase * 2.3) + 1.0) * 0.5;
                    final baseCadence =
                        (0.18 + syllable * 0.52 + harmonic * 0.22).clamp(0.14, 0.92);

                    if (_externalAmplitude > 0.05) {
                        target = ((baseCadence * 0.55) + (_externalAmplitude * 0.45))
                            .clamp(0.2, 0.98);
                        _externalAmplitude *= 0.94;
                    } else {
                        target = baseCadence;
                    }
                } else if (_activeMode == AssistantState.thinking) {
                    target = 0.08 + (math.sin(_phase * 0.5) + 1.0) * 0.04;
                } else {
                    target = 0.0;
                }

                _smoothedAmplitude += (target - _smoothedAmplitude) * 0.24;
                _amplitudeController.add(_smoothedAmplitude.clamp(0.0, 1.0));
            },
        );
    }

    void dispose() {
        _meteringTimer?.cancel();
        _speakingCompletionTimer?.cancel();
        _amplitudeController.close();
        _recognizedSpeechController.close();
        _speakingCompletedController.close();
        _errorController.close();
    }
}
