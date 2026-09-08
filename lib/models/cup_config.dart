import 'package:flutter/material.dart';
import '../core/extensions.dart';

/// Configuration for a target cup container at a normalized location.
class CupConfig {
  final double x;
  final double y;
  final double width;
  final double height;
  final Color color;
  final int targetAmount;

  const CupConfig({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.color = const Color(0xFFFFFFFF),
    this.targetAmount = 100,
  });

  factory CupConfig.fromJson(
    Map<String, dynamic> json, {
    double scaleX = 1.0,
    double scaleY = 1.0,
  }) {
    return CupConfig(
      x: (json['x'] as num).toDouble() * scaleX,
      y: (json['y'] as num).toDouble() * scaleY,
      width: (json['width'] as num).toDouble() * scaleX,
      height: (json['height'] as num).toDouble() * scaleY,
      color: json['color'] != null
          ? HexColor.fromHex(json['color'] as String)
          : const Color(0xFFFFFFFF),
      targetAmount: (json['targetAmount'] as num?)?.toInt() ?? 100,
    );
  }

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'color': color.toHex(leadingHash: true, includeAlpha: false),
        'targetAmount': targetAmount,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CupConfig &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          width == other.width &&
          height == other.height &&
          color.toARGB32() == other.color.toARGB32() &&
          targetAmount == other.targetAmount;

  @override
  int get hashCode => Object.hash(
        x,
        y,
        width,
        height,
        color.toARGB32(),
        targetAmount,
      );

  @override
  String toString() =>
      'CupConfig(x: $x, y: $y, width: $width, height: $height, color: $color, targetAmount: $targetAmount)';
}
