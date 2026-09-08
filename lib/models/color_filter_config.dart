import 'package:flutter/material.dart';
import '../core/extensions.dart';

/// Configuration for a color filter zone that mutates passing particle colors.
class ColorFilterConfig {
  final double x;
  final double y;
  final double width;
  final double height;
  final Color targetColor;

  const ColorFilterConfig({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.targetColor,
  });

  factory ColorFilterConfig.fromJson(
    Map<String, dynamic> json, {
    double scaleX = 1.0,
    double scaleY = 1.0,
  }) {
    final colorStr = (json['targetColor'] ?? json['color']) as String?;
    return ColorFilterConfig(
      x: (json['x'] as num).toDouble() * scaleX,
      y: (json['y'] as num).toDouble() * scaleY,
      width: (json['width'] as num).toDouble() * scaleX,
      height: (json['height'] as num).toDouble() * scaleY,
      targetColor: colorStr != null
          ? HexColor.fromHex(colorStr)
          : const Color(0xFFFFFFFF),
    );
  }

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'targetColor': targetColor.toHex(leadingHash: true, includeAlpha: false),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorFilterConfig &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          width == other.width &&
          height == other.height &&
          targetColor.toARGB32() == other.targetColor.toARGB32();

  @override
  int get hashCode => Object.hash(
        x,
        y,
        width,
        height,
        targetColor.toARGB32(),
      );

  @override
  String toString() =>
      'ColorFilterConfig(x: $x, y: $y, width: $width, height: $height, targetColor: $targetColor)';
}
