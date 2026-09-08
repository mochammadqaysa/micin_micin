import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/engine/collision/cup_hitbox.dart';
import 'package:micin_micin/models/cup_config.dart';
import 'package:micin_micin/models/sugar_particle.dart';

void main() {
  group('CupHitbox', () {
    test('contains detects whether coordinates are within bounds', () {
      final cup = CupHitbox(
        bounds: const Rect.fromLTWH(100, 200, 50, 40),
        color: const Color(0xFFFFFFFF),
      );

      expect(cup.contains(125, 220), isTrue);
      expect(cup.contains(50, 50), isFalse);
    });

    test('matches allows neutral white particles to enter any cup', () {
      final redCup = CupHitbox(
        bounds: const Rect.fromLTWH(0, 0, 50, 50),
        color: const Color(0xFFFF0000),
      );

      final whiteParticle = SugarParticle(
        x: 25,
        y: 25,
        color: const Color(0xFFFFFFFF),
      );

      expect(redCup.matches(whiteParticle), isTrue);
    });

    test('matches restricts colored particles to matching cup color', () {
      final blueCup = CupHitbox(
        bounds: const Rect.fromLTWH(0, 0, 50, 50),
        color: const Color(0xFF0000FF),
      );

      final blueParticle = SugarParticle(
        x: 25,
        y: 25,
        color: const Color(0xFF0000FF),
      );

      final yellowParticle = SugarParticle(
        x: 25,
        y: 25,
        color: const Color(0xFFFFFF00),
      );

      expect(blueCup.matches(blueParticle), isTrue);
      expect(blueCup.matches(yellowParticle), isFalse);
    });

    test('tracks captured count, determines full status, and resets', () {
      final cup = CupHitbox(
        bounds: const Rect.fromLTWH(0, 0, 10, 10),
        color: Colors.white,
        targetAmount: 2,
      );

      expect(cup.isFull, isFalse);

      cup.capturedCount++;
      expect(cup.isFull, isFalse);

      cup.capturedCount++;
      expect(cup.isFull, isTrue);

      cup.reset();
      expect(cup.capturedCount, equals(0));
      expect(cup.isFull, isFalse);
    });

    test('fromConfig scales normalized coordinates to viewport dimensions', () {
      const config = CupConfig(
        x: 0.5,
        y: 0.8,
        width: 0.1,
        height: 0.05,
        color: Color(0xFF00FF00),
        targetAmount: 50,
      );

      final hitbox = CupHitbox.fromConfig(
        config,
        canvasWidth: 1000,
        canvasHeight: 2000,
      );

      expect(hitbox.bounds.left, equals(500.0));
      expect(hitbox.bounds.top, equals(1600.0));
      expect(hitbox.bounds.width, equals(100.0));
      expect(hitbox.bounds.height, equals(100.0));
      expect(hitbox.color, equals(const Color(0xFF00FF00)));
      expect(hitbox.targetAmount, equals(50));
    });

    test('fromConfig with native virtual coordinates preserves exact dimensions', () {
      const config = CupConfig(
        x: 160.0,
        y: 600.0,
        width: 80.0,
        height: 70.0,
        color: Color(0xFFFFFFFF),
        targetAmount: 100,
      );

      final hitbox = CupHitbox.fromConfig(config);

      expect(hitbox.bounds.left, equals(160.0));
      expect(hitbox.bounds.top, equals(600.0));
      expect(hitbox.bounds.width, equals(80.0));
      expect(hitbox.bounds.height, equals(70.0));
      expect(hitbox.color, equals(const Color(0xFFFFFFFF)));
      expect(hitbox.targetAmount, equals(100));
    });

    test('intersectsSegment detects fast particle jumping across cup boundary', () {
      final cup = CupHitbox(
        bounds: const Rect.fromLTWH(160, 600, 80, 70),
        color: const Color(0xFFFFFFFF),
      );

      // Particle moving from y=595 to y=605 (crossing top edge at y=600)
      expect(
        cup.intersectsSegment(const Offset(200, 595), const Offset(200, 605)),
        isTrue,
      );

      // Particle moving completely outside cup horizontally
      expect(
        cup.intersectsSegment(const Offset(100, 595), const Offset(100, 605)),
        isFalse,
      );
    });

    test('remaining getter computes countdown quota accurately and clamps at 0 (REQ-005)', () {
      final cup = CupHitbox(
        bounds: const Rect.fromLTWH(100, 200, 40, 50),
        color: const Color(0xFFFF0000),
        targetAmount: 50,
      );

      expect(cup.remaining, equals(50));
      expect(cup.isFull, isFalse);

      cup.capturedCount = 30;
      expect(cup.remaining, equals(20));
      expect(cup.isFull, isFalse);

      cup.capturedCount = 50;
      expect(cup.remaining, equals(0));
      expect(cup.isFull, isTrue);

      cup.capturedCount = 60;
      expect(cup.remaining, equals(0));
      expect(cup.isFull, isTrue);
    });

    test('processParticle deflects non-matching colored particle off top aperture (AC-003, Option A)', () {
      final redCup = CupHitbox(
        bounds: const Rect.fromLTWH(100, 200, 50, 40),
        color: const Color(0xFFFF0000),
      );

      // Blue particle falling towards red cup aperture
      final blueParticle = SugarParticle(
        x: 125,
        y: 198,
        vx: 0.0,
        vy: 3.0,
        color: const Color(0xFF0000FF),
        isActive: true,
      );

      final captured = redCup.processParticle(blueParticle);

      expect(captured, isFalse);
      expect(blueParticle.isCaptured, isFalse);
      expect(redCup.capturedCount, equals(0));
      expect(blueParticle.vy, lessThan(0.0), reason: 'Must be deflected upward');
      expect(blueParticle.vx.abs(), greaterThan(0.0), reason: 'Must have horizontal deflection velocity');
    });

    test('processParticle captures matching particle entering top aperture', () {
      final redCup = CupHitbox(
        bounds: const Rect.fromLTWH(100, 200, 50, 40),
        color: const Color(0xFFFF0000),
      );

      // Red particle reaching cup floor
      final redParticle = SugarParticle(
        x: 125,
        y: 239,
        vx: 0.0,
        vy: 2.0,
        color: const Color(0xFFFF0000),
        isActive: true,
      );

      final captured = redCup.processParticle(redParticle);

      expect(captured, isTrue);
      expect(redParticle.isCaptured, isTrue);
      expect(redCup.capturedCount, equals(1));
      expect(redCup.remaining, equals(99));
    });

    test('resolveBarrierCollision deflects particles hitting outer left wall', () {
      final cup = CupHitbox(
        bounds: const Rect.fromLTWH(100, 200, 50, 40),
        color: const Color(0xFFFFFFFF),
      );

      // Particle moving right towards outer left wall at x = 100
      final p = SugarParticle(
        x: 99.0,
        y: 220.0,
        vx: 3.0,
        vy: 1.0,
        isActive: true,
      );

      final collided = cup.resolveBarrierCollision(p);

      expect(collided, isTrue);
      expect(p.vx, lessThan(0.0), reason: 'Must bounce away to the left');
    });
  });
}
