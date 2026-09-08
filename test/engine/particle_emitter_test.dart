import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/engine/particle/particle_emitter.dart';
import 'package:micin_micin/engine/particle/particle_pool.dart';
import 'package:micin_micin/models/emitter_config.dart';

void main() {
  group('ParticleEmitter', () {
    test('spawns particles with organic position jitter within x ± 1.2 virtual px (REQ-003)', () {
      final pool = ParticlePool(capacity: 50);
      final emitter = ParticleEmitter(
        x: 200.0,
        y: 50.0,
        emitRate: 1,
        totalToEmit: 30,
      );

      for (int i = 0; i < 30; i++) {
        emitter.tick(pool);
      }

      expect(pool.activeParticles.length, equals(30));
      for (final p in pool.activeParticles) {
        expect(p.x, greaterThanOrEqualTo(200.0 - 1.2));
        expect(p.x, lessThanOrEqualTo(200.0 + 1.2));
        expect(p.y, equals(50.0));
      }
    });

    test('spawns particles with horizontal velocity jitter vx in [-0.25, 0.25] (REQ-003)', () {
      final pool = ParticlePool(capacity: 50);
      final emitter = ParticleEmitter(
        x: 100.0,
        y: 40.0,
        emitRate: 1,
        totalToEmit: 30,
      );

      for (int i = 0; i < 30; i++) {
        emitter.tick(pool);
      }

      for (final p in pool.activeParticles) {
        expect(p.vx, greaterThanOrEqualTo(-0.25));
        expect(p.vx, lessThanOrEqualTo(0.25));
        expect(p.vy, equals(0.0));
      }
    });

    test('spawns particles with crystalline opacity alpha in [0.85, 1.0] (REQ-001, AC-001)', () {
      final pool = ParticlePool(capacity: 50);
      final emitter = ParticleEmitter(
        x: 150.0,
        y: 80.0,
        emitRate: 1,
        totalToEmit: 30,
      );

      for (int i = 0; i < 30; i++) {
        emitter.tick(pool);
      }

      for (final p in pool.activeParticles) {
        expect(p.opacity, greaterThanOrEqualTo(0.85));
        expect(p.opacity, lessThanOrEqualTo(1.0));
      }
    });

    test('constructs from EmitterConfig accurately', () {
      const config = EmitterConfig(
        x: 120.0,
        y: 30.0,
        rate: 2,
        totalToEmit: 15,
        color: Color(0xFFFF0000),
      );

      final emitter = ParticleEmitter.fromConfig(config);

      expect(emitter.x, equals(120.0));
      expect(emitter.y, equals(30.0));
      expect(emitter.emitRate, equals(2));
      expect(emitter.totalToEmit, equals(15));
      expect(emitter.color, equals(const Color(0xFFFF0000)));
    });

    test('reset() clears frameCounter and emittedCount', () {
      final pool = ParticlePool(capacity: 10);
      final emitter = ParticleEmitter(
        x: 50.0,
        y: 50.0,
        emitRate: 1,
        totalToEmit: 5,
      );

      emitter.tick(pool);
      emitter.tick(pool);
      expect(emitter.emittedCount, equals(2));
      expect(emitter.frameCounter, equals(2));

      emitter.reset();
      expect(emitter.emittedCount, equals(0));
      expect(emitter.frameCounter, equals(0));
      expect(emitter.isExhausted, isFalse);
    });
  });
}
