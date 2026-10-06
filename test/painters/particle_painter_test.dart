import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/core/constants.dart';
import 'package:micin_micin/engine/collision/cup_hitbox.dart';
import 'package:micin_micin/models/sugar_particle.dart';
import 'package:micin_micin/screens/game/painters/particle_painter.dart';

/// Test canvas spy to inspect paint parameters and drawn points.
class _SpyCanvas implements Canvas {
  final List<Paint> capturedPaints = [];
  final List<List<Offset>> capturedPoints = [];
  final List<ui.PointMode> capturedModes = [];

  @override
  void drawPoints(ui.PointMode pointMode, List<Offset> points, Paint paint) {
    capturedModes.add(pointMode);
    capturedPoints.add(List<Offset>.from(points));
    // Copy paint attributes to preserve state at drawing time
    final recordedPaint = Paint()
      ..color = paint.color
      ..strokeWidth = paint.strokeWidth
      ..strokeCap = paint.strokeCap;
    capturedPaints.add(recordedPaint);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('ParticlePainter Bonte Aesthetic Tests (AC-001, TASK-104)', () {
    setUp(() {
      ParticlePainter.clearBuffers();
    });

    tearDown(() {
      ParticlePainter.clearBuffers();
    });

    test('renders active particles with StrokeCap.square and 2.2px width (AC-001)', () {
      final p1 = SugarParticle(x: 100.0, y: 150.0, color: const Color(0xFFFFFFFF))
        ..isActive = true
        ..opacity = 0.95;
      final p2 = SugarParticle(x: 102.0, y: 154.0, color: const Color(0xFFFFFFFF))
        ..isActive = true
        ..opacity = 1.0;
      final pInactive = SugarParticle(x: 200.0, y: 200.0, color: const Color(0xFFFFFFFF))
        ..isActive = false;
      final pCaptured = SugarParticle(x: 250.0, y: 250.0, color: const Color(0xFFFFFFFF))
        ..isActive = true
        ..isCaptured = true;

      final spyCanvas = _SpyCanvas();
      final painter = ParticlePainter([p1, p2, pInactive, pCaptured]);

      painter.paint(spyCanvas, const Size(400, 700));

      expect(spyCanvas.capturedPoints.isNotEmpty, isTrue);
      // All batch draw calls must use StrokeCap.square and 2.2px strokeWidth
      for (final recordedPaint in spyCanvas.capturedPaints) {
        expect(recordedPaint.strokeCap, equals(StrokeCap.square));
        expect(recordedPaint.strokeWidth, closeTo(kParticleRadius * 2.0, 0.001));
      }

      // Check points count: only active, non-captured particles are rendered
      final allPoints = spyCanvas.capturedPoints.expand((list) => list).toList();
      expect(allPoints.length, equals(2));
      expect(allPoints, contains(const Offset(100.0, 150.0)));
      expect(allPoints, contains(const Offset(102.0, 154.0)));
    });

    test('renders settled sand mounds in cups using StrokeCap.square (AC-001)', () {
      final cup = CupHitbox(
        bounds: const Rect.fromLTWH(100, 500, 60, 40),
        color: const Color(0xFFFF5555),
        targetAmount: 20,
      );
      cup.settledParticleOffsets.add(const Offset(120.0, 530.0));
      cup.settledParticleOffsets.add(const Offset(125.0, 532.0));

      final spyCanvas = _SpyCanvas();
      final painter = ParticlePainter([], cups: [cup]);

      painter.paint(spyCanvas, const Size(400, 700));

      expect(spyCanvas.capturedPoints.isNotEmpty, isTrue);
      final moundPaint = spyCanvas.capturedPaints.last;
      expect(moundPaint.strokeCap, equals(StrokeCap.square));
      expect(moundPaint.strokeWidth, closeTo(2.2, 0.001));
      expect(moundPaint.color.toARGB32(), equals(const Color(0xFFFF5555).toARGB32()));
      expect(spyCanvas.capturedPoints.last.length, equals(2));
    });

    test('clearBuffers flushes static batch caches without memory leak', () {
      final p = SugarParticle(x: 50.0, y: 50.0, color: const Color(0xFF00FF00))
        ..isActive = true;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final painter = ParticlePainter([p]);

      expect(() => painter.paint(canvas, const Size(400, 700)), returnsNormally);

      // Verify clearing buffers works safely
      expect(() => ParticlePainter.clearBuffers(), returnsNormally);
    });

    test('shouldRepaint always returns true for continuous particle animation', () {
      final painter1 = ParticlePainter([]);
      final painter2 = ParticlePainter([]);
      expect(painter1.shouldRepaint(painter2), isTrue);
    });
  });
}
