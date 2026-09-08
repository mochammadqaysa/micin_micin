import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/engine/collision/cup_hitbox.dart';
import 'package:micin_micin/engine/drawing/drawn_line.dart';
import 'package:micin_micin/models/cup_config.dart';
import 'package:micin_micin/models/level_config.dart';
import 'package:micin_micin/models/sugar_particle.dart';
import 'package:micin_micin/screens/game/painters/level_painter.dart';
import 'package:micin_micin/screens/game/painters/line_painter.dart';
import 'package:micin_micin/screens/game/painters/particle_painter.dart';

void main() {
  group('Painters Optimization Tests (PRN-001, PRN-002)', () {
    test('LevelPainter shouldRepaint returns false when live cup counts are unchanged', () {
      const config = LevelConfig(
        id: 1,
        name: 'Test',
        totalSugar: 10,
        emitters: [],
        cups: [
          CupConfig(x: 100, y: 300, width: 60, height: 50, targetAmount: 10),
        ],
      );

      final cup1 = CupHitbox(
        bounds: const Rect.fromLTWH(100, 300, 60, 50),
        color: Colors.white,
        targetAmount: 10,
      );

      final painter1 = LevelPainter(levelConfig: config, liveCups: [cup1]);
      final painter2 = LevelPainter(levelConfig: config, liveCups: [cup1]);

      expect(painter2.shouldRepaint(painter1), isFalse);

      // Mutating capturedCount on live cup causes new LevelPainter to trigger shouldRepaint
      cup1.capturedCount = 1;
      final painter3 = LevelPainter(levelConfig: config, liveCups: [cup1]);
      expect(painter3.shouldRepaint(painter1), isTrue);
    });

    test('LinePainter shouldRepaint returns false when lines reference is identical', () {
      final lines = [
        const DrawnLine(points: [Offset(0, 0), Offset(10, 10)]),
      ];

      final painter1 = LinePainter(lines);
      final painter2 = LinePainter(lines);

      expect(painter2.shouldRepaint(painter1), isFalse);

      final newLines = [
        ...lines,
        const DrawnLine(points: [Offset(10, 10), Offset(20, 20)]),
      ];
      final painter3 = LinePainter(newLines);
      expect(painter3.shouldRepaint(painter1), isTrue);
    });

    test('ParticlePainter renders active particles and buffers without throwing', () {
      final particles = [
        SugarParticle(x: 10, y: 20, color: const Color(0xFFFFFFFF)),
        SugarParticle(x: 30, y: 40, color: const Color(0xFFFF0000)),
      ]..forEach((p) => p.isActive = true);

      final painter = ParticlePainter(particles);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      expect(() => painter.paint(canvas, const Size(400, 700)), returnsNormally);

      // Verify clearBuffers works without issue
      ParticlePainter.clearBuffers();
    });
  });
}
