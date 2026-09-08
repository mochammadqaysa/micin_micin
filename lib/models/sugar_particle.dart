import 'package:flutter/material.dart';

/// Represents a single physics particle of sugar / micin.
///
/// Designed for high-frequency updates and reuse within [ParticlePool]
/// to eliminate garbage collection pressure during the 60fps game loop.
class SugarParticle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double opacity;
  bool isActive;
  bool isCaptured;

  SugarParticle({
    required this.x,
    required this.y,
    this.vx = 0.0,
    this.vy = 0.0,
    this.color = const Color(0xFFFFFFFF),
    this.opacity = 1.0,
    this.isActive = false,
    this.isCaptured = false,
  });

  /// Resets particle physics and lifecycle states back to default pool condition.
  void reset() {
    isActive = false;
    isCaptured = false;
    vx = 0.0;
    vy = 0.0;
    color = const Color(0xFFFFFFFF);
    opacity = 1.0;
  }

  /// Returns `true` if particle is the default neutral white sugar color.
  bool get isNeutral => color.toARGB32() == 0xFFFFFFFF;

  @override
  String toString() =>
      'SugarParticle(x: $x, y: $y, vx: $vx, vy: $vy, color: $color, opacity: $opacity, isActive: $isActive, isCaptured: $isCaptured)';
}
