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

  /// Determines whether a particle's position falls within this color zone.
  bool contains(double x, double y) => region.contains(Offset(x, y));

  /// Continuous swept collision check to prevent discrete velocity tunneling through thin filter zones.
  bool intersectsSegment(Offset p1, Offset p2) {
    if (contains(p1.dx, p1.dy) || contains(p2.dx, p2.dy)) return true;

    final double minX = p1.dx < p2.dx ? p1.dx : p2.dx;
    final double maxX = p1.dx > p2.dx ? p1.dx : p2.dx;
    final double minY = p1.dy < p2.dy ? p1.dy : p2.dy;
    final double maxY = p1.dy > p2.dy ? p1.dy : p2.dy;

    // Reject if bounding boxes do not overlap
    if (maxX < region.left || minX > region.right) return false;
    if (maxY < region.top || minY > region.bottom) return false;

    return true;
  }

  /// Mutates the particle's color if it passes through this zone.
  void apply(SugarParticle particle) {
    if (contains(particle.x, particle.y)) {
      particle.color = targetColor;
    }
  }
}
