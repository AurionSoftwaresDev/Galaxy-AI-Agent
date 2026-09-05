import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/assistant_state.dart';
import 'orb/orb_particle.dart';
import 'orb/volumetric_orb_painter.dart';

export 'orb/orb_particle.dart';
export 'orb/volumetric_orb_painter.dart';

/// Production-grade Agent Voice Orb & AI Core featuring volumetric glass texturing,
/// multi-layered atmospheric luminescence, dynamic gyroscopic orbits,
/// 3D synaptic particle constellation, and audio-reactive acoustic ripples.
class AiOrb extends StatefulWidget {
    final AssistantState state;
    final double amplitude;
    final VoidCallback onTap;
    final int particleCount;

    const AiOrb({
        super.key,
        required this.state,
        required this.amplitude,
        required this.onTap,
        this.particleCount = 140,
    });

    @override
    State<AiOrb> createState() => _AiOrbState();
}

class _AiOrbState extends State<AiOrb> with TickerProviderStateMixin {
    late AnimationController _rotationController;
    late AnimationController _pulseController;
    late AnimationController _vortexController;
    late AnimationController _breathingController;
    late AnimationController _rippleController;

    bool _isHovered = false;
    late List<OrbParticle> _particles;

    @override
    void initState() {
        super.initState();

        _rotationController = AnimationController(
            vsync: this,
            duration: const Duration(seconds: 16),
        )..repeat();

        _pulseController = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 1600),
        )..repeat(reverse: true);

        _vortexController = AnimationController(
            vsync: this,
            duration: const Duration(seconds: 5),
        )..repeat();

        _breathingController = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 3600),
        )..repeat(reverse: true);

        _rippleController = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 2400),
        )..repeat();

        _initParticles();
    }

    void _initParticles() {
        _particles = OrbParticle.generate(widget.particleCount);
    }

    @override
    void didUpdateWidget(covariant AiOrb oldWidget) {
        super.didUpdateWidget(oldWidget);
        if (oldWidget.particleCount != widget.particleCount) {
            _initParticles();
        }
    }

    @override
    void dispose() {
        _rotationController.dispose();
        _pulseController.dispose();
        _vortexController.dispose();
        _breathingController.dispose();
        _rippleController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return LayoutBuilder(
            builder: (context, constraints) {
                // Responsively scale to available width & height without exceeding container
                final maxSide = math.min(constraints.maxWidth, constraints.maxHeight);
                final orbSize = maxSide.isFinite && maxSide > 120 ? maxSide.clamp(140.0, 340.0) : 280.0;

                return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => setState(() => _isHovered = true),
                    onExit: (_) => setState(() => _isHovered = false),
                    child: GestureDetector(
                        onTap: widget.onTap,
                        child: AnimatedBuilder(
                            animation: Listenable.merge([
                                _rotationController,
                                _pulseController,
                                _vortexController,
                                _breathingController,
                                _rippleController,
                            ]),
                            builder: (context, _) {
                                return CustomPaint(
                                    size: Size(orbSize, orbSize),
                                    painter: VolumetricOrbPainter(
                                        state: widget.state,
                                        rotation: _rotationController.value * 2 * math.pi,
                                        pulse: _pulseController.value,
                                        vortex: _vortexController.value * 2 * math.pi,
                                        breathing: _breathingController.value,
                                        rippleProgress: _rippleController.value,
                                        amplitude: widget.amplitude,
                                        isHovered: _isHovered,
                                        particles: _particles,
                                    ),
                                );
                            },
                        ),
                    ),
                );
            },
        );
    }
}
