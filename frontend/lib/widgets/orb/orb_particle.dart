import 'dart:math' as math;

/// Single particle node within the 3D-depth volumetric constellation.
class OrbParticle {
    final int ring;
    final double baseRadiusFraction;
    final double angle;
    final double speed;
    final double size;
    final double pulseOffset;
    final double depthPhase;

    const OrbParticle({
        required this.ring,
        required this.baseRadiusFraction,
        required this.angle,
        required this.speed,
        required this.size,
        required this.pulseOffset,
        required this.depthPhase,
    });

    /// Generates a reproducible list of particles with 4 concentric orbital bands.
    static List<OrbParticle> generate(int count, {int seed = 1337}) {
        final rand = math.Random(seed);
        return List.generate(count, (i) {
            final ring = i % 4; // 4 concentric orbital bands
            final baseRadius = 0.28 + (ring * 0.16) + (rand.nextDouble() * 0.10);
            final speed = (ring % 2 == 0 ? 1.0 : -1.0) * (0.35 + rand.nextDouble() * 0.75);
            final initialAngle = rand.nextDouble() * 2 * math.pi;
            final dotSize = 1.6 + rand.nextDouble() * 2.8;
            final pulseOffset = rand.nextDouble() * 2 * math.pi;
            final depthPhase = rand.nextDouble() * 2 * math.pi;

            return OrbParticle(
                ring: ring,
                baseRadiusFraction: baseRadius,
                angle: initialAngle,
                speed: speed,
                size: dotSize,
                pulseOffset: pulseOffset,
                depthPhase: depthPhase,
            );
        });
    }
}
