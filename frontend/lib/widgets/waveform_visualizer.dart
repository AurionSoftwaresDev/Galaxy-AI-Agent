import 'package:flutter/material.dart';
import '../models/assistant_state.dart';
import '../models/audio_packet.dart';

/// Desktop waveform visualization widget for Galaxy AI.
///
/// Dynamically renders multi-band audio bars reflecting microphone input
/// while listening and assistant synthesized audio while speaking.
class WaveformVisualizer extends StatelessWidget {
    final AssistantState state;
    final AudioPacket audioPacket;
    final double width;
    final double height;

    const WaveformVisualizer({
        super.key,
        required this.state,
        required this.audioPacket,
        this.width = 380,
        this.height = 48,
    });

    @override
    Widget build(BuildContext context) {
        return RepaintBoundary(
            child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: width),
                child: SizedBox(
                    width: double.infinity,
                    height: height,
                    child: CustomPaint(
                        painter: _WaveformCustomPainter(
                            state: state,
                            amplitude: audioPacket.amplitude,
                            frequencyBands: audioPacket.frequencyBands,
                        ),
                    ),
                ),
            ),
        );
    }
}

class _WaveformCustomPainter extends CustomPainter {
    final AssistantState state;
    final double amplitude;
    final List<double> frequencyBands;

    _WaveformCustomPainter({
        required this.state,
        required this.amplitude,
        required this.frequencyBands,
    });

    @override
    void paint(Canvas canvas, Size size) {
        const totalBars = 32;
        final barSpacing = size.width / totalBars;
        final barWidth = (barSpacing * 0.45).clamp(2.5, 4.5);
        final centerY = size.height / 2;

        final colors = _getWaveformColors();

        final paint = Paint()
            ..style = PaintingStyle.fill
            ..strokeCap = StrokeCap.round;

        for (int i = 0; i < totalBars; i++) {
            // Symmetry mapping: highest energy in the middle
            final distFromCenter = (i - totalBars / 2).abs() / (totalBars / 2);
            final centerFactor = 1.0 - (distFromCenter * 0.65);

            // Fetch band energy or interpolate
            double bandEnergy = 0.0;
            if (frequencyBands.isNotEmpty) {
                final bandIndex = (distFromCenter * (frequencyBands.length - 1)).round();
                bandEnergy = frequencyBands[bandIndex.clamp(0, frequencyBands.length - 1)];
            } else {
                bandEnergy = amplitude;
            }

            // Compute height
            double barHeight = 0.0;
            if (state == AssistantState.listening || state == AssistantState.speaking) {
                barHeight = 4.0 + (size.height * 0.85 * bandEnergy * centerFactor);
            } else if (state == AssistantState.thinking || state == AssistantState.toolExecution || state == AssistantState.generating) {
                // Subtle moving wave during reasoning
                barHeight = 3.0 + (size.height * 0.35 * bandEnergy * centerFactor);
            } else {
                // Baseline resting idle line
                barHeight = 3.0;
            }

            barHeight = barHeight.clamp(3.0, size.height);

            final x = (i * barSpacing) + (barSpacing - barWidth) / 2;
            final top = centerY - (barHeight / 2);

            final barRect = RRect.fromRectAndRadius(
                Rect.fromLTWH(x, top, barWidth, barHeight),
                Radius.circular(barWidth / 2),
            );

            // Create linear gradient along the height
            paint.shader = LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                    colors.topColor.withValues(alpha: 0.9),
                    colors.bottomColor.withValues(alpha: 0.6),
                ],
            ).createShader(barRect.outerRect);

            canvas.drawRRect(barRect, paint);
        }
    }

    _WaveformColors _getWaveformColors() {
        switch (state) {
            case AssistantState.idle:
                return _WaveformColors(
                    topColor: const Color(0xFF818CF8),
                    bottomColor: const Color(0xFF4F46E5),
                );
            case AssistantState.listening:
                return _WaveformColors(
                    topColor: const Color(0xFF38BDF8),
                    bottomColor: const Color(0xFF0284C7),
                );
            case AssistantState.thinking:
                return _WaveformColors(
                    topColor: const Color(0xFFA78BFA),
                    bottomColor: const Color(0xFF6366F1),
                );
            case AssistantState.toolExecution:
                return _WaveformColors(
                    topColor: const Color(0xFFFBBF24),
                    bottomColor: const Color(0xFFD97706),
                );
            case AssistantState.generating:
                return _WaveformColors(
                    topColor: const Color(0xFF60A5FA),
                    bottomColor: const Color(0xFF2563EB),
                );
            case AssistantState.speaking:
                return _WaveformColors(
                    topColor: const Color(0xFF34D399),
                    bottomColor: const Color(0xFF0D9488),
                );
            case AssistantState.interrupted:
                return _WaveformColors(
                    topColor: const Color(0xFFF472B6),
                    bottomColor: const Color(0xFFBE185D),
                );
            case AssistantState.connecting:
                return _WaveformColors(
                    topColor: const Color(0xFF60A5FA),
                    bottomColor: const Color(0xFF1D4ED8),
                );
            case AssistantState.error:
                return _WaveformColors(
                    topColor: const Color(0xFFF87171),
                    bottomColor: const Color(0xFFDC2626),
                );
            case AssistantState.disconnected:
                return _WaveformColors(
                    topColor: const Color(0xFF475569),
                    bottomColor: const Color(0xFF334155),
                );
        }
    }

    @override
    bool shouldRepaint(covariant _WaveformCustomPainter oldDelegate) {
        return oldDelegate.amplitude != amplitude ||
            oldDelegate.state != state ||
            oldDelegate.frequencyBands != frequencyBands;
    }
}

class _WaveformColors {
    final Color topColor;
    final Color bottomColor;

    _WaveformColors({
        required this.topColor,
        required this.bottomColor,
    });
}
