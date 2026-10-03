import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/assistant_state.dart';

/// Central circular AI orb with breathing, pulsing, rotation, and dynamic scale animations.
class AIOrb extends StatefulWidget {
    final AssistantState state;
    final double amplitude;
    final bool isMuted;
    final double size;
    final VoidCallback onTap;

    const AIOrb({
        super.key,
        required this.state,
        required this.amplitude,
        required this.isMuted,
        required this.size,
        required this.onTap,
    });

    @override
    State<AIOrb> createState() => _AIOrbState();
}

class _AIOrbState extends State<AIOrb> with TickerProviderStateMixin {
    late final AnimationController _breathingController;
    late final AnimationController _rotationController;
    late final AnimationController _pulseController;
    bool _isHovered = false;

    @override
    void initState() {
        super.initState();
        _breathingController = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 3600),
        )..repeat(reverse: true);

        _rotationController = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 9000),
        )..repeat();

        _pulseController = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 1400),
        )..repeat(reverse: true);
    }

    @override
    void didUpdateWidget(covariant AIOrb oldWidget) {
        super.didUpdateWidget(oldWidget);
        if (oldWidget.state != widget.state) {
            _syncAnimationSpeeds();
        }
    }

    void _syncAnimationSpeeds() {
        switch (widget.state) {
            case AssistantState.thinking:
                _rotationController.duration = const Duration(milliseconds: 3200);
                _rotationController.repeat();
                break;
            case AssistantState.speaking:
                _rotationController.duration = const Duration(milliseconds: 6500);
                _rotationController.repeat();
                break;
            case AssistantState.connecting:
                _rotationController.duration = const Duration(milliseconds: 4500);
                _rotationController.repeat();
                break;
            default:
                _rotationController.duration = const Duration(milliseconds: 11000);
                _rotationController.repeat();
                break;
        }
    }

    Color _primaryAccentColor() {
        if (widget.isMuted && widget.state == AssistantState.listening) {
            return const Color(0xFF64748B);
        }
        switch (widget.state) {
            case AssistantState.disconnected:
                return const Color(0xFF475569);
            case AssistantState.connecting:
                return const Color(0xFF38BDF8);
            case AssistantState.listening:
                return const Color(0xFF06B6D4);
            case AssistantState.thinking:
                return const Color(0xFF818CF8);
            case AssistantState.speaking:
                return const Color(0xFF22D3EE);
            case AssistantState.error:
                return const Color(0xFFF43F5E);
        }
    }

    Color _secondaryHaloColor() {
        switch (widget.state) {
            case AssistantState.disconnected:
                return const Color(0xFF1E293B);
            case AssistantState.connecting:
                return const Color(0xFF0284C7);
            case AssistantState.listening:
                return const Color(0xFF0EA5E9);
            case AssistantState.thinking:
                return const Color(0xFF6366F1);
            case AssistantState.speaking:
                return const Color(0xFF06B6D4);
            case AssistantState.error:
                return const Color(0xFFE11D48);
        }
    }

    @override
    void dispose() {
        _breathingController.dispose();
        _rotationController.dispose();
        _pulseController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        final primaryColor = _primaryAccentColor();
        final secondaryColor = _secondaryHaloColor();

        return MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: GestureDetector(
                onTap: widget.onTap,
                child: AnimatedBuilder(
                    animation: Listenable.merge([
                        _breathingController,
                        _rotationController,
                        _pulseController,
                    ]),
                    builder: (context, _) {
                        final breath = Curves.easeInOutSine.transform(
                            _breathingController.value,
                        );
                        final pulse = Curves.easeInOut.transform(
                            _pulseController.value,
                        );

                        double dynamicScale = 1.0 + (breath * 0.035);
                        if (widget.state == AssistantState.listening && !widget.isMuted) {
                            dynamicScale += widget.amplitude * 0.12;
                        } else if (widget.state == AssistantState.speaking) {
                            dynamicScale += (widget.amplitude * 0.18) + (pulse * 0.04);
                        } else if (widget.state == AssistantState.disconnected) {
                            dynamicScale = 0.94 + (breath * 0.015);
                        }
                        if (_isHovered) {
                            dynamicScale += 0.025;
                        }

                        return Transform.scale(
                            scale: dynamicScale,
                            child: SizedBox(
                                width: widget.size,
                                height: widget.size,
                                child: CustomPaint(
                                    painter: _OrbPainter(
                                        state: widget.state,
                                        primaryColor: primaryColor,
                                        secondaryColor: secondaryColor,
                                        rotationAngle: _rotationController.value * math.pi * 2,
                                        breathValue: breath,
                                        pulseValue: pulse,
                                        amplitude: widget.amplitude,
                                        isMuted: widget.isMuted,
                                    ),
                                    child: Center(
                                        child: _buildCenterGlyph(primaryColor),
                                    ),
                                ),
                            ),
                        );
                    },
                ),
            ),
        );
    }

    Widget _buildCenterGlyph(Color accent) {
        IconData icon;
        if (widget.state == AssistantState.disconnected) {
            icon = Icons.portable_wifi_off_outlined;
        } else if (widget.state == AssistantState.error) {
            icon = Icons.error_outline_rounded;
        } else if (widget.isMuted) {
            icon = Icons.mic_off_rounded;
        } else if (widget.state == AssistantState.speaking) {
            icon = Icons.graphic_eq_rounded;
        } else if (widget.state == AssistantState.thinking) {
            icon = Icons.auto_awesome_motion_rounded;
        } else {
            icon = Icons.mic_none_rounded;
        }

        return AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: Icon(
                icon,
                key: ValueKey<Object>(Object.hash(widget.state, widget.isMuted)),
                size: widget.size * 0.16,
                color: Colors.white.withValues(
                    alpha: widget.state == AssistantState.disconnected ? 0.45 : 0.92,
                ),
                shadows: [
                    Shadow(
                        color: accent.withValues(alpha: 0.65),
                        blurRadius: 18,
                    ),
                ],
            ),
        );
    }
}

class _OrbPainter extends CustomPainter {
    final AssistantState state;
    final Color primaryColor;
    final Color secondaryColor;
    final double rotationAngle;
    final double breathValue;
    final double pulseValue;
    final double amplitude;
    final bool isMuted;

    const _OrbPainter({
        required this.state,
        required this.primaryColor,
        required this.secondaryColor,
        required this.rotationAngle,
        required this.breathValue,
        required this.pulseValue,
        required this.amplitude,
        required this.isMuted,
    });

    @override
    void paint(Canvas canvas, Size size) {
        final center = Offset(size.width / 2, size.height / 2);
        final baseRadius = size.width * 0.28;
        final isInactive = state == AssistantState.disconnected;

        // 1. Ambient outer radial glow
        final glowMultiplier = state == AssistantState.speaking
            ? (1.35 + amplitude * 0.45)
            : state == AssistantState.listening
                ? (1.15 + amplitude * 0.30)
                : isInactive
                    ? 0.65
                    : 1.05;

        final outerGlowPaint = Paint()
            ..shader = RadialGradient(
                colors: [
                    primaryColor.withValues(alpha: isInactive ? 0.08 : 0.26),
                    secondaryColor.withValues(alpha: isInactive ? 0.03 : 0.09),
                    Colors.transparent,
                ],
                stops: const [0.0, 0.55, 1.0],
            ).createShader(
                Rect.fromCircle(
                    center: center,
                    radius: baseRadius * 1.85 * glowMultiplier,
                ),
            );

        canvas.drawCircle(
            center,
            baseRadius * 1.85 * glowMultiplier,
            outerGlowPaint,
        );

        // 2. Pulsing concentric acoustic ripple rings
        if (!isInactive && !isMuted) {
            final rippleCount = state == AssistantState.speaking ? 3 : 2;
            for (int i = 0; i < rippleCount; i++) {
                final phaseOffset = ((pulseValue + (i * 0.33)) % 1.0);
                final rippleRadius = baseRadius * (1.08 + phaseOffset * 0.55 + amplitude * 0.18);
                final rippleAlpha = ((1.0 - phaseOffset) * 0.28).clamp(0.0, 0.35);

                final ripplePaint = Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 1.2
                    ..color = primaryColor.withValues(alpha: rippleAlpha);

                canvas.drawCircle(center, rippleRadius, ripplePaint);
            }
        }

        // 3. Rotating orbital arc ring (prominent during Thinking & Connecting)
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(rotationAngle);

        final orbitalRadius = baseRadius * 1.16;
        final orbitalRect = Rect.fromCircle(
            center: Offset.zero,
            radius: orbitalRadius,
        );

        final sweepOpacity = state == AssistantState.thinking
            ? 0.75
            : state == AssistantState.connecting
                ? 0.60
                : isInactive
                    ? 0.12
                    : 0.32;

        final orbitalPaint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = state == AssistantState.thinking ? 2.2 : 1.4
            ..strokeCap = StrokeCap.round
            ..shader = SweepGradient(
                colors: [
                    Colors.transparent,
                    primaryColor.withValues(alpha: sweepOpacity),
                    secondaryColor.withValues(alpha: sweepOpacity * 0.5),
                    Colors.transparent,
                ],
                stops: const [0.0, 0.45, 0.75, 1.0],
            ).createShader(orbitalRect);

        canvas.drawArc(orbitalRect, 0, math.pi * 1.65, false, orbitalPaint);
        canvas.restore();

        // 4. Core dark glassmorphic sphere with inner rim illumination
        final coreRect = Rect.fromCircle(center: center, radius: baseRadius);
        final coreSpherePaint = Paint()
            ..shader = RadialGradient(
                center: const Alignment(-0.28, -0.32),
                radius: 1.1,
                colors: [
                    primaryColor.withValues(alpha: isInactive ? 0.14 : 0.38),
                    const Color(0xFF0F172A),
                    const Color(0xFF07090E),
                ],
                stops: const [0.0, 0.62, 1.0],
            ).createShader(coreRect);

        canvas.drawCircle(center, baseRadius, coreSpherePaint);

        // 5. Crisp 1px specular rim border
        final rimPaint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.25
            ..shader = LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                    primaryColor.withValues(alpha: isInactive ? 0.22 : 0.72),
                    secondaryColor.withValues(alpha: 0.15),
                    primaryColor.withValues(alpha: isInactive ? 0.10 : 0.40),
                ],
            ).createShader(coreRect);

        canvas.drawCircle(center, baseRadius, rimPaint);
    }

    @override
    bool shouldRepaint(covariant _OrbPainter oldDelegate) {
        return oldDelegate.state != state ||
            oldDelegate.rotationAngle != rotationAngle ||
            oldDelegate.breathValue != breathValue ||
            oldDelegate.pulseValue != pulseValue ||
            oldDelegate.amplitude != amplitude ||
            oldDelegate.isMuted != isMuted;
    }
}
