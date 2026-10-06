import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/cup_config.dart';
import '../../models/sugar_particle.dart';
import 'line_segment.dart';

/// Collision, boundary deflection, and collection container for a target cup.
///
/// Implements physical rigid barriers (left wall, floor, right wall) with
/// an open top aperture protected by a Color Selective Membrane (Option A),
/// and a 1D Discrete Column Heightmap with Angle of Repose slope relaxation.
class CupHitbox {
  final Rect bounds;
  final Color color;
  final int targetAmount;
  int capturedCount;
  int lastCaptureMs;

  // Rigid barrier segments for outer collisions
  final LineSegment leftWall;
  final LineSegment floor;
  final LineSegment rightWall;

  // 1D Discrete Column Heightmap (ADR 0003, REQ-006)
  final int binCount;
  final Float64List columnHeights;
  final List<Offset> settledParticleOffsets;

  CupHitbox({
    required this.bounds,
    required this.color,
    this.targetAmount = 100,
    this.capturedCount = 0,
    this.lastCaptureMs = 0,
  })  : leftWall = LineSegment(
          start: Offset(bounds.left, bounds.top),
          end: Offset(bounds.left, bounds.bottom),
          thickness: kCupWallThickness,
        ),
        floor = LineSegment(
          start: Offset(bounds.left, bounds.bottom),
          end: Offset(bounds.right, bounds.bottom),
          thickness: kCupWallThickness,
        ),
        rightWall = LineSegment(
          start: Offset(bounds.right, bounds.bottom),
          end: Offset(bounds.right, bounds.top),
          thickness: kCupWallThickness,
        ),
        binCount = (bounds.width / kHeightmapBinWidth).ceil(),
        columnHeights = Float64List((bounds.width / kHeightmapBinWidth).ceil()),
        settledParticleOffsets = [];

  /// Builds a [CupHitbox] from a normalized [CupConfig] and viewport dimensions.
  factory CupHitbox.fromConfig(
    CupConfig config, {
    double canvasWidth = 1.0,
    double canvasHeight = 1.0,
  }) {
    return CupHitbox(
      bounds: Rect.fromLTWH(
        config.x * canvasWidth,
        config.y * canvasHeight,
        config.width * canvasWidth,
        config.height * canvasHeight,
      ),
      color: config.color,
      targetAmount: config.targetAmount,
    );
  }

  /// Remaining quota required to satisfy the cup.
  int get remaining => (targetAmount - capturedCount).clamp(0, targetAmount);

  /// Indicates if this cup has satisfied its target quota of sugar.
  bool get isFull => capturedCount >= targetAmount;

  /// Determines whether a point (particle coordinates) is inside the cup collection area.
  bool contains(double x, double y) => bounds.contains(Offset(x, y));

  /// Swept continuous check to catch fast particles entering cup across frame boundaries.
  bool intersectsSegment(Offset p1, Offset p2) {
    if (contains(p1.dx, p1.dy) || contains(p2.dx, p2.dy)) return true;

    final double minX = p1.dx < p2.dx ? p1.dx : p2.dx;
    final double maxX = p1.dx > p2.dx ? p1.dx : p2.dx;
    final double minY = p1.dy < p2.dy ? p1.dy : p2.dy;
    final double maxY = p1.dy > p2.dy ? p1.dy : p2.dy;

    if (maxX < bounds.left || minX > bounds.right) return false;
    if (maxY < bounds.top || minY > bounds.bottom) return false;

    return true;
  }

  /// Checks if a [SugarParticle] meets the cup's color acceptance criteria.
  ///
  /// Neutral white particles match any cup.
  /// Colored particles match only cups with the identical color.
  bool matches(SugarParticle particle) {
    if (particle.isNeutral) {
      return true;
    }
    return particle.color.toARGB32() == color.toARGB32();
  }

  /// Resolves outer rigid barrier collisions (left wall, floor, right wall).
  ///
  /// Returns `true` if a collision with outer walls occurred and was deflected.
  bool resolveBarrierCollision(SugarParticle p) {
    if (leftWall.resolveCollision(p)) return true;
    if (rightWall.resolveCollision(p)) return true;
    // Floor barrier only deflects particles hitting the underside of the cup from outside
    if (p.vy < 0 || p.y >= bounds.bottom) {
      if (floor.resolveCollision(p)) return true;
    }
    return false;
  }

  /// Handles particle interaction with the cup aperture and collection zone:
  /// - If non-matching color at top mouth aperture: deflecting off selective membrane (Option A).
  /// - If matching color entering aperture: settling onto heightmap with angle of repose.
  /// - Returns `true` if particle was swallowed/settled, `false` if still active in world.
  bool processParticle(SugarParticle p, {double? prevY}) {
    // 1. Check if particle is within horizontal bounds of cup mouth
    final withinX = p.x >= bounds.left && p.x <= bounds.right;
    final prev = prevY ?? p.y - p.vy;

    // 2. Color Selective Membrane Check (Option A)
    if (!matches(p)) {
      // If approaching or crossing top mouth aperture downwards
      final crossingMouth = (p.y >= bounds.top - 4.0 && p.y <= bounds.top + 8.0) ||
          (prev <= bounds.top && p.y >= bounds.top);
      if (withinX && crossingMouth && p.vy > 0) {
        p.vy = -p.vy.abs() * 0.3;
        p.vx += (p.x < bounds.center.dx ? -0.5 : 0.5);
        p.y = bounds.top - 1.0;
      }
      return false;
    }

    // Particle must be within horizontal span of cup to settle inside
    if (!withinX) return false;

    // 3. Map x to heightmap bin index
    int b = ((p.x - bounds.left) / kHeightmapBinWidth).floor().clamp(0, binCount - 1);
    final currentHeight = columnHeights[b];
    final surfaceY = bounds.bottom - currentHeight;

    // Has the particle reached the surface of the sand mound or floor?
    if (p.y >= surfaceY - 2.0) {
      // 4. Angle of Repose Slope Relaxation (Cascade rolling downhill)
      while (true) {
        final leftDiff = (b > 0) ? columnHeights[b] - columnHeights[b - 1] : -1.0;
        final rightDiff = (b < binCount - 1) ? columnHeights[b] - columnHeights[b + 1] : -1.0;

        if (leftDiff > kReposeSlopeMax || rightDiff > kReposeSlopeMax) {
          if (rightDiff > leftDiff && b < binCount - 1) {
            b++;
          } else if (leftDiff > rightDiff && b > 0) {
            b--;
          } else {
            // Equal steepest slope on both sides
            if (p.vx < 0 && b > 0) {
              b--;
            } else if (p.vx > 0 && b < binCount - 1) {
              b++;
            } else {
              // Alternate symmetrically or prefer lower neighbor
              if (b > 0 && (b == binCount - 1 || columnHeights[b - 1] <= columnHeights[b + 1])) {
                b--;
              } else if (b < binCount - 1) {
                b++;
              } else {
                break;
              }
            }
          }
        } else {
          break;
        }
      }

      // 5. Overflow Spill check: Eject excess particles over cup rim (REQ-007, AC-006)
      if (columnHeights[b] >= bounds.height) {
        columnHeights[b] = bounds.height;
        final ejectLeft = b < binCount / 2;
        p.x = ejectLeft ? bounds.left - 2.0 : bounds.right + 2.0;
        p.y = bounds.top - 1.0;
        p.vx = ejectLeft ? -1.0 : 1.0;
        p.vy = 0.5;
        return false; // Particle remains active in world!
      }

      // 6. Settle Particle onto heightmap
      final grainHeight = kParticleRadius * 1.5;
      columnHeights[b] += grainHeight;
      if (columnHeights[b] > bounds.height) {
        columnHeights[b] = bounds.height;
      }

      final settledX = bounds.left + b * kHeightmapBinWidth + (kHeightmapBinWidth / 2.0);
      final settledY = (bounds.bottom - columnHeights[b]).clamp(bounds.top, bounds.bottom);
      settledParticleOffsets.add(Offset(settledX, settledY));

      capturedCount++;
      lastCaptureMs = DateTime.now().millisecondsSinceEpoch;
      p.isCaptured = true;
      return true;
    }

    return false;
  }

  /// Resets captured count and clears heightmap state.
  void reset() {
    capturedCount = 0;
    lastCaptureMs = 0;
    columnHeights.fillRange(0, columnHeights.length, 0.0);
    settledParticleOffsets.clear();
  }
}
