import 'package:flutter/material.dart';
import '../engine/collision/line_segment.dart';
import '../engine/collision/silhouette_collider_factory.dart';

/// Supported types of procedural vector silhouette props (GDD Section 4, REQ-005).
enum SilhouetteType {
  teaspoon,
  teaspoonDouble,
  handPouring,
  handHoldingCup,
  teapotSpout,
  hourglassFrame,
}

/// Geometric configuration for procedural silhouette props and their colliders.
class SilhouettePropConfig {
  final SilhouetteType type;
  final Offset origin;
  final double rotationDegrees;
  final double scale;
  final Color shadowColor;

  const SilhouettePropConfig({
    required this.type,
    required this.origin,
    this.rotationDegrees = 0.0,
    this.scale = 1.0,
    this.shadowColor = const Color(0xD905070B), // 85% solid obsidian
  });

  /// Generates the line segment colliders to register into the physics engine (DECISION-001).
  List<LineSegment> generateColliders() {
    return SilhouetteColliderFactory.create(
      type: type,
      origin: origin,
      scale: scale,
      rotationDegrees: rotationDegrees,
    );
  }
}
