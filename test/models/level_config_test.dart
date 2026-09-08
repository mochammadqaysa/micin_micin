import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/core/constants.dart';
import 'package:micin_micin/models/color_filter_config.dart';
import 'package:micin_micin/models/cup_config.dart';
import 'package:micin_micin/models/emitter_config.dart';
import 'package:micin_micin/models/level_config.dart';

void main() {
  group('LevelConfig', () {
    test('parses full complete level JSON correctly', () {
      final json = {
        'id': 15,
        'name': 'Level 15: Dual Color Challenge',
        'totalSugar': 150,
        'gravity': 0.25,
        'hasGravityToggle': true,
        'canvasHeight': 1.0,
        'emitters': [
          {'x': 0.5, 'y': 0.05, 'rate': 3, 'color': '#FFFFFF', 'totalToEmit': 150},
        ],
        'cups': [
          {'x': 0.3, 'y': 0.85, 'width': 0.1, 'height': 0.08, 'color': '#FF0000', 'targetAmount': 75},
          {'x': 0.7, 'y': 0.85, 'width': 0.1, 'height': 0.08, 'color': '#00FF00', 'targetAmount': 75},
        ],
        'filters': [
          {'x': 0.2, 'y': 0.4, 'width': 0.3, 'height': 0.05, 'targetColor': '#FF0000'},
          {'x': 0.6, 'y': 0.4, 'width': 0.3, 'height': 0.05, 'targetColor': '#00FF00'},
        ],
      };

      final level = LevelConfig.fromJson(json);

      expect(level.id, equals(15));
      expect(level.name, equals('Level 15: Dual Color Challenge'));
      expect(level.totalSugar, equals(150));
      expect(level.gravity, equals(0.25));
      expect(level.hasGravityToggle, isTrue);
      expect(level.canvasHeight, equals(kVirtualHeight));
      expect(level.emitters.length, equals(1));
      // Auto-scaled from normalized coordinates to 400x700
      expect(level.emitters[0].x, equals(200.0));
      expect(level.emitters[0].y, equals(35.0));
      expect(level.cups.length, equals(2));
      expect(level.cups[0].x, equals(120.0));
      expect(level.cups[0].y, equals(595.0));
      expect(level.cups[0].width, equals(40.0));
      expect(level.cups[0].height, equals(56.0));
      expect(level.filters.length, equals(2));
      expect(level.filters[0].x, equals(80.0));
      expect(level.filters[0].y, equals(280.0));
      expect(level.cups[0].color, equals(const Color(0xFFFF0000)));
      expect(level.cups[1].color, equals(const Color(0xFF00FF00)));
    });

    test('parses minimal level JSON with optional fields omitted and auto-scales', () {
      final json = {
        'id': 1,
        'totalSugar': 100,
        'emitters': [
          {'x': 0.5, 'y': 0.05},
        ],
        'cups': [
          {'x': 0.45, 'y': 0.85, 'width': 0.1, 'height': 0.08},
        ],
      };

      final level = LevelConfig.fromJson(json);

      expect(level.id, equals(1));
      expect(level.name, equals('Level 1'));
      expect(level.totalSugar, equals(100));
      expect(level.gravity, equals(kGravityDefault));
      expect(level.hasGravityToggle, isFalse);
      expect(level.canvasHeight, equals(kVirtualHeight));
      expect(level.filters, isEmpty);
      expect(level.emitters.length, equals(1));
      expect(level.emitters[0].x, equals(200.0));
      expect(level.emitters[0].y, equals(35.0));
      expect(level.cups.length, equals(1));
      expect(level.cups[0].x, equals(180.0));
      expect(level.cups[0].y, equals(595.0));
    });

    test('parses native virtual JSON without extra scaling when canvasHeight > 2.0', () {
      final json = {
        'id': 2,
        'name': 'Level 2: Native Virtual',
        'totalSugar': 100,
        'gravity': 0.25,
        'canvasHeight': 700.0,
        'emitters': [
          {'x': 200.0, 'y': 50.0, 'rate': 3, 'color': '#FFFFFF', 'totalToEmit': 100},
        ],
        'cups': [
          {'x': 160.0, 'y': 600.0, 'width': 80.0, 'height': 70.0, 'color': '#FFFFFF', 'targetAmount': 100},
        ],
      };

      final level = LevelConfig.fromJson(json);

      expect(level.canvasHeight, equals(700.0));
      expect(level.emitters[0].x, equals(200.0));
      expect(level.emitters[0].y, equals(50.0));
      expect(level.cups[0].x, equals(160.0));
      expect(level.cups[0].y, equals(600.0));
      expect(level.cups[0].width, equals(80.0));
      expect(level.cups[0].height, equals(70.0));
    });

    test('serializes to JSON and performs round-trip correctly', () {
      const original = LevelConfig(
        id: 7,
        name: 'Level 7',
        emitters: [
          EmitterConfig(x: 200.0, y: 35.0, rate: 3, color: Colors.white, totalToEmit: 100),
        ],
        cups: [
          CupConfig(x: 200.0, y: 630.0, width: 48.0, height: 56.0, color: Colors.white, targetAmount: 100),
        ],
        filters: [
          ColorFilterConfig(x: 120.0, y: 350.0, width: 160.0, height: 35.0, targetColor: Colors.amber),
        ],
        totalSugar: 100,
        gravity: 0.2,
        hasGravityToggle: false,
        canvasHeight: kVirtualHeight,
      );

      final json = original.toJson();
      final reconstructed = LevelConfig.fromJson(json);

      expect(reconstructed, equals(original));
      expect(reconstructed.hashCode, equals(original.hashCode));
    });
  });
}
