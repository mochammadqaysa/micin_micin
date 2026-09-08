import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../engine/drawing/drawn_line.dart';

/// Renders player-drawn collision barrier paths onto the canvas.
class LinePainter extends CustomPainter {
  final List<DrawnLine> lines;

  LinePainter(this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    if (lines.isEmpty) return;

    for (final line in lines) {
      if (line.points.length < 2) continue;

      final thickness = line.thickness > 0 ? line.thickness : kLineThickness;

      final path = Path();
      for (int i = 0; i < line.points.length; i++) {
        final p = line.points[i];
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }

      // Subtle ethereal outer aura / glow (Zen Art Direction)
      final glowPaint = Paint()
        ..color = line.color.withValues(alpha: 0.18)
        ..strokeWidth = thickness + 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, glowPaint);

      // Core crisp semi-matte stroke barrier
      final corePaint = Paint()
        ..color = line.color
        ..strokeWidth = thickness
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) =>
      !identical(lines, oldDelegate.lines);
}
