import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/extensions.dart';
import '../engine/collision/line_segment.dart';

/// Configuration for a static obstacle beam (`balk`) barrier deflecting sugar grains.
class ObstacleConfig {
  final double x;
  final double y;
  final double width;
  final double height;
  final double rotation; // in radians
  final Color? color;

  const ObstacleConfig({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.rotation = 0.0,
    this.color,
  });

  /// Converts this rectangular obstacle into rigid [LineSegment] colliders.
  List<LineSegment> toLineSegments({double thickness = 3.0}) {
    if (width <= 0 || height <= 0) return const [];

    final cx = x + width / 2.0;
    final cy = y + height / 2.0;
    final hw = width / 2.0;
    final hh = height / 2.0;

    Offset rotatePoint(double dx, double dy) {
      if (rotation == 0.0) {
        return Offset(cx + dx, cy + dy);
      }
      final cosR = math.cos(rotation);
      final sinR = math.sin(rotation);
      return Offset(
        cx + dx * cosR - dy * sinR,
        cy + dx * sinR + dy * cosR,
      );
    }

    final pTopLeft = rotatePoint(-hw, -hh);
    final pTopRight = rotatePoint(hw, -hh);
    final pBottomRight = rotatePoint(hw, hh);
    final pBottomLeft = rotatePoint(-hw, hh);

    return [
      LineSegment(start: pTopLeft, end: pTopRight, thickness: thickness),
      LineSegment(start: pTopRight, end: pBottomRight, thickness: thickness),
      LineSegment(start: pBottomRight, end: pBottomLeft, thickness: thickness),
      LineSegment(start: pBottomLeft, end: pTopLeft, thickness: thickness),
    ];
  }

  factory ObstacleConfig.fromJson(
    Map<String, dynamic> json, {
    double scaleX = 1.0,
    double scaleY = 1.0,
  }) {
    return ObstacleConfig(
      x: (json['x'] as num).toDouble() * scaleX,
      y: (json['y'] as num).toDouble() * scaleY,
      width: (json['width'] as num).toDouble() * scaleX,
      height: (json['height'] as num).toDouble() * scaleY,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      color: json['color'] != null
          ? HexColor.fromHex(json['color'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'rotation': rotation,
        if (color != null)
          'color': color!.toHex(leadingHash: true, includeAlpha: false),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObstacleConfig &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          width == other.width &&
          height == other.height &&
          rotation == other.rotation &&
          color == other.color;

  @override
  int get hashCode => Object.hash(x, y, width, height, rotation, color);
}

