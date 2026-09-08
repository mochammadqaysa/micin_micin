import 'package:flutter/material.dart';
import '../core/extensions.dart';

/// Configuration for a particle emitter at a normalized location.
class EmitterConfig {
  final double x;
  final double y;
  final int rate;
  final Color color;
  final int totalToEmit;

  const EmitterConfig({
    required this.x,
    required this.y,
    this.rate = 3,
    this.color = const Color(0xFFFFFFFF),
    this.totalToEmit = 100,
  });

  factory EmitterConfig.fromJson(
    Map<String, dynamic> json, {
    double scaleX = 1.0,
    double scaleY = 1.0,
  }) {
    return EmitterConfig(
      x: (json['x'] as num).toDouble() * scaleX,
      y: (json['y'] as num).toDouble() * scaleY,
      rate: (json['rate'] as num?)?.toInt() ?? 3,
      color: json['color'] != null
          ? HexColor.fromHex(json['color'] as String)
          : const Color(0xFFFFFFFF),
      totalToEmit: (json['totalToEmit'] as num?)?.toInt() ?? 100,
    );
  }

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'rate': rate,
        'color': color.toHex(leadingHash: true, includeAlpha: false),
        'totalToEmit': totalToEmit,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmitterConfig &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          rate == other.rate &&
          color.toARGB32() == other.color.toARGB32() &&
          totalToEmit == other.totalToEmit;

  @override
  int get hashCode => Object.hash(x, y, rate, color.toARGB32(), totalToEmit);

  @override
  String toString() =>
      'EmitterConfig(x: $x, y: $y, rate: $rate, color: $color, totalToEmit: $totalToEmit)';
}
