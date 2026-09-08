import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/sugar_particle.dart';

/// Represents a single geometric segment of a player-drawn barrier line.
///
/// Implements deterministic Euclidean distance checks and velocity reflection
/// for high-speed particle collisions (ADR 0001).
class LineSegment {
  final Offset start;
  final Offset end;
  final double thickness;

  const LineSegment({
    required this.start,
    required this.end,
    this.thickness = kLineThickness,
  });

  /// Computes the shortest distance from scalar coordinates [px, py] to this line segment
  /// without allocating an [Offset] on the heap (PRN-001).
  double distanceToPoint(double px, double py) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final lenSq = dx * dx + dy * dy;

    if (lenSq == 0.0) {
      final diffX = px - start.dx;
      final diffY = py - start.dy;
      return sqrt(diffX * diffX + diffY * diffY);
    }

    double t = ((px - start.dx) * dx + (py - start.dy) * dy) / lenSq;
    t = t.clamp(0.0, 1.0);

    final projX = start.dx + t * dx;
    final projY = start.dy + t * dy;
    final diffX = px - projX;
    final diffY = py - projY;
    return sqrt(diffX * diffX + diffY * diffY);
  }

  /// Computes the shortest distance from an arbitrary point [p] to this line segment.
  double distanceTo(Offset p) => distanceToPoint(p.dx, p.dy);

  /// Calculates the unit normal vector perpendicular to the segment direction.
  Offset get normal {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final len = sqrt(dx * dx + dy * dy);

    if (len == 0.0) return const Offset(0.0, -1.0);

    return Offset(-dy / len, dx / len);
  }

  /// Resolves physical collision with a [SugarParticle].
  ///
  /// Applies positional projection to prevent penetration, normal velocity reflection
  /// ([kLineRestitution]), and tangential surface friction ([kLineFriction]).
  /// Returns `true` if a collision occurred and was resolved.
  bool resolveCollision(SugarParticle p, {double radius = kParticleRadius}) {
    final dist = distanceToPoint(p.x, p.y);
    final threshold = radius + thickness / 2.0;
    if (dist > threshold) {
      return false;
    }

    var n = normal;
    var dot = p.vx * n.dx + p.vy * n.dy;

    // Orient the normal towards the approaching particle so lines reflect
    // particles regardless of drawing direction (left-to-right vs right-to-left)
    if (dot > 0) {
      n = Offset(-n.dx, -n.dy);
      dot = -dot;
    }

    // Positional separation to prevent sinking or penetration through the barrier
    final overlap = threshold - dist;
    if (overlap > 0) {
      p.x += n.dx * overlap;
      p.y += n.dy * overlap;
    }

    // Decompose velocity into normal and tangential components
    final vnX = dot * n.dx;
    final vnY = dot * n.dy;
    final vtX = p.vx - vnX;
    final vtY = p.vy - vnY;

    // Apply normal restitution and tangential surface sliding friction
    p.vx = vtX * kLineFriction - vnX * kLineRestitution;
    p.vy = vtY * kLineFriction - vnY * kLineRestitution;

    return true;
  }

  @override
  String toString() =>
      'LineSegment(start: $start, end: $end, thickness: $thickness)';
}
