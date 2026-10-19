import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show Canvas, Paint, PaintingStyle, Path, StrokeCap, StrokeJoin;
import '../../core/constants.dart';
import '../../engine/drawing/drawn_line.dart';

/// Renders player-drawn collision barrier paths onto the canvas.
///
/// Direct port of [LinePainter] as a Flame [Component] at priority 30.
class LineDrawingFlameComponent extends Component {
  final List<DrawnLine> Function() linesGetter;

  LineDrawingFlameComponent({required this.linesGetter});

  @override
  int get priority => 30;

  @override
  void render(Canvas canvas) {
    final lines = linesGetter();
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

      // Ethereal outer aura / glow
      canvas.drawPath(
        path,
        Paint()
          ..color = line.color.withValues(alpha: 0.18)
          ..strokeWidth = thickness + 3.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      // Core crisp semi-matte stroke
      canvas.drawPath(
        path,
        Paint()
          ..color = line.color
          ..strokeWidth = thickness
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }
}
