import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/models/obstacle_config.dart';

void main() {
  group('ObstacleConfig Tests', () {
    test('serializes and deserializes cleanly with JSON', () {
      const obstacle = ObstacleConfig(
        x: 100.0,
        y: 250.0,
        width: 120.0,
        height: 14.0,
        rotation: 0.25,
        color: Color(0xFF30D30B),
      );

      final json = obstacle.toJson();
      final fromJson = ObstacleConfig.fromJson(json);

      expect(fromJson, equals(obstacle));
      expect(fromJson.x, equals(100.0));
      expect(fromJson.y, equals(250.0));
      expect(fromJson.width, equals(120.0));
      expect(fromJson.height, equals(14.0));
      expect(fromJson.rotation, equals(0.25));
      expect(fromJson.color, equals(const Color(0xFF30D30B)));
    });

    test('supports optional color and rotation default', () {
      final json = {
        'x': 50,
        'y': 150,
        'width': 80,
        'height': 10,
      };

      final obstacle = ObstacleConfig.fromJson(json);
      expect(obstacle.x, equals(50.0));
      expect(obstacle.y, equals(150.0));
      expect(obstacle.width, equals(80.0));
      expect(obstacle.height, equals(10.0));
      expect(obstacle.rotation, equals(0.0));
      expect(obstacle.color, isNull);
    });

    test('toLineSegments generates 4 bounding segments for rigid collision', () {
      const obstacle = ObstacleConfig(
        x: 100.0,
        y: 200.0,
        width: 100.0,
        height: 20.0,
      );

      final segments = obstacle.toLineSegments();
      expect(segments.length, equals(4));

      // Top: (100, 200) -> (200, 200)
      expect(segments[0].start, equals(const Offset(100.0, 200.0)));
      expect(segments[0].end, equals(const Offset(200.0, 200.0)));

      // Right: (200, 200) -> (200, 220)
      expect(segments[1].start, equals(const Offset(200.0, 200.0)));
      expect(segments[1].end, equals(const Offset(200.0, 220.0)));

      // Bottom: (200, 220) -> (100, 220)
      expect(segments[2].start, equals(const Offset(200.0, 220.0)));
      expect(segments[2].end, equals(const Offset(100.0, 220.0)));

      // Left: (100, 220) -> (100, 200)
      expect(segments[3].start, equals(const Offset(100.0, 220.0)));
      expect(segments[3].end, equals(const Offset(100.0, 200.0)));
    });
  });
}

