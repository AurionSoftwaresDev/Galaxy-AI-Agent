import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/assistant_state.dart';
import 'orb_particle.dart';

/// CustomPainter implementing 6-stage volumetric rendering for Galaxy AI Voice Orb:
/// 1. Atmospheric nebula back-glow
/// 2. Audio-reactive shockwave ripples
/// 3. Gyroscopic orbital sci-fi rings
/// 4. 3D synaptic particle constellation with filament web connections
/// 5. Volumetric glass core sphere with specular crescent reflection
/// 6. Center state functional icon glyph
class VolumetricOrbPainter extends CustomPainter {
    final double rotation;
    final double pulse;
    final double vortex;
    final double breathing;
    final double rippleProgress;
    final double amplitude;
    final AssistantState state;
    final bool isHovered;
    final List<OrbParticle> particles;

    const VolumetricOrbPainter({
        required this.rotation,
        required this.pulse,
        required this.vortex,
        required this.breathing,
        required this.rippleProgress,
        required this.amplitude,
        required this.state,
        required this.isHovered,
        required this.particles,
    });

    @override
    void paint(Canvas canvas, Size size) {
        final center = Offset(size.width / 2, size.height / 2);
        final maxRadius = size.width / 2;
        final primaryColor = state.neonColor;
        final secondaryColor = state.secondaryNeonColor;

        final bool isThinking = state == AssistantState.thinking;
        final bool isExecutingTool = state == AssistantState.toolExecution;
        final bool isSpeaking = state == AssistantState.speaking;
        final bool isListening = state == AssistantState.listening;

        final double ampNorm = amplitude.clamp(0.0, 1.0);
        final double hoverScale = isHovered ? 1.06 : 1.0;
        final double effectiveRadius = maxRadius * hoverScale;

        // 1. Multi-Stage Atmospheric Nebula Back-Glow
        _drawAtmosphericNebula(canvas, center, effectiveRadius, primaryColor, secondaryColor, ampNorm);

        // 2. Audio-Reactive Shockwave Ripples (Expanding outward waves)
        _drawAudioRipples(canvas, center, effectiveRadius, primaryColor, secondaryColor, ampNorm, isSpeaking, isListening);

        // 3. Gyroscopic Orbital Sci-Fi Rings
        _drawGyroscopicRings(canvas, center, effectiveRadius * 0.62, primaryColor, secondaryColor);

        // 4. Compute 3D Synaptic Particle Constellation
        _drawParticleConstellation(canvas, center, effectiveRadius, primaryColor, secondaryColor, ampNorm, isThinking, isExecutingTool, isSpeaking, isListening);

        // 5. Volumetric Glass Core Sphere with 3D Specular Highlight & Texture
        _drawVolumetricGlassCore(canvas, center, effectiveRadius * 0.27, primaryColor, secondaryColor, ampNorm);

        // 6. Center State Functional Glyph / Icon
        _drawCenterIconGlyph(canvas, center, effectiveRadius * 0.27, primaryColor);
    }

    /// Atmospheric outer nebula glow with chromatic dispersion
    void _drawAtmosphericNebula(Canvas canvas, Offset center, double radius, Color primary, Color secondary, double amp) {
        final double nebulaRadius = radius * (0.85 + (pulse * 0.08) + (amp * 0.18));
        final nebulaPaint = Paint()
            ..shader = RadialGradient(
                colors: [
                    primary.withValues(alpha: 0.42),
                    secondary.withValues(alpha: 0.24),
                    primary.withValues(alpha: 0.08),
                    Colors.transparent,
                ],
                stops: const [0.0, 0.45, 0.78, 1.0],
            ).createShader(Rect.fromCircle(center: center, radius: nebulaRadius));

        canvas.drawCircle(center, nebulaRadius, nebulaPaint);
    }

    /// Concentric acoustic energy waves that pulse smoothly outward
    void _drawAudioRipples(Canvas canvas, Offset center, double radius, Color primary, Color secondary, double amp, bool isSpeaking, bool isListening) {
        if (!isSpeaking && !isListening && amp < 0.05) return;

        final ripplePaint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;

        final int waves = isSpeaking ? 3 : 2;
        for (int i = 0; i < waves; i++) {
            final waveOffset = (rippleProgress + (i / waves)) % 1.0;
            final waveRadius = (radius * 0.32) + (waveOffset * radius * 0.58);
            final waveAlpha = (1.0 - waveOffset) * (0.35 + (amp * 0.45));

            if (waveAlpha <= 0.02) continue;

            ripplePaint
                ..color = (i % 2 == 0 ? primary : secondary).withValues(alpha: waveAlpha.clamp(0.0, 0.75))
                ..strokeWidth = 1.4 * (1.0 - (waveOffset * 0.6));

            canvas.drawCircle(center, waveRadius, ripplePaint);
        }
    }

    /// Futuristic dual gyroscopic orbital rings with glowing micro-notches
    void _drawGyroscopicRings(Canvas canvas, Offset center, double ringRadius, Color primary, Color secondary) {
        final ringPaint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.1;

        // Primary tilted orbital ellipse
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(rotation * 0.6);

        ringPaint.color = primary.withValues(alpha: 0.28);
        canvas.drawOval(
            Rect.fromCenter(center: Offset.zero, width: ringRadius * 2.1, height: ringRadius * 0.85),
            ringPaint,
        );

        // Counter-rotating secondary ring
        canvas.rotate(-rotation * 1.2);
        ringPaint.color = secondary.withValues(alpha: 0.22);
        canvas.drawOval(
            Rect.fromCenter(center: Offset.zero, width: ringRadius * 1.7, height: ringRadius * 0.65),
            ringPaint,
        );

        canvas.restore();
    }

    /// 3D-depth particle swarm with synaptic neural filaments
    void _drawParticleConstellation(
        Canvas canvas,
        Offset center,
        double maxRadius,
        Color primary,
        Color secondary,
        double amp,
        bool isThinking,
        bool isExecutingTool,
        bool isSpeaking,
        bool isListening,
    ) {
        final List<Offset> positions = [];
        final List<double> opacities = [];
        final List<double> particleSizes = [];
        final List<Color> particleColors = [];

        final ampBoost = amp * (isSpeaking ? 36.0 : (isListening ? 26.0 : 10.0));

        for (int i = 0; i < particles.length; i++) {
            final p = particles[i];

            double currentAngle = p.angle;
            double currentRadius = (p.baseRadiusFraction * maxRadius);

            // Calculate pseudo 3D Z-depth between -1.0 and 1.0
            final double zDepth = math.sin((rotation * p.speed) + p.depthPhase);

            if (isThinking) {
                // Rapid inward celestial vortex
                currentAngle += vortex * (1.6 + (p.ring * 0.35));
                currentRadius = (p.baseRadiusFraction * maxRadius * 0.62) +
                    (math.sin(vortex * 3 + p.pulseOffset) * 14.0);
            } else if (isExecutingTool) {
                // Synchronized dual orbital telemetry tracks
                final dir = p.ring % 2 == 0 ? 1.0 : -1.0;
                currentAngle += rotation * 2.0 * dir;
                currentRadius += math.sin(pulse * math.pi + p.ring) * 5.0;
            } else if (isSpeaking) {
                // Explosive acoustic dispersal wave
                currentAngle += rotation * p.speed * 1.4;
                final wavePush = math.sin((rotation * 4) + (p.ring * 1.6)) * ampBoost;
                currentRadius += wavePush.abs();
            } else {
                // Organic harmonic breathing float
                currentAngle += rotation * p.speed;
                currentRadius += math.sin((breathing * 2 * math.pi) + p.pulseOffset) * 7.0 + (ampBoost * 0.5);
            }

            final px = center.dx + currentRadius * math.cos(currentAngle);
            final py = center.dy + currentRadius * math.sin(currentAngle);
            positions.add(Offset(px, py));

            // Depth-based scaling & luminosity
            final depthFactor = 0.65 + 0.35 * zDepth; // Closer particles are larger & brighter
            final dotPulse = 0.5 + 0.5 * math.sin((pulse * 2 * math.pi) + p.pulseOffset);
            final alpha = ((0.38 + (dotPulse * 0.52)) * depthFactor).clamp(0.15, 1.0);

            opacities.add(alpha);
            particleSizes.add(p.size * (0.8 + 0.4 * depthFactor));
            particleColors.add(p.ring % 2 == 0 ? primary : secondary);
        }

        // Filament Web Connections between nearby nodes
        final filamentPaint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;

        final double maxLinkDist = isThinking ? 36.0 : (isSpeaking ? 48.0 : 40.0);
        final double maxDistSq = maxLinkDist * maxLinkDist;

        for (int i = 0; i < positions.length; i += 2) {
            final pt1 = positions[i];
            for (int j = i + 1; j < math.min(i + 7, positions.length); j++) {
                final pt2 = positions[j];
                final dx = pt1.dx - pt2.dx;
                final dy = pt1.dy - pt2.dy;
                final distSq = (dx * dx) + (dy * dy);

                if (distSq < maxDistSq) {
                    final fraction = 1.0 - (math.sqrt(distSq) / maxLinkDist);
                    final lineAlpha = (fraction * 0.32 * opacities[i]).clamp(0.0, 0.45);
                    filamentPaint
                        ..color = particleColors[i].withValues(alpha: lineAlpha)
                        ..strokeWidth = 0.85 * fraction;
                    canvas.drawLine(pt1, pt2, filamentPaint);
                }
            }
        }

        // Draw individual glowing dots
        final dotGlowPaint = Paint()..style = PaintingStyle.fill;
        final dotCorePaint = Paint()..style = PaintingStyle.fill;

        for (int i = 0; i < positions.length; i++) {
            final pt = positions[i];
            final alpha = opacities[i];
            final color = particleColors[i];
            final size = particleSizes[i];

            // Outer Neon Glow Halo
            dotGlowPaint.color = color.withValues(alpha: alpha * 0.45);
            canvas.drawCircle(pt, size * 2.2, dotGlowPaint);

            // Intense white-hot core dot
            dotCorePaint.color = Colors.white.withValues(alpha: alpha * 0.95);
            canvas.drawCircle(pt, size * 0.85, dotCorePaint);
        }
    }

    /// Volumetric 3D Glass Core Sphere with specular crescent reflection,
    /// deep refraction shading, and chromatic fresnel rim
    void _drawVolumetricGlassCore(Canvas canvas, Offset center, double baseRadius, Color primary, Color secondary, double amp) {
        final coreRadius = (baseRadius + (pulse * 3.5) + (amp * 12.0));

        // Outer Fresnel Bloom Rim
        final rimPaint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2
            ..shader = SweepGradient(
                colors: [
                    primary.withValues(alpha: 0.95),
                    secondary.withValues(alpha: 0.7),
                    Colors.white.withValues(alpha: 0.85),
                    primary.withValues(alpha: 0.95),
                ],
                transform: GradientRotation(rotation),
            ).createShader(Rect.fromCircle(center: center, radius: coreRadius));
        canvas.drawCircle(center, coreRadius + 1.2, rimPaint);

        // Volumetric 3D Sphere Shading (Off-center light source at -0.3, -0.35)
        final sphereShader = RadialGradient(
            center: const Alignment(-0.35, -0.4),
            radius: 0.95,
            colors: [
                Colors.white.withValues(alpha: 0.98),
                primary.withValues(alpha: 0.92),
                secondary.withValues(alpha: 0.75),
                const Color(0xFF030712).withValues(alpha: 0.94),
            ],
            stops: const [0.0, 0.32, 0.68, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: coreRadius));

        final corePaint = Paint()
            ..style = PaintingStyle.fill
            ..shader = sphereShader;
        canvas.drawCircle(center, coreRadius, corePaint);

        // Glass Specular Crescent Reflection (Simulates smooth polished glass surface texture)
        final specularPaint = Paint()
            ..style = PaintingStyle.fill
            ..shader = LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                    Colors.white.withValues(alpha: 0.65),
                    Colors.white.withValues(alpha: 0.0),
                ],
            ).createShader(Rect.fromCircle(center: center, radius: coreRadius * 0.7));

        final specularRect = Rect.fromCenter(
            center: center.translate(-coreRadius * 0.18, -coreRadius * 0.28),
            width: coreRadius * 0.95,
            height: coreRadius * 0.45,
        );
        canvas.drawOval(specularRect, specularPaint);
    }

    /// Center glyph reflecting current AI state with high optical clarity
    void _drawCenterIconGlyph(Canvas canvas, Offset center, double radius, Color color) {
        final strokePaint = Paint()
            ..color = Colors.white.withValues(alpha: 0.95)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round;

        final fillPaint = Paint()
            ..color = Colors.white.withValues(alpha: 0.95)
            ..style = PaintingStyle.fill;

        switch (state) {
            case AssistantState.listening:
                final micRect = RRect.fromRectAndRadius(
                    Rect.fromCenter(center: center.translate(0, -3), width: 12, height: 22),
                    const Radius.circular(6),
                );
                canvas.drawRRect(micRect, fillPaint);
                final cradleRect = Rect.fromCenter(center: center, width: 24, height: 22);
                canvas.drawArc(cradleRect, 0, math.pi, false, strokePaint);
                canvas.drawLine(center.translate(0, 11), center.translate(0, 18), strokePaint);
                canvas.drawLine(center.translate(-8, 18), center.translate(8, 18), strokePaint);
                break;

            case AssistantState.thinking:
                final angle = vortex * 1.5;
                for (int i = 0; i < 4; i++) {
                    final a = angle + (i * math.pi / 2);
                    final tip = Offset(center.dx + 14 * math.cos(a), center.dy + 14 * math.sin(a));
                    canvas.drawLine(center, tip, strokePaint);
                }
                canvas.drawCircle(center, 3.2, fillPaint);
                break;

            case AssistantState.toolExecution:
                canvas.drawLine(center.translate(-8, -6), center.translate(-2, 0), strokePaint);
                canvas.drawLine(center.translate(-2, 0), center.translate(-8, 6), strokePaint);
                canvas.drawLine(center.translate(1, 6), center.translate(8, 6), strokePaint);
                break;

            case AssistantState.speaking:
                for (int i = 1; i <= 3; i++) {
                    final waveRadius = 7.0 + (i * 6.0) + (amplitude * 6.0);
                    final arcRect = Rect.fromCircle(center: center, radius: waveRadius);
                    canvas.drawArc(arcRect, -math.pi / 3, 2 * math.pi / 3, false, strokePaint);
                    canvas.drawArc(arcRect, 2 * math.pi / 3, 2 * math.pi / 3, false, strokePaint);
                }
                break;

            case AssistantState.interrupted:
                canvas.drawLine(center.translate(-4, -8), center.translate(-4, 8), strokePaint);
                canvas.drawLine(center.translate(4, -8), center.translate(4, 8), strokePaint);
                break;

            case AssistantState.error:
                canvas.drawLine(center.translate(0, -9), center.translate(0, 2), strokePaint);
                canvas.drawCircle(center.translate(0, 8), 2.0, fillPaint);
                break;

            default:
                canvas.drawCircle(center, 4.0 + (pulse * 2.2), fillPaint);
                break;
        }
    }

    @override
    bool shouldRepaint(covariant VolumetricOrbPainter oldDelegate) {
        return oldDelegate.rotation != rotation ||
            oldDelegate.pulse != pulse ||
            oldDelegate.vortex != vortex ||
            oldDelegate.breathing != breathing ||
            oldDelegate.rippleProgress != rippleProgress ||
            oldDelegate.amplitude != amplitude ||
            oldDelegate.state != state ||
            oldDelegate.isHovered != isHovered;
    }
}
