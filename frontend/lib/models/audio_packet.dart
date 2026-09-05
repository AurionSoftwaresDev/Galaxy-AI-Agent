import 'dart:typed_data';

/// Represents an audio packet or amplitude reading for visualization and streaming.
class AudioPacket {
    /// Normalized root-mean-square amplitude between 0.0 (silent) and 1.0 (loud).
    final double amplitude;

    /// Raw PCM audio chunk bytes (optional when transmitting/receiving audio).
    final Uint8List? rawBytes;

    /// Frequency spectrum bar heights for fine-grained multi-band visualization.
    final List<double> frequencyBands;

    /// Timestamp of the audio reading.
    final DateTime timestamp;

    const AudioPacket({
        required this.amplitude,
        this.rawBytes,
        this.frequencyBands = const <double>[],
        required this.timestamp,
    });

    /// Factory for silent reading.
    factory AudioPacket.silent() {
        return AudioPacket(
            amplitude: 0.0,
            frequencyBands: List<double>.filled(32, 0.0),
            timestamp: DateTime.now(),
        );
    }

    /// Helper to compute amplitude from 16-bit signed PCM audio bytes.
    factory AudioPacket.fromPcm16(Uint8List pcmData) {
        if (pcmData.isEmpty) return AudioPacket.silent();

        final byteData = ByteData.sublistView(pcmData);
        final samplesCount = pcmData.length ~/ 2;
        if (samplesCount == 0) return AudioPacket.silent();

        double sumSquares = 0.0;
        for (int i = 0; i < samplesCount; i++) {
            final sample = byteData.getInt16(i * 2, Endian.little);
            final normalized = sample / 32768.0;
            sumSquares += normalized * normalized;
        }

        final rms = (sumSquares / samplesCount);
        final clampedRms = (rms * 2.5).clamp(0.0, 1.0);

        return AudioPacket(
            amplitude: clampedRms,
            rawBytes: pcmData,
            frequencyBands: _estimateBands(clampedRms),
            timestamp: DateTime.now(),
        );
    }

    static List<double> _estimateBands(double amp) {
        // Generate responsive wave frequency distribution based on energy
        final bands = List<double>.filled(24, 0.0);
        for (int i = 0; i < 24; i++) {
            final decay = 1.0 - (i / 24.0) * 0.4;
            bands[i] = (amp * decay).clamp(0.0, 1.0);
        }
        return bands;
    }
}
