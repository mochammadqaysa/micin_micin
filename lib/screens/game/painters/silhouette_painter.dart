import 'dart:math';
import 'package:flutter/material.dart';
import '../../../models/silhouette_prop_config.dart';

/// Renders procedural vector silhouettes directly onto the canvas plane behind particles (REQ-005, DECISION-002).
class SilhouettePainter extends CustomPainter {
  final List<SilhouettePropConfig> props;

  const SilhouettePainter(this.props);

  @override
  void paint(Canvas canvas, Size size) {
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

      final path = _generatePath(prop.type);
      canvas.drawPath(path, fillPaint);

      canvas.restore();
    }
  }

  /// Procedural vector path generation for each silhouette prop type.
  static Path _generatePath(SilhouetteType type) {
    final path = Path();

    switch (type) {
      case SilhouetteType.teaspoon:
        // 1. Long slender handle
        path.moveTo(-130.0, -42.0);
        path.quadraticBezierTo(-135.0, -48.0, -125.0, -46.0);
        path.lineTo(-40.0, -12.0);
        path.quadraticBezierTo(-15.0, 0.0, -5.0, 6.0);

        // 2. Teaspoon deflector bowl (outer lower rim)
        path.quadraticBezierTo(20.0, 22.0, 45.0, 24.0);
        path.quadraticBezierTo(75.0, 22.0, 95.0, -5.0);

        // 3. Teaspoon bowl inner concave rim
        path.quadraticBezierTo(80.0, 10.0, 45.0, 14.0);
        path.quadraticBezierTo(15.0, 12.0, -5.0, 2.0);

        // 4. Return to handle
        path.lineTo(-120.0, -38.0);
        path.close();
        break;

      case SilhouetteType.teaspoonDouble:
        // Upper deflector spoon
        path.moveTo(-70.0, -48.0);
        path.lineTo(-20.0, -22.0);
        path.quadraticBezierTo(15.0, -8.0, 50.0, -10.0);
        path.quadraticBezierTo(70.0, -16.0, 80.0, -25.0);
        path.quadraticBezierTo(50.0, -2.0, 15.0, -2.0);
        path.lineTo(-65.0, -42.0);
        path.close();

        // Lower deflector spoon
        path.moveTo(-50.0, 22.0);
        path.lineTo(0.0, 45.0);
        path.quadraticBezierTo(35.0, 62.0, 70.0, 58.0);
        path.quadraticBezierTo(90.0, 50.0, 100.0, 40.0);
        path.quadraticBezierTo(70.0, 68.0, 35.0, 68.0);
        path.lineTo(-45.0, 28.0);
        path.close();
        break;

      case SilhouetteType.handPouring:
        // Expressive silhouette arm & pinched pouring fingers
        path.moveTo(-100.0, -60.0);
        path.lineTo(-60.0, -35.0);
        path.quadraticBezierTo(-20.0, -15.0, 0.0, -2.0);
        path.quadraticBezierTo(25.0, 10.0, 45.0, 45.0); // Index fingertip
        path.quadraticBezierTo(35.0, 25.0, 15.0, 18.0); // Thumb
        path.quadraticBezierTo(-10.0, 12.0, -40.0, -5.0);
        path.lineTo(-90.0, -45.0);
        path.close();
        break;

      case SilhouetteType.handHoldingCup:
        // Gentle fingers holding teacup base
        path.moveTo(-55.0, 10.0);
        path.quadraticBezierTo(-25.0, 35.0, 15.0, 38.0);
        path.quadraticBezierTo(45.0, 32.0, 65.0, 15.0);
        path.quadraticBezierTo(50.0, 42.0, 15.0, 45.0);
        path.quadraticBezierTo(-25.0, 42.0, -50.0, 20.0);
        path.close();
        break;

      case SilhouetteType.teapotSpout:
        // Elegant curved teapot spout neck
        path.moveTo(-70.0, 50.0);
        path.quadraticBezierTo(-30.0, 25.0, 0.0, 12.0);
        path.quadraticBezierTo(35.0, 2.0, 60.0, -15.0);
        path.lineTo(65.0, -8.0);
        path.quadraticBezierTo(35.0, 12.0, 0.0, 22.0);
        path.quadraticBezierTo(-30.0, 38.0, -60.0, 60.0);
        path.close();
        break;

      case SilhouetteType.hourglassFrame:
        // Upper funnel housing & constriction waist
        path.moveTo(-50.0, -60.0);
        path.lineTo(50.0, -60.0);
        path.lineTo(40.0, -50.0);
        path.lineTo(-40.0, -50.0);
        path.close();

        // Waist columns
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

        // Bottom plate
        path.moveTo(-50.0, 60.0);
        path.lineTo(50.0, 60.0);
        path.lineTo(40.0, 50.0);
        path.lineTo(-40.0, 50.0);
        path.close();
        break;
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant SilhouettePainter oldDelegate) =>
      oldDelegate.props != props;
}
