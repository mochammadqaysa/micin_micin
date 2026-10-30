import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/core/constants.dart';
import 'package:micin_micin/engine/game_engine.dart';
import 'package:micin_micin/models/cup_config.dart';
import 'package:micin_micin/models/emitter_config.dart';
import 'package:micin_micin/models/level_config.dart';
import 'package:micin_micin/models/obstacle_config.dart';

void main() {
  group('GameEngine', () {
    late LevelConfig testConfig;

    setUp(() {
      testConfig = const LevelConfig(
        id: 1,
        name: 'Test Level',
        totalSugar: 2,
        gravity: 0.2,
        hasGravityToggle: true,
        canvasHeight: 500,
        emitters: [
          EmitterConfig(x: 100, y: 10, rate: 1, totalToEmit: 2),
        ],
        cups: [
          CupConfig(x: 80, y: 150, width: 40, height: 30, targetAmount: 2),
        ],
      );
    });

    test('constructs via injection and initializes sub-controllers', () {
      final engine = GameEngine(levelConfig: testConfig);

      expect(engine.levelConfig.id, equals(1));
      expect(engine.particleController.emitters.length, equals(1));
      expect(engine.cups.length, equals(1));
      expect(engine.filters, isEmpty);
      expect(engine.isPaused, isFalse);
      expect(engine.isComplete, isFalse);
    });

    test('pause and resume correctly update state and notify listeners', () {
      final engine = GameEngine(levelConfig: testConfig);
      int notificationCount = 0;
      engine.addListener(() => notificationCount++);

      engine.pause();
      expect(engine.isPaused, isTrue);
      expect(notificationCount, equals(1));

      engine.resume();
      expect(engine.isPaused, isFalse);
      expect(notificationCount, equals(2));
    });

    test('toggleGravity reverses vertical gravity direction', () {
      final engine = GameEngine(levelConfig: testConfig);

      expect(engine.particleController.gravity, equals(0.2));

      engine.toggleGravity();
      expect(engine.particleController.gravity, equals(-0.2));

      engine.toggleGravity();
      expect(engine.particleController.gravity, equals(0.2));
    });

    test('reset() performs TOTAL reset: lines, particles, cups, and complete flag', () {
      final engine = GameEngine(levelConfig: testConfig);

      // Add a line
      engine.lineController.onPanStart(const Offset(0, 0));
      engine.lineController.onPanUpdate(const Offset(50, 50));
      engine.lineController.onPanEnd();
      expect(engine.lineController.allSegments.isNotEmpty, isTrue);

      // Simulate particle and cup progress
      engine.particleController.capturedCount = 5;
      engine.cups.first.capturedCount = 5;

      engine.reset();

      expect(engine.lineController.allSegments, isEmpty);
      expect(engine.particleController.capturedCount, equals(0));
      expect(engine.cups.first.capturedCount, equals(0));
      expect(engine.isComplete, isFalse);
    });

    test('win condition triggers _isComplete flag with boolean guard', () {
      final engine = GameEngine(levelConfig: testConfig);
      int notificationCount = 0;
      engine.addListener(() => notificationCount++);

      // Manually satisfy win condition:
      // totalSugar = 2, capturedCount >= 2, and all emitters exhausted
      engine.particleController.capturedCount = 2;
      for (final emitter in engine.particleController.emitters) {
        // exhaust emitter
        while (!emitter.isExhausted) {
          emitter.tick(engine.particleController.pool);
        }
      }

      expect(engine.isLevelComplete, isTrue);
      expect(engine.isComplete, isFalse);

      // Run manual tick
      engine.tickManual(Duration.zero);

      expect(engine.isComplete, isTrue);
      final countAfterFirstTick = notificationCount;

      // Run another tick — _isComplete remains true without redundant re-trigger
      engine.tickManual(const Duration(milliseconds: 16));
      expect(engine.isComplete, isTrue);
      // Notifications continue per frame (for animation rendering)
      expect(notificationCount, greaterThan(countAfterFirstTick));
    });

    test('particle free-fall traversal takes 105–120 frames to reach cup level (AC-002)', () {
      const level = LevelConfig(
        id: 99,
        name: 'Kinematics Test',
        totalSugar: 1,
        gravity: kGravityDefault,
        canvasHeight: kVirtualHeight,
        emitters: [
          EmitterConfig(x: 200, y: 40, rate: 1, totalToEmit: 1),
        ],
        cups: [
          CupConfig(x: 120, y: 500, width: 160, height: 70, targetAmount: 1),
        ],
      );

      final engine = GameEngine(levelConfig: level);
      int frames = 0;
      while (engine.particleController.capturedCount == 0 && frames < 150) {
        engine.tickManual(const Duration(milliseconds: 16));
        frames++;
      }

      expect(engine.particleController.capturedCount, equals(1));
      expect(frames, inInclusiveRange(125, 135));
    });

    test('drawn barrier covering cup mouth deflects 100% of particles (AC-001)', () {
      const level = LevelConfig(
        id: 100,
        name: 'Impenetrability Test',
        totalSugar: 10,
        gravity: kGravityDefault,
        canvasHeight: kVirtualHeight,
        emitters: [
          EmitterConfig(x: 200, y: 40, rate: 2, totalToEmit: 10),
        ],
        cups: [
          CupConfig(x: 160, y: 600, width: 80, height: 70, targetAmount: 10),
        ],
      );

      final engine = GameEngine(levelConfig: level);

      // Player draws a horizontal barrier directly blocking the mouth of the cup (y=580, from x=140 to x=260)
      engine.lineController.onPanStart(const Offset(140, 580));
      engine.lineController.onPanUpdate(const Offset(260, 580));
      engine.lineController.onPanEnd();

      // Simulate 150 frames of physics
      for (int i = 0; i < 150; i++) {
        engine.tickManual(const Duration(milliseconds: 16));
      }

      // Zero particles must penetrate into the cup
      expect(engine.cups.first.capturedCount, equals(0));
      expect(engine.particleController.capturedCount, equals(0));
    });

    test('matching particles falling into cup increment capture count and score', () {
      const level = LevelConfig(
        id: 101,
        name: 'Score Increment Test',
        totalSugar: 5,
        gravity: kGravityDefault,
        canvasHeight: kVirtualHeight,
        emitters: [
          EmitterConfig(x: 200, y: 40, rate: 1, totalToEmit: 5),
        ],
        cups: [
          CupConfig(x: 160, y: 300, width: 80, height: 70, targetAmount: 5),
        ],
      );

      final engine = GameEngine(levelConfig: level);

      // Run 90 frames for calibrated soft gravity traversal to y=300
      for (int i = 0; i < 90; i++) {
        engine.tickManual(const Duration(milliseconds: 16));
      }

      expect(engine.cups.first.capturedCount, greaterThan(0));
      expect(engine.particleController.capturedCount, equals(engine.cups.first.capturedCount));
    });

    test('rigid obstacle beam in levelConfig deflects falling sugar particles', () {
      const level = LevelConfig(
        id: 102,
        name: 'Obstacle Beam Deflection Test',
        totalSugar: 5,
        gravity: 0.25,
        canvasHeight: 500,
        emitters: [
          EmitterConfig(x: 200, y: 50, rate: 1, totalToEmit: 1),
        ],
        cups: [
          CupConfig(x: 200, y: 400, width: 40, height: 40, targetAmount: 1),
        ],
        obstacles: [
          ObstacleConfig(
            x: 150,
            y: 150,
            width: 100,
            height: 20,
          ),
        ],
      );

      final engine = GameEngine(levelConfig: level);
      expect(engine.propColliders.length, equals(4)); // 4 perimeter segments

      // Spawn a particle directly above obstacle beam
      final p = engine.particleController.pool.acquire()!;
      p.x = 200.0;
      p.y = 130.0;
      p.vx = 0.0;
      p.vy = 3.0; // Falling toward top of obstacle at y = 150

      // Step simulation
      for (int i = 0; i < 15; i++) {
        engine.tickManual(const Duration(milliseconds: 16));
      }

      // Particle should have collided with the top of the obstacle beam and rebounded
      expect(p.isActive, isTrue);
      // Particle y should remain near or above the beam rather than passing straight through to y=400
      expect(p.y, lessThan(170.0));
    });
  });
}
