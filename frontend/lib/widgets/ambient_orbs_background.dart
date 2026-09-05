import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/agent_config.dart';
import '../models/assistant_state.dart';

/// Ambient neon floating background orbs and cyber-grid effect.
///
/// Smoothly renders multi-layered drifting neon orbs in deep purple, blue,
/// cyan, and violet with continuous trigonometric animations.
class AmbientOrbsBackground extends StatefulWidget {
    final AssistantState state;
    final NeonThemePalette palette;
    final bool isEnabled;

    const AmbientOrbsBackground({
        super.key,
        required this.state,
        required this.palette,
        this.isEnabled = true,
    });

    @override
    State<AmbientOrbsBackground> createState() => _AmbientOrbsBackgroundState();
}

class _AmbientOrbsBackgroundState extends State<AmbientOrbsBackground>
    with SingleTickerProviderStateMixin {
    late AnimationController _animController;

    @override
    void initState() {
        super.initState();
        _animController = AnimationController(
            vsync: this,
            duration: const Duration(seconds: 24),
        )..repeat();
    }

    @override
    void dispose() {
        _animController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        if (!widget.isEnabled) {
            return Container(color: widget.palette.background);
        }

        return AnimatedBuilder(
            animation: _animController,
            builder: (context, _) {
                return CustomPaint(
                    size: Size.infinite,
                    painter: _AmbientOrbsPainter(
                        progress: _animController.value,
                        state: widget.state,
                        palette: widget.palette,
                    ),
                );
            },
        );
    }
}

class _AmbientOrbsPainter extends CustomPainter {
    final double progress;
    final AssistantState state;
    final NeonThemePalette palette;

    _AmbientOrbsPainter({
        required this.progress,
        required this.state,
        required this.palette,
    });

    @override
    void paint(Canvas canvas, Size size) {
        // 1. Deep Space Canvas Fill
        final bgPaint = Paint()..color = palette.background;
        canvas.drawRect(Offset.zero & size, bgPaint);

        // 2. Subtle Cyber Starfield & Floating Micro-Dots
        final random = math.Random(42);
        final dotPaint = Paint()..style = PaintingStyle.fill;
        for (int i = 0; i < 40; i++) {
            final rx = random.nextDouble() * size.width;
            final ry = random.nextDouble() * size.height;
            final floatOffset = math.sin((progress * 2 * math.pi) + i) * 8.0;
            final dotAlpha = 0.08 + (math.sin(progress * 4 * math.pi + i) * 0.04);
            dotPaint.color = palette.primary.withValues(alpha: dotAlpha.clamp(0.02, 0.2));
            canvas.drawCircle(Offset(rx, ry + floatOffset), 1.2, dotPaint);
        }

        // 3. Dynamic Large Ambient Floating Orbs
        // Orb 1: Top-Left to Center Drifting Orb (Neon Purple / Palette Primary)
        final p1 = progress * 2 * math.pi;
        final o1x = size.width * (0.25 + 0.12 * math.sin(p1));
        final o1y = size.height * (0.28 + 0.10 * math.cos(p1 * 0.7));
        final o1r = size.width * 0.42;
        _drawGlowingOrb(
            canvas,
            Offset(o1x, o1y),
            o1r,
            palette.primary,
            0.18,
        );

        // Orb 2: Bottom-Right Drifting Orb (Electric Blue / Palette Secondary)
        final p2 = (progress + 0.35) * 2 * math.pi;
        final o2x = size.width * (0.75 + 0.14 * math.cos(p2 * 0.8));
        final o2y = size.height * (0.68 + 0.12 * math.sin(p2));
        final o2r = size.width * 0.48;
        _drawGlowingOrb(
            canvas,
            Offset(o2x, o2y),
            o2r,
            palette.secondary,
            0.15,
        );

        // Orb 3: Central Ambient Core Reacting to State Accent
        final p3 = (progress + 0.7) * 2 * math.pi;
        final o3x = size.width * (0.50 + 0.08 * math.sin(p3 * 1.2));
        final o3y = size.height * (0.50 + 0.08 * math.cos(p3 * 0.9));
        final o3r = size.width * 0.35;
        _drawGlowingOrb(
            canvas,
            Offset(o3x, o3y),
            o3r,
            state.neonColor,
            0.16,
        );

        // Orb 4: Top-Right Floating Neon Filament Orb
        final p4 = (progress + 0.5) * 2 * math.pi;
        final o4x = size.width * (0.85 + 0.08 * math.sin(p4 * 0.6));
        final o4y = size.height * (0.20 + 0.08 * math.cos(p4 * 0.8));
        final o4r = size.width * 0.30;
        _drawGlowingOrb(
            canvas,
            Offset(o4x, o4y),
            o4r,
            palette.accent,
            0.12,
        );
    }

    void _drawGlowingOrb(
        Canvas canvas,
        Offset center,
        double radius,
        Color color,
        double maxAlpha,
    ) {
        final paint = Paint()
            ..shader = RadialGradient(
                colors: [
                    color.withValues(alpha: maxAlpha),
                    color.withValues(alpha: maxAlpha * 0.45),
                    color.withValues(alpha: maxAlpha * 0.1),
                    Colors.transparent,
                ],
                stops: const [0.0, 0.4, 0.75, 1.0],
            ).createShader(Rect.fromCircle(center: center, radius: radius));

        canvas.drawCircle(center, radius, paint);
    }

    @override
    bool shouldRepaint(covariant _AmbientOrbsPainter oldDelegate) {
        return oldDelegate.progress != progress ||
            oldDelegate.state != state ||
            oldDelegate.palette != palette;
    }
}
