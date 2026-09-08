import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/models/color_filter_config.dart';
import 'package:micin_micin/models/cup_config.dart';
import 'package:micin_micin/models/emitter_config.dart';

void main() {
  group('EmitterConfig', () {
    test('parses complete valid JSON correctly', () {
      final json = {
        'x': 0.5,
        'y': 0.1,
        'rate': 4,
        'color': '#FFCC00',
        'totalToEmit': 120,
      };

      final emitter = EmitterConfig.fromJson(json);

      expect(emitter.x, equals(0.5));
      expect(emitter.y, equals(0.1));
      expect(emitter.rate, equals(4));
      expect(emitter.color, equals(const Color(0xFFFFCC00)));
      expect(emitter.totalToEmit, equals(120));
    });

    test('parses JSON with optional fields omitted using defaults', () {
      final json = {
        'x': 0.25,
        'y': 0.05,
      };

      final emitter = EmitterConfig.fromJson(json);

      expect(emitter.x, equals(0.25));
      expect(emitter.y, equals(0.05));
      expect(emitter.rate, equals(3));
      expect(emitter.color, equals(const Color(0xFFFFFFFF)));
      expect(emitter.totalToEmit, equals(100));
    });

    test('serializes to JSON and performs round-trip correctly', () {
      const original = EmitterConfig(
        x: 0.75,
        y: 0.15,
        rate: 2,
        color: Color(0xFF00E5FF),
        totalToEmit: 80,
      );

      final json = original.toJson();
      final reconstructed = EmitterConfig.fromJson(json);

      expect(reconstructed, equals(original));
      expect(reconstructed.hashCode, equals(original.hashCode));
    });
  });

  group('CupConfig', () {
    test('parses complete valid JSON correctly', () {
      final json = {
        'x': 0.4,
        'y': 0.8,
        'width': 0.12,
        'height': 0.09,
        'color': '#FF4081',
        'targetAmount': 90,
      };

      final cup = CupConfig.fromJson(json);

      expect(cup.x, equals(0.4));
      expect(cup.y, equals(0.8));
      expect(cup.width, equals(0.12));
      expect(cup.height, equals(0.09));
      expect(cup.color, equals(const Color(0xFFFF4081)));
      expect(cup.targetAmount, equals(90));
    });

    test('parses JSON with optional fields omitted using defaults', () {
      final json = {
        'x': 0.5,
        'y': 0.85,
        'width': 0.1,
        'height': 0.08,
      };

      final cup = CupConfig.fromJson(json);

      expect(cup.x, equals(0.5));
      expect(cup.y, equals(0.85));
      expect(cup.width, equals(0.1));
      expect(cup.height, equals(0.08));
      expect(cup.color, equals(const Color(0xFFFFFFFF)));
      expect(cup.targetAmount, equals(100));
    });

    test('serializes to JSON and performs round-trip correctly', () {
      const original = CupConfig(
        x: 0.35,
        y: 0.75,
        width: 0.15,
        height: 0.1,
        color: Color(0xFFFF5252),
        targetAmount: 50,
      );

      final json = original.toJson();
      final reconstructed = CupConfig.fromJson(json);

      expect(reconstructed, equals(original));
      expect(reconstructed.hashCode, equals(original.hashCode));
    });
  });

  group('ColorFilterConfig', () {
    test('parses valid JSON with targetColor key', () {
      final json = {
        'x': 0.3,
        'y': 0.4,
        'width': 0.4,
        'height': 0.06,
        'targetColor': '#FF0055',
      };

      final filter = ColorFilterConfig.fromJson(json);

      expect(filter.x, equals(0.3));
      expect(filter.y, equals(0.4));
      expect(filter.width, equals(0.4));
      expect(filter.height, equals(0.06));
      expect(filter.targetColor, equals(const Color(0xFFFF0055)));
    });

    test('parses JSON with alternative color key for compatibility', () {
      final json = {
        'x': 0.2,
        'y': 0.5,
        'width': 0.3,
        'height': 0.05,
        'color': '#00E676',
      };

      final filter = ColorFilterConfig.fromJson(json);

      expect(filter.targetColor, equals(const Color(0xFF00E676)));
    });

    test('serializes to JSON and performs round-trip correctly', () {
      const original = ColorFilterConfig(
        x: 0.1,
        y: 0.3,
        width: 0.8,
        height: 0.04,
        targetColor: Color(0xFF7C4DFF),
      );

      final json = original.toJson();
      final reconstructed = ColorFilterConfig.fromJson(json);

      expect(reconstructed, equals(original));
      expect(reconstructed.hashCode, equals(original.hashCode));
    });
  });
}
