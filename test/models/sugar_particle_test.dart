import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/models/sugar_particle.dart';

void main() {
  group('SugarParticle', () {
    test('initializes with expected default values', () {
      final particle = SugarParticle(x: 10.0, y: 20.0);

      expect(particle.x, equals(10.0));
      expect(particle.y, equals(20.0));
      expect(particle.vx, equals(0.0));
      expect(particle.vy, equals(0.0));
      expect(particle.color, equals(const Color(0xFFFFFFFF)));
      expect(particle.opacity, equals(1.0));
      expect(particle.isActive, isFalse);
      expect(particle.isCaptured, isFalse);
    });

    test('initializes with custom parameters', () {
      final particle = SugarParticle(
        x: 15.5,
        y: 25.5,
        vx: 2.0,
        vy: -3.0,
        color: const Color(0xFFFF0000),
        opacity: 0.92,
        isActive: true,
        isCaptured: false,
      );

      expect(particle.x, equals(15.5));
      expect(particle.y, equals(25.5));
      expect(particle.vx, equals(2.0));
      expect(particle.vy, equals(-3.0));
      expect(particle.color, equals(const Color(0xFFFF0000)));
      expect(particle.opacity, equals(0.92));
      expect(particle.isActive, isTrue);
      expect(particle.isCaptured, isFalse);
    });

    test('reset() restores velocities, colors, and lifecycle flags to default pool state', () {
      final particle = SugarParticle(
        x: 100.0,
        y: 200.0,
        vx: 5.0,
        vy: 4.5,
        color: const Color(0xFF00FF00),
        opacity: 0.88,
        isActive: true,
        isCaptured: true,
      );

      particle.reset();

      expect(particle.isActive, isFalse);
      expect(particle.isCaptured, isFalse);
      expect(particle.vx, equals(0.0));
      expect(particle.vy, equals(0.0));
      expect(particle.color, equals(const Color(0xFFFFFFFF)));
      expect(particle.opacity, equals(1.0));
      // Note: coordinates x and y are left for next acquisition to overwrite
      expect(particle.x, equals(100.0));
      expect(particle.y, equals(200.0));
    });

    test('isNeutral returns true for white particles and false for dyed particles', () {
      final whiteParticle = SugarParticle(x: 0, y: 0, color: const Color(0xFFFFFFFF));
      final redParticle = SugarParticle(x: 0, y: 0, color: const Color(0xFFFF0000));

      expect(whiteParticle.isNeutral, isTrue);
      expect(redParticle.isNeutral, isFalse);
    });

    test('toString() produces informative output', () {
      final particle = SugarParticle(x: 1.0, y: 2.0);
      expect(particle.toString(), contains('SugarParticle'));
      expect(particle.toString(), contains('x: 1.0'));
      expect(particle.toString(), contains('y: 2.0'));
    });
  });
}
