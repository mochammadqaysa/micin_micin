import 'dart:math' show pi;
import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show Canvas, Paint, PaintingStyle, Path;
import '../../models/silhouette_prop_config.dart';

/// Renders procedural vector silhouettes onto the canvas plane behind particles.
///
/// Direct port of [SilhouettePainter] as a Flame [Component].
/// Operates in virtual 400×700 coordinate space.
class SilhouetteFlameComponent extends Component {
  final List<SilhouettePropConfig> props;

  SilhouetteFlameComponent({required this.props});

  @override
  int get priority => 0;

  @override
  void render(Canvas canvas) {
    if (props.isEmpty) return;

    for (final prop in props) {
      canvas.save();
      canvas.translate(prop.origin.dx, prop.origin.dy);
      if (prop.rotationDegrees != 0.0) {
        canvas.rotate(prop.rotationDegrees * pi / 180.0);
      }
      if (prop.scale != 1.0) {
        canvas.scale(prop.scale);
      }

      final fillPaint = Paint()
        ..color = prop.shadowColor
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;

      canvas.drawPath(_generatePath(prop.type), fillPaint);
      canvas.restore();
    }
  }

  static Path _generatePath(SilhouetteType type) {
    final path = Path();
    switch (type) {
      case SilhouetteType.teaspoon:
        path.moveTo(-130.0, -42.0);
        path.quadraticBezierTo(-135.0, -48.0, -125.0, -46.0);
        path.lineTo(-40.0, -12.0);
        path.quadraticBezierTo(-15.0, 0.0, -5.0, 6.0);
        path.quadraticBezierTo(20.0, 22.0, 45.0, 24.0);
        path.quadraticBezierTo(75.0, 22.0, 95.0, -5.0);
        path.quadraticBezierTo(80.0, 10.0, 45.0, 14.0);
        path.quadraticBezierTo(15.0, 12.0, -5.0, 2.0);
        path.lineTo(-120.0, -38.0);
        path.close();

      case SilhouetteType.teaspoonDouble:
        path.moveTo(-70.0, -48.0);
        path.lineTo(-20.0, -22.0);
        path.quadraticBezierTo(15.0, -8.0, 50.0, -10.0);
        path.quadraticBezierTo(70.0, -16.0, 80.0, -25.0);
        path.quadraticBezierTo(50.0, -2.0, 15.0, -2.0);
        path.lineTo(-65.0, -42.0);
        path.close();
        path.moveTo(-50.0, 22.0);
        path.lineTo(0.0, 45.0);
        path.quadraticBezierTo(35.0, 62.0, 70.0, 58.0);
        path.quadraticBezierTo(90.0, 50.0, 100.0, 40.0);
        path.quadraticBezierTo(70.0, 68.0, 35.0, 68.0);
        path.lineTo(-45.0, 28.0);
        path.close();

      case SilhouetteType.handPouring:
        path.moveTo(-100.0, -60.0);
        path.lineTo(-60.0, -35.0);
        path.quadraticBezierTo(-20.0, -15.0, 0.0, -2.0);
        path.quadraticBezierTo(25.0, 10.0, 45.0, 45.0);
        path.quadraticBezierTo(35.0, 25.0, 15.0, 18.0);
        path.quadraticBezierTo(-10.0, 12.0, -40.0, -5.0);
        path.lineTo(-90.0, -45.0);
        path.close();

      case SilhouetteType.handHoldingCup:
        path.moveTo(-55.0, 10.0);
        path.quadraticBezierTo(-25.0, 35.0, 15.0, 38.0);
        path.quadraticBezierTo(45.0, 32.0, 65.0, 15.0);
        path.quadraticBezierTo(50.0, 42.0, 15.0, 45.0);
        path.quadraticBezierTo(-25.0, 42.0, -50.0, 20.0);
        path.close();

      case SilhouetteType.teapotSpout:
        path.moveTo(-70.0, 50.0);
        path.quadraticBezierTo(-30.0, 25.0, 0.0, 12.0);
        path.quadraticBezierTo(35.0, 2.0, 60.0, -15.0);
        path.lineTo(65.0, -8.0);
        path.quadraticBezierTo(35.0, 12.0, 0.0, 22.0);
        path.quadraticBezierTo(-30.0, 38.0, -60.0, 60.0);
        path.close();

      case SilhouetteType.hourglassFrame:
        path.moveTo(-50.0, -60.0);
        path.lineTo(50.0, -60.0);
        path.lineTo(40.0, -50.0);
        path.lineTo(-40.0, -50.0);
        path.close();
        path.moveTo(-15.0, -50.0);
        path.quadraticBezierTo(-6.0, 0.0, -15.0, 50.0);
        path.lineTo(-20.0, 50.0);
        path.quadraticBezierTo(-10.0, 0.0, -20.0, -50.0);
        path.close();
        path.moveTo(15.0, -50.0);
        path.quadraticBezierTo(6.0, 0.0, 15.0, 50.0);
        path.lineTo(20.0, 50.0);
        path.quadraticBezierTo(10.0, 0.0, 20.0, -50.0);
        path.close();
        path.moveTo(-50.0, 60.0);
        path.lineTo(50.0, 60.0);
        path.lineTo(40.0, 50.0);
        path.lineTo(-40.0, 50.0);
        path.close();
    }
    return path;
  }
}
