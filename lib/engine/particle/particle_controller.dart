import '../../core/constants.dart';
import '../collision/cup_hitbox.dart';
import '../collision/line_segment.dart';
import '../color_filter/color_filter_zone.dart';
import '../../models/sugar_particle.dart';
import 'particle_emitter.dart';
import 'particle_pool.dart';

/// Central physics controller orchestrating particle lifecycle, kinematics,
/// gravity acceleration, color transitions, collisions, and collection.
class ParticleController {
  final ParticlePool pool;
  final List<ParticleEmitter> emitters;
  double gravity;
  int capturedCount;
  bool isSpawningActive;

  ParticleController({
    ParticlePool? pool,
    required this.emitters,
    this.gravity = kGravityDefault,
    this.capturedCount = 0,
    this.isSpawningActive = true,
  }) : pool = pool ?? ParticlePool();

  /// Updates physics simulation for one frame step.
  void update({
    required List<LineSegment> lines,
    List<LineSegment> obstacles = const [],
    required List<CupHitbox> cups,
    required List<ColorFilterZone> filters,
    required double canvasHeight,
    void Function(CupHitbox cup, SugarParticle particle)? onParticleCaptured,
    void Function(ColorFilterZone filter, SugarParticle particle)? onFilterPassed,
  }) {
    // 1. Tick all emitters to spawn new particles if scheduled and spawning is active
    if (isSpawningActive) {
      for (final emitter in emitters) {
        emitter.tick(pool);
      }
    }

    // Determine out-of-bounds safety buffer depending on coordinate space
    final double boundBuffer = canvasHeight <= 2.0 ? 0.1 : 50.0;
    final double minHorizontal = -boundBuffer;
    final double maxHorizontal = canvasHeight <= 2.0 ? 1.0 + boundBuffer : kVirtualWidth + boundBuffer;
    final double minVertical = -boundBuffer;
    final double maxVertical = canvasHeight + boundBuffer;

    // 2. Iterate over all active, uncaptured particles
    for (final p in pool.activeParticles) {
      // (a) Apply gravity
      p.vy += gravity;

      // (b) Anti-tunneling velocity clamp (REQ-011)
      p.vx = p.vx.clamp(-kMaxSpeed, kMaxSpeed);
      p.vy = p.vy.clamp(-kMaxSpeed, kMaxSpeed);

      // (c) Apply color filter mutations with swept continuous test
      for (final filter in filters) {
        final nextX = p.x + p.vx;
        final nextY = p.y + p.vy;
        if (filter.intersectsCoords(p.x, p.y, nextX, nextY)) {
          if (p.color != filter.targetColor) {
            p.color = filter.targetColor;
            onFilterPassed?.call(filter, p);
          }
        }
      }

      // (d1) Resolve collisions against rigid static obstacles (REQ-005, AC-005)
      for (final obstacle in obstacles) {
        if (obstacle.resolveCollision(p)) {
          break;
        }
      }

      // (d2) Resolve collisions against player-drawn line segments
      for (final segment in lines) {
        if (segment.resolveCollision(p)) {
          break;
        }
      }

      // (e) Integrate positions
      final prevY = p.y;
      p.x += p.vx;
      p.y += p.vy;

      // (f) Check target cup capture & selective membrane deflection
      for (final cup in cups) {
        if (cup.processParticle(p, prevY: prevY)) {
          capturedCount++;
          onParticleCaptured?.call(cup, p);
          break;
        } else {
          cup.resolveBarrierCollision(p);
        }
      }

      // (g) Release uncaptured particles that fall out of bounds
      if (!p.isCaptured &&
          (p.y > maxVertical ||
           p.y < minVertical ||
           p.x < minHorizontal ||
           p.x > maxHorizontal)) {
        pool.release(p);
      }
    }
  }

  /// Resets all particles and emitters back to their initial state (REQ-012).
  void resetAll() {
    pool.releaseAll();
    for (final emitter in emitters) {
      emitter.reset();
    }
    capturedCount = 0;
  }
}
