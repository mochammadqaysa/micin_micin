import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/emitter_config.dart';
import 'particle_pool.dart';

/// Spawns sugar particles at a fixed rate and location according to level design.
///
/// Operates on frame-based timing (CON-007) matching the original ActionScript logic
/// with organic velocity and position jitter to simulate natural sand dispersion.
class ParticleEmitter {
  final double x;
  final double y;
  final Color color;
  final int totalToEmit;
  final int emitRate;
  final math.Random _random;

  int _frameCounter = 0;
  int _emitted = 0;

  ParticleEmitter({
    required this.x,
    required this.y,
    this.color = const Color(0xFFFFFFFF),
    this.totalToEmit = 100,
    this.emitRate = 3,
    math.Random? random,
  }) : _random = random ?? math.Random();

  /// Factory constructor to build an active emitter from an [EmitterConfig] model.
  factory ParticleEmitter.fromConfig(EmitterConfig config, {math.Random? random}) =>
      ParticleEmitter(
        x: config.x,
        y: config.y,
        color: config.color,
        totalToEmit: config.totalToEmit,
        emitRate: config.rate,
        random: random,
      );

  /// Called per-frame to increment the frame counter and spawn particles when due.
  void tick(ParticlePool pool) {
    if (isExhausted) return;

    _frameCounter++;
    if (_frameCounter % emitRate == 0) {
      final particle = pool.acquire();
      if (particle != null) {
        // Organic position jitter: x ± 1.2 virtual px
        final xJitter = (_random.nextDouble() * 2.4) - 1.2;
        // Organic horizontal velocity jitter: vx in [-0.25, 0.25] virtual px/frame
        final vxJitter = (_random.nextDouble() * 0.5) - 0.25;
        // Crystalline opacity variation: alpha in [0.85, 1.0]
        final opacity = 0.85 + (_random.nextDouble() * 0.15);

        particle.x = x + xJitter;
        particle.y = y;
        particle.vx = vxJitter;
        particle.vy = 0.0;
        particle.color = color;
        particle.opacity = opacity;
        particle.isActive = true;
        particle.isCaptured = false;
        _emitted++;
      }
    }
  }

  /// Resets emission counters back to 0.
  void reset() {
    _frameCounter = 0;
    _emitted = 0;
  }

  /// Indicates whether the emitter has completed its quota of particles.
  bool get isExhausted => _emitted >= totalToEmit;

  /// Current number of particles spawned so far.
  int get emittedCount => _emitted;

  /// Internal frame counter value.
  int get frameCounter => _frameCounter;
}
