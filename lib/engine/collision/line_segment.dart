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
  /// Features continuous collision detection (CCD):
  /// - Evaluates current distance, predicted frame distance, and swept line intersection.
  /// - Applies positional separation to prevent penetration.
  /// - Reflects normal velocity with [kLineRestitution] and tangential friction [kLineFriction].
  /// Returns `true` if a collision occurred and was resolved.
  bool resolveCollision(SugarParticle p, {double radius = kParticleRadius}) {
    final dist = distanceToPoint(p.x, p.y);
    final threshold = radius + thickness / 2.0;

    bool hit = dist <= threshold;
    if (!hit && (p.vx != 0.0 || p.vy != 0.0)) {
      final nextDist = distanceToPoint(p.x + p.vx, p.y + p.vy);
      if (nextDist <= threshold) {
        hit = true;
      } else {
        hit = _sweptIntersects(p.x, p.y, p.x + p.vx, p.y + p.vy);
      }
    }

    if (!hit) {
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

  /// Evaluates whether the swept path between (x1, y1) and (x2, y2)
  /// intersects this line segment.
  bool _sweptIntersects(double x1, double y1, double x2, double y2) {
    final x3 = start.dx;
    final y3 = start.dy;
    final x4 = end.dx;
    final y4 = end.dy;

    final denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    if (denom.abs() < 1e-6) return false;

    final t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denom;
    final u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / denom;

    return t >= 0.0 && t <= 1.0 && u >= 0.0 && u <= 1.0;
  }

  @override
  String toString() =>
      'LineSegment(start: $start, end: $end, thickness: $thickness)';
}
