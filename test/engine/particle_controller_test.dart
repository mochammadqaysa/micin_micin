import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/core/constants.dart';
import 'package:micin_micin/engine/collision/cup_hitbox.dart';
import 'package:micin_micin/engine/collision/line_segment.dart';
import 'package:micin_micin/engine/color_filter/color_filter_zone.dart';
import 'package:micin_micin/engine/particle/particle_controller.dart';
import 'package:micin_micin/engine/particle/particle_emitter.dart';
import 'package:micin_micin/engine/particle/particle_pool.dart';

void main() {
  group('ParticleController', () {
    test('spawns particles from emitter according to emitRate', () {
      final emitter = ParticleEmitter(
        x: 100,
        y: 10,
        emitRate: 2,
        totalToEmit: 10,
      );

      final controller = ParticleController(
        emitters: [emitter],
        gravity: 0.2,
      );

      // Frame 1: frameCounter = 1 (% 2 != 0) -> no spawn
      controller.update(lines: [], cups: [], filters: [], canvasHeight: 500);
      expect(controller.pool.activeParticles.length, equals(0));

      // Frame 2: frameCounter = 2 (% 2 == 0) -> 1 particle spawned
      controller.update(lines: [], cups: [], filters: [], canvasHeight: 500);
      expect(controller.pool.activeParticles.length, equals(1));
    });

    test('strictly enforces velocity clamp at kMaxSpeed = 4.8', () {
      final pool = ParticlePool(capacity: 5);
      final p = pool.acquire()!;
      p.x = 100;
      p.y = 100;
      p.vx = 15.0; // Exceeds clamp
      p.vy = 20.0; // Exceeds clamp

      final controller = ParticleController(
        pool: pool,
        emitters: [],
        gravity: 2.0, // High gravity
      );

      controller.update(lines: [], cups: [], filters: [], canvasHeight: 1000);

      expect(p.vx, equals(kMaxSpeed));
      expect(p.vy, equals(kMaxSpeed));
      expect(p.vx, equals(4.8));
      expect(p.vy, equals(4.8));
    });

    test('free-fall traversal from y = 50 to 650 with g = 0.14 takes between 125 and 145 frames (AC-002)', () {
      final pool = ParticlePool(capacity: 5);
      final p = pool.acquire()!;
      p.x = 200.0;
      p.y = 50.0;
      p.vx = 0.0;
      p.vy = 0.0;

      final controller = ParticleController(
        pool: pool,
        emitters: [],
        gravity: kGravityDefault, // 0.14
      );

      int frames = 0;
      while (p.y < 650.0 && frames < 200) {
        controller.update(lines: [], cups: [], filters: [], canvasHeight: 700);
        frames++;
      }

      expect(frames, greaterThanOrEqualTo(125));
      expect(frames, lessThanOrEqualTo(145));
      expect(p.vy, equals(kMaxSpeed)); // Reached terminal velocity 4.8
    });

    test('10-frame simulation deflects falling particle with line barrier', () {
      final pool = ParticlePool(capacity: 10);
      final particle = pool.acquire()!;
      particle.x = 50.0;
      particle.y = 40.0;
      particle.vx = 0.0;
      particle.vy = 0.0;

      // Diagonal line angled to deflect particle to the right
      const barrier = LineSegment(
        start: Offset(20, 40),
        end: Offset(80, 70),
        thickness: 6.0,
      );

      final controller = ParticleController(
        pool: pool,
        emitters: [],
        gravity: 0.5,
      );

      // Run 10 frames of simulation
      for (int frame = 0; frame < 10; frame++) {
        controller.update(
          lines: [barrier],
          cups: [],
          filters: [],
          canvasHeight: 500,
        );
      }

      // Particle should have collided with the angled barrier and developed positive horizontal velocity
      expect(particle.x, greaterThan(50.0), reason: 'Particle should be deflected rightward');
      expect(particle.isActive, isTrue);
    });

    test('mutates color when particle falls through ColorFilterZone', () {
      final pool = ParticlePool(capacity: 5);
      final p = pool.acquire()!;
      p.x = 50;
      p.y = 50;
      p.color = const Color(0xFFFFFFFF);

      const filter = ColorFilterZone(
        region: Rect.fromLTWH(40, 40, 30, 30),
        targetColor: Color(0xFFFF0000),
      );

      final controller = ParticleController(
        pool: pool,
        emitters: [],
        gravity: 0.1,
      );

      controller.update(lines: [], cups: [], filters: [filter], canvasHeight: 500);

      expect(p.color, equals(const Color(0xFFFF0000)));
    });

    test('captures matching particle when inside CupHitbox', () {
      final pool = ParticlePool(capacity: 5);
      final p = pool.acquire()!;
      p.x = 105;
      p.y = 239;
      p.color = const Color(0xFFFFFFFF);

      final cup = CupHitbox(
        bounds: const Rect.fromLTWH(100, 200, 50, 40),
        color: const Color(0xFFFFFFFF),
        targetAmount: 5,
      );

      final controller = ParticleController(
        pool: pool,
        emitters: [],
        gravity: 0.1,
      );

      controller.update(lines: [], cups: [cup], filters: [], canvasHeight: 500);

      expect(p.isCaptured, isTrue);
      expect(cup.capturedCount, equals(1));
      expect(controller.capturedCount, equals(1));
      expect(controller.pool.activeParticles, isEmpty); // Captured particle not in active list
    });

    test('releases particles that fall below canvas bounds', () {
      final pool = ParticlePool(capacity: 5);
      final p = pool.acquire()!;
      p.x = 50;
      p.y = 400; // Far below canvasHeight = 100

      final controller = ParticleController(
        pool: pool,
        emitters: [],
        gravity: 1.0,
      );

      controller.update(lines: [], cups: [], filters: [], canvasHeight: 100);

      expect(p.isActive, isFalse, reason: 'Particle should be released when falling out of bounds');
    });

    test('resetAll() resets particle pool, emitters, and captured count', () {
      final emitter = ParticleEmitter(x: 0, y: 0, totalToEmit: 5);
      final pool = ParticlePool(capacity: 5);
      final p = pool.acquire()!;
      p.x = 10;
      p.y = 10;

      final controller = ParticleController(
        pool: pool,
        emitters: [emitter],
        gravity: 0.2,
      );
      controller.capturedCount = 3;

      controller.resetAll();

      expect(controller.capturedCount, equals(0));
      expect(controller.pool.activeCount, equals(0));
      expect(emitter.emittedCount, equals(0));
      expect(p.isActive, isFalse);
    });
  });
}
