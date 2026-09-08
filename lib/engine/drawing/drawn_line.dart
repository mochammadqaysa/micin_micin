import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../collision/line_segment.dart';

/// Represents a continuous line stroke drawn by the player on the game canvas.
class DrawnLine {
  final List<Offset> points;
  final Color color;
  final double thickness;

  const DrawnLine({
    required this.points,
    this.color = const Color(0xFFFFFFFF),
    this.thickness = kLineThickness,
  });

  /// Decomposes this continuous line path into individual [LineSegment]s for collision testing.
  List<LineSegment> toSegments() {
    if (points.length < 2) return const [];

    final segments = <LineSegment>[];
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      // Skip degenerate segments with zero or sub-pixel length
      final dx = p2.dx - p1.dx;
      final dy = p2.dy - p1.dy;
      if (dx * dx + dy * dy < 0.25) continue;

      segments.add(
        LineSegment(
          start: p1,
          end: p2,
          thickness: thickness,
        ),
      );
    }
    return segments;
  }
}
