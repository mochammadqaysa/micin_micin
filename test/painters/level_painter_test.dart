import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/engine/collision/cup_hitbox.dart';
import 'package:micin_micin/models/cup_config.dart';
import 'package:micin_micin/models/emitter_config.dart';
import 'package:micin_micin/models/level_config.dart';
import 'package:micin_micin/screens/game/painters/level_painter.dart';

void main() {
  group('LevelPainter 2.5D Isometric Rendering Tests', () {
    const config = LevelConfig(
      id: 1,
      name: 'Level 1',
      totalSugar: 100,
      emitters: [
        EmitterConfig(x: 200, y: 50, rate: 3, totalToEmit: 100),
      ],
      cups: [
        CupConfig(x: 180, y: 590, width: 44, height: 60, targetAmount: 100),
      ],
    );

    test('paints 2.5D isometric cups and funnel emitters without throwing', () {
      final painter = LevelPainter(
        levelConfig: config,
        liveCups: [
          CupHitbox(
            bounds: const Rect.fromLTWH(180, 590, 44, 60),
            targetAmount: 100,
            color: Colors.white,
          ),
        ],
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 700);

      expect(() => painter.paint(canvas, size), returnsNormally);
      final picture = recorder.endRecording();
      picture.dispose();
    });

    test('shouldRepaint detects changes in capturedCount correctly', () {
      final cup1 = CupHitbox(
        bounds: const Rect.fromLTWH(180, 590, 44, 60),
        targetAmount: 100,
        color: Colors.white,
      );
      final painter1 = LevelPainter(
        levelConfig: config,
        liveCups: [cup1],
      );

      final cup2 = CupHitbox(
        bounds: const Rect.fromLTWH(180, 590, 44, 60),
        targetAmount: 100,
        color: Colors.white,
      )..capturedCount = 5;

      final painter2 = LevelPainter(
        levelConfig: config,
        liveCups: [cup2],
      );

      expect(painter2.shouldRepaint(painter1), isTrue);
    });
  });
}
