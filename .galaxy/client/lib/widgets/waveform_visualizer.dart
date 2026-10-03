import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/assistant_state.dart';

/// Dynamic multi-harmonic waveform visualizer synchronized with voice/audio amplitude.
class WaveformVisualizer extends StatefulWidget {
    final AssistantState state;
    final double amplitude;
    final bool isMuted;
    final double width;
    final double height;

    const WaveformVisualizer({
        super.key,
        required this.state,
        required this.amplitude,
        required this.isMuted,
        this.width = 340,
        this.height = 56,
    });

    @override
    State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer>
    with SingleTickerProviderStateMixin {
    late final AnimationController _waveController;

    @override
    void initState() {
        super.initState();
        _waveController = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 2000),
        )..repeat();
    }

    @override
    void dispose() {
        _waveController.dispose();
        super.dispose();
    }

    Color _waveColor() {
        if (widget.isMuted || widget.state == AssistantState.disconnected) {
            return const Color(0xFF475569);
        }
        switch (widget.state) {
            case AssistantState.listening:
                return const Color(0xFF06B6D4);
            case AssistantState.thinking:
                return const Color(0xFF818CF8);
            case AssistantState.speaking:
                return const Color(0xFF22D3EE);
            case AssistantState.connecting:
                return const Color(0xFF38BDF8);
            case AssistantState.error:
                return const Color(0xFFF43F5E);
            case AssistantState.disconnected:
                return const Color(0xFF475569);
        }
    }

    @override
    Widget build(BuildContext context) {
        final color = _waveColor();
        final isActive = (widget.state == AssistantState.listening && !widget.isMuted) ||
            widget.state == AssistantState.speaking ||
            widget.state == AssistantState.thinking;

        return SizedBox(
            width: widget.width,
            height: widget.height,
            child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, _) {
                    return CustomPaint(
                        painter: _WaveformPainter(
                            phase: _waveController.value * math.pi * 2,
                            amplitude: isActive ? widget.amplitude : 0.02,
                            primaryColor: color,
                            isSpeaking: widget.state == AssistantState.speaking,
                            isInactive: !isActive,
                        ),
                    );
                },
            ),
        );
    }
}

class _WaveformPainter extends CustomPainter {
    final double phase;
    final double amplitude;
    final Color primaryColor;
    final bool isSpeaking;
    final bool isInactive;

    const _WaveformPainter({
        required this.phase,
        required this.amplitude,
        required this.primaryColor,
        required this.isSpeaking,
        required this.isInactive,
    });

    @override
    void paint(Canvas canvas, Size size) {
        final centerY = size.height / 2;
        const int barCount = 35;
        final double spacing = size.width / (barCount - 1);

        // Baseline hairline
        final baselinePaint = Paint()
            ..color = primaryColor.withValues(alpha: isInactive ? 0.14 : 0.22)
            ..strokeWidth = 1.0;

        canvas.drawLine(
            Offset(0, centerY),
            Offset(size.width, centerY),
            baselinePaint,
        );

        // Vertical symmetric harmonic bars with Gaussian window envelope
        final barPaint = Paint()
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 2.4;

        for (int i = 0; i < barCount; i++) {
            final normalizedX = (i / (barCount - 1)) * 2.0 - 1.0; // [-1, 1]
            final window = math.exp(-3.2 * normalizedX * normalizedX);

            final waveA = math.sin((i * 0.42) + phase);
            final waveB = math.cos((i * 0.78) - phase * 1.4);
            final combined = ((waveA * 0.65 + waveB * 0.35) + 1.0) * 0.5;

            final effectiveAmp = isInactive
                ? 0.03
                : (amplitude * (isSpeaking ? 1.25 : 0.95)).clamp(0.06, 1.0);

            final halfHeight = (2.0 + combined * effectiveAmp * window * (size.height * 0.46))
                .clamp(1.5, size.height * 0.48);

            final alpha = isInactive
                ? 0.22
                : (0.30 + window * 0.65).clamp(0.25, 0.95);

            barPaint.color = primaryColor.withValues(alpha: alpha);

            final x = i * spacing;
            canvas.drawLine(
                Offset(x, centerY - halfHeight),
                Offset(x, centerY + halfHeight),
                barPaint,
            );
        }
    }

    @override
    bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
        return oldDelegate.phase != phase ||
            oldDelegate.amplitude != amplitude ||
            oldDelegate.primaryColor != primaryColor ||
            oldDelegate.isInactive != isInactive;
    }
}
