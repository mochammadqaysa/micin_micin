import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/engine/color_filter/color_filter_zone.dart';
import 'package:micin_micin/models/color_filter_config.dart';
import 'package:micin_micin/models/sugar_particle.dart';

void main() {
  group('ColorFilterZone', () {
    test('contains accurately tests point boundary', () {
      const zone = ColorFilterZone(
        region: Rect.fromLTWH(50, 50, 100, 20),
        targetColor: Color(0xFFFF0055),
      );

      expect(zone.contains(60, 60), isTrue);
      expect(zone.contains(10, 10), isFalse);
    });

    test('apply mutates passing particle color', () {
      const zone = ColorFilterZone(
        region: Rect.fromLTWH(0, 0, 100, 100),
        targetColor: Color(0xFF00FF00),
      );

      final particleInside = SugarParticle(
        x: 50,
        y: 50,
        color: const Color(0xFFFFFFFF),
      );

      zone.apply(particleInside);
      expect(particleInside.color, equals(const Color(0xFF00FF00)));

      final particleOutside = SugarParticle(
        x: 200,
        y: 200,
        color: const Color(0xFFFFFFFF),
      );

      zone.apply(particleOutside);
      expect(particleOutside.color, equals(const Color(0xFFFFFFFF)));
    });

    test('fromConfig builds zone with scaled coordinates', () {
      const config = ColorFilterConfig(
        x: 0.2,
        y: 0.3,
        width: 0.6,
        height: 0.1,
        targetColor: Color(0xFFFFCC00),
      );

      final zone = ColorFilterZone.fromConfig(
        config,
        canvasWidth: 500,
        canvasHeight: 1000,
      );

      expect(zone.region.left, equals(100.0));
      expect(zone.region.top, equals(300.0));
      expect(zone.region.width, equals(300.0));
      expect(zone.region.height, equals(100.0));
      expect(zone.targetColor, equals(const Color(0xFFFFCC00)));
    });
  });
}
