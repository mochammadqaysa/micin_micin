import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/silhouette_prop_config.dart';
import 'line_segment.dart';

/// Factory generating mathematical [LineSegment] rigid obstacles for procedural silhouette props (REQ-005, DECISION-001).
class SilhouetteColliderFactory {
  /// Generates rigid line segments transformed by origin, scale, and rotation.
  static List<LineSegment> create({
    required SilhouetteType type,
    required Offset origin,
    double scale = 1.0,
    double rotationDegrees = 0.0,
    double thickness = 5.0,
  }) {
    final double rad = rotationDegrees * pi / 180.0;
    final List<List<Offset>> polylineGroups = _getLocalPolylines(type);
    final List<LineSegment> colliders = [];

    for (final polyline in polylineGroups) {
      if (polyline.length < 2) continue;

      for (int i = 0; i < polyline.length - 1; i++) {
        final pStart = _transformPoint(polyline[i], origin, scale, rad);
        final pEnd = _transformPoint(polyline[i + 1], origin, scale, rad);

        colliders.add(
          LineSegment(
            start: pStart,
            end: pEnd,
            thickness: thickness * scale,
          ),
        );
      }
    }

    return colliders;
  }

  /// Transforms a local point by scale, rotation, and translation origin.
  static Offset _transformPoint(Offset local, Offset origin, double scale, double rad) {
    final sx = local.dx * scale;
    final sy = local.dy * scale;
    final rx = sx * cos(rad) - sy * sin(rad);
    final ry = sx * sin(rad) + sy * cos(rad);
    return Offset(origin.dx + rx, origin.dy + ry);
  }

  /// Canonical local coordinate curves for each silhouette prop type.
  static List<List<Offset>> _getLocalPolylines(SilhouetteType type) {
    switch (type) {
      case SilhouetteType.teaspoon:
        return [
          // Teaspoon handle and deflector bowl curve
          const [
            Offset(-120.0, -35.0),
            Offset(-80.0, -20.0),
            Offset(-40.0, -8.0),
            Offset(-15.0, 5.0),
            Offset(10.0, 18.0),
            Offset(40.0, 20.0),
            Offset(70.0, 12.0),
            Offset(95.0, -5.0),
          ],
        ];

      case SilhouetteType.teaspoonDouble:
        return [
          // Upper deflector spoon
          const [
            Offset(-60.0, -40.0),
            Offset(-20.0, -20.0),
            Offset(15.0, -10.0),
            Offset(50.0, -12.0),
            Offset(80.0, -25.0),
          ],
          // Lower deflector spoon
          const [
            Offset(-40.0, 30.0),
            Offset(0.0, 50.0),
            Offset(35.0, 58.0),
            Offset(70.0, 55.0),
            Offset(100.0, 40.0),
          ],
        ];

      case SilhouetteType.handPouring:
        return [
          // Hand wrist to pinched fingers pouring sugar
          const [
            Offset(-90.0, -50.0),
            Offset(-50.0, -30.0),
            Offset(-15.0, -10.0),
            Offset(10.0, 5.0),
            Offset(30.0, 25.0),
            Offset(45.0, 45.0),
          ],
        ];

      case SilhouetteType.handHoldingCup:
        return [
          // Finger cradle holding teacup base
          const [
            Offset(-45.0, 20.0),
            Offset(-20.0, 32.0),
            Offset(15.0, 35.0),
            Offset(45.0, 30.0),
            Offset(65.0, 15.0),
          ],
        ];

      case SilhouetteType.teapotSpout:
        return [
          // Elegant curved teapot neck & pouring lip
          const [
            Offset(-60.0, 40.0),
            Offset(-30.0, 22.0),
            Offset(0.0, 10.0),
            Offset(35.0, 0.0),
            Offset(60.0, -15.0),
          ],
        ];

      case SilhouetteType.hourglassFrame:
        return [
          // Upper funnel slope left
          const [
            Offset(-50.0, -60.0),
            Offset(-20.0, -25.0),
            Offset(-8.0, 0.0),
            Offset(-20.0, 25.0),
            Offset(-50.0, 60.0),
          ],
          // Upper funnel slope right
          const [
            Offset(50.0, -60.0),
            Offset(20.0, -25.0),
            Offset(8.0, 0.0),
            Offset(20.0, 25.0),
            Offset(50.0, 60.0),
          ],
        ];
    }
  }
}
