import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import '../models/assistant_state.dart';
import '../models/audio_packet.dart';

/// Abstract contract for Flutter Desktop audio capture and playback.
///
/// Designed to decouple the UI and state management from desktop hardware drivers,
/// enabling effortless swapping between simulated amplitude generators and
/// native desktop audio backends (e.g. record/audioplayers/miniaudio).
abstract class AudioService {
    /// Continuous stream of audio packets containing amplitude and frequency bands.
    Stream<AudioPacket> get amplitudeStream;

    /// Indicates whether the active provider is running simulated amplitude data.
    bool get isSimulated;

    /// Current microphone mute or paused status.
    bool get isMicrophoneMuted;

    /// Initialize desktop audio subsystems.
    Future<void> initialize();

    /// Begin capturing microphone input from desktop hardware.
    Future<void> startCapture();

    /// Halt microphone capture.
    Future<void> stopCapture();

    /// Toggle microphone mute state.
    void toggleMute();

    /// Feed incoming audio bytes from backend assistant speech for visualization.
    void feedIncomingAudio(Uint8List pcmBytes);

    /// Synchronize the audio amplitude generator with the assistant's state.
    void setAssistantState(AssistantState state);

    /// Dispose resources, streams, and ticker loops.
    void dispose();
}

/// Desktop audio service with mathematical simulation provider and native hook points.
class DesktopAudioService implements AudioService {
    final StreamController<AudioPacket> _amplitudeController =
        StreamController<AudioPacket>.broadcast();

    Timer? _simulationTicker;
    double _phase = 0.0;
    bool _isMuted = false;
    AssistantState _currentState = AssistantState.disconnected;
    DateTime _lastRealFeed = DateTime.fromMillisecondsSinceEpoch(0);

    @override
    Stream<AudioPacket> get amplitudeStream => _amplitudeController.stream;

    @override
    bool get isSimulated => true; // Clearly identified as simulation until native driver binds

    @override
    bool get isMicrophoneMuted => _isMuted;

    @override
    Future<void> initialize() async {
        _startAmplitudeGenerator();
    }

    @override
    Future<void> startCapture() async {
        _isMuted = false;
    }

    @override
    Future<void> stopCapture() async {
        _isMuted = true;
    }

    @override
    void toggleMute() {
        _isMuted = !_isMuted;
    }

    @override
    void feedIncomingAudio(Uint8List pcmBytes) {
        _lastRealFeed = DateTime.now();
        final packet = AudioPacket.fromPcm16(pcmBytes);
        if (!_amplitudeController.isClosed) {
            _amplitudeController.add(packet);
        }
    }

    @override
    void setAssistantState(AssistantState state) {
        _currentState = state;
    }

    /// Generates smooth mathematical amplitude waveforms when real hardware is not feeding.
    void _startAmplitudeGenerator() {
        _simulationTicker?.cancel();
        _simulationTicker = Timer.periodic(
            const Duration(milliseconds: 33), // ~30 FPS visualization updates
            (_) => _tick(),
        );
    }

    void _tick() {
        if (_amplitudeController.isClosed) return;

        // If real audio was fed within the last 150ms, let real data take precedence
        if (DateTime.now().difference(_lastRealFeed).inMilliseconds < 150) {
            return;
        }

        _phase += 0.15;
        if (_phase > 2 * math.pi) {
            _phase -= 2 * math.pi;
        }

        double targetAmp = 0.0;
        final randomJitter = math.Random().nextDouble() * 0.12;

        if (_isMuted || _currentState == AssistantState.disconnected || _currentState == AssistantState.error) {
            targetAmp = 0.0;
        } else if (_currentState == AssistantState.listening) {
            // Organic, breathing voice-ready amplitude
            targetAmp = 0.28 + 0.22 * math.sin(_phase * 2.1) + randomJitter;
        } else if (_currentState == AssistantState.thinking) {
            // Subtle slow undulating wave
            targetAmp = 0.12 + 0.08 * math.sin(_phase * 0.8);
        } else if (_currentState == AssistantState.speaking) {
            // Dynamic speaking wave envelope with rhythmic bursts
            final voicePattern = math.sin(_phase * 3.4) * math.cos(_phase * 1.7);
            targetAmp = 0.45 + 0.35 * voicePattern.abs() + randomJitter;
        } else if (_currentState == AssistantState.connecting) {
            targetAmp = 0.08 + 0.05 * math.sin(_phase);
        }

        final clampedAmp = targetAmp.clamp(0.0, 1.0);

        // Generate 24 multi-band harmonic frequency bars
        final bands = List<double>.filled(24, 0.0);
        for (int i = 0; i < 24; i++) {
            final harmonic = math.sin(_phase * 2.5 + (i * 0.35)).abs();
            final envelope = 1.0 - (i / 24.0) * 0.5;
            bands[i] = (clampedAmp * harmonic * envelope).clamp(0.0, 1.0);
        }

        final packet = AudioPacket(
            amplitude: clampedAmp,
            frequencyBands: bands,
            timestamp: DateTime.now(),
        );

        _amplitudeController.add(packet);
    }

    @override
    void dispose() {
        _simulationTicker?.cancel();
        _simulationTicker = null;
        _amplitudeController.close();
    }
}
