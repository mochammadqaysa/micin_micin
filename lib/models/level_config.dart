import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import 'color_filter_config.dart';
import 'cup_config.dart';
import 'emitter_config.dart';

/// Complete configuration for a level loaded from JSON assets.
class LevelConfig {
  final int id;
  final String name;
  final List<EmitterConfig> emitters;
  final List<CupConfig> cups;
  final List<ColorFilterConfig> filters;
  final int totalSugar;
  final double gravity;
  final bool hasGravityToggle;
  final double canvasHeight;

  const LevelConfig({
    required this.id,
    required this.name,
    required this.emitters,
    required this.cups,
    this.filters = const [],
    required this.totalSugar,
    this.gravity = kGravityDefault,
    this.hasGravityToggle = false,
    this.canvasHeight = kVirtualHeight,
  });

  factory LevelConfig.fromJson(Map<String, dynamic> json) {
    final double rawCanvasHeight =
        (json['canvasHeight'] as num?)?.toDouble() ?? 1.0;
    final bool isNormalized = rawCanvasHeight <= 2.0;
    final double scaleX = isNormalized ? kVirtualWidth : 1.0;
    final double scaleY = isNormalized ? kVirtualHeight : 1.0;

    return LevelConfig(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? 'Level ${json['id']}',
      emitters: (json['emitters'] as List<dynamic>?)
              ?.map((e) => EmitterConfig.fromJson(
                    e as Map<String, dynamic>,
                    scaleX: scaleX,
                    scaleY: scaleY,
                  ))
              .toList() ??
          const [],
      cups: (json['cups'] as List<dynamic>?)
              ?.map((c) => CupConfig.fromJson(
                    c as Map<String, dynamic>,
                    scaleX: scaleX,
                    scaleY: scaleY,
                  ))
              .toList() ??
          const [],
      filters: (json['filters'] as List<dynamic>?)
              ?.map(
                  (f) => ColorFilterConfig.fromJson(
                        f as Map<String, dynamic>,
                        scaleX: scaleX,
                        scaleY: scaleY,
                      ))
              .toList() ??
          const [],
      totalSugar: (json['totalSugar'] as num?)?.toInt() ?? 100,
      gravity: (json['gravity'] as num?)?.toDouble() ?? kGravityDefault,
      hasGravityToggle: json['hasGravityToggle'] as bool? ?? false,
      canvasHeight: isNormalized ? kVirtualHeight : rawCanvasHeight,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emitters': emitters.map((e) => e.toJson()).toList(),
        'cups': cups.map((c) => c.toJson()).toList(),
        'filters': filters.map((f) => f.toJson()).toList(),
        'totalSugar': totalSugar,
        'gravity': gravity,
        'hasGravityToggle': hasGravityToggle,
        'canvasHeight': canvasHeight,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LevelConfig &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          listEquals(emitters, other.emitters) &&
          listEquals(cups, other.cups) &&
          listEquals(filters, other.filters) &&
          totalSugar == other.totalSugar &&
          gravity == other.gravity &&
          hasGravityToggle == other.hasGravityToggle &&
          canvasHeight == other.canvasHeight;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        Object.hashAll(emitters),
        Object.hashAll(cups),
        Object.hashAll(filters),
        totalSugar,
        gravity,
        hasGravityToggle,
        canvasHeight,
      );

  @override
  String toString() =>
      'LevelConfig(id: $id, name: $name, totalSugar: $totalSugar, gravity: $gravity, hasGravityToggle: $hasGravityToggle)';
}
