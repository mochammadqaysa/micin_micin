import 'package:flutter/material.dart';
import '../../models/color_filter_config.dart';
import '../../models/sugar_particle.dart';

/// Represents a filter gate zone that mutates the color of passing particles.
class ColorFilterZone {
  final Rect region;
  final Color targetColor;

  const ColorFilterZone({
    required this.region,
    required this.targetColor,
  });

  /// Factory to construct a filter zone from a normalized [ColorFilterConfig].
  factory ColorFilterZone.fromConfig(
    ColorFilterConfig config, {
    double canvasWidth = 1.0,
    double canvasHeight = 1.0,
  }) {
    return ColorFilterZone(
      region: Rect.fromLTWH(
        config.x * canvasWidth,
        config.y * canvasHeight,
        config.width * canvasWidth,
        config.height * canvasHeight,
      ),
      targetColor: config.targetColor,
    );
  }

  /// Determines whether a particle's position falls within this color zone without heap allocation.
  bool contains(double x, double y) =>
      x >= region.left && x <= region.right && y >= region.top && y <= region.bottom;

  /// Continuous swept collision check using raw scalar coordinates to prevent heap allocation.
  bool intersectsCoords(double x1, double y1, double x2, double y2) {
    if (contains(x1, y1) || contains(x2, y2)) return true;

    final double minX = x1 < x2 ? x1 : x2;
    final double maxX = x1 > x2 ? x1 : x2;
    final double minY = y1 < y2 ? y1 : y2;
    final double maxY = y1 > y2 ? y1 : y2;

    // Reject if bounding boxes do not overlap
    if (maxX < region.left || minX > region.right) return false;
    if (maxY < region.top || minY > region.bottom) return false;

    return true;
  }

  /// Continuous swept collision check to prevent discrete velocity tunneling through thin filter zones.
  bool intersectsSegment(Offset p1, Offset p2) =>
      intersectsCoords(p1.dx, p1.dy, p2.dx, p2.dy);

  /// Mutates the particle's color if it passes through this zone.
  void apply(SugarParticle particle) {
    if (contains(particle.x, particle.y)) {
      particle.color = targetColor;
    }
  }
}
