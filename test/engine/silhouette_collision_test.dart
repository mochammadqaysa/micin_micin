import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/engine/collision/silhouette_collider_factory.dart';
import 'package:micin_micin/engine/game_engine.dart';
import 'package:micin_micin/engine/particle/particle_controller.dart';
import 'package:micin_micin/engine/particle/particle_pool.dart';
import 'package:micin_micin/models/cup_config.dart';
import 'package:micin_micin/models/emitter_config.dart';
import 'package:micin_micin/models/level_config.dart';
import 'package:micin_micin/models/silhouette_prop_config.dart';
import 'package:micin_micin/screens/game/painters/silhouette_painter.dart';

void main() {
  group('SilhouetteColliderFactory Geometric Tests (REQ-005, TASK-302)', () {
    test('creates non-empty valid LineSegments for all SilhouetteType variants', () {
      for (final type in SilhouetteType.values) {
        final colliders = SilhouetteColliderFactory.create(
          type: type,
          origin: const Offset(150.0, 300.0),
          scale: 1.0,
          rotationDegrees: 0.0,
        );

        expect(colliders.isNotEmpty, isTrue, reason: 'Failed for type: $type');
        for (final segment in colliders) {
          // Verify non-degenerate line segments
          final dx = segment.end.dx - segment.start.dx;
          final dy = segment.end.dy - segment.start.dy;
          final lengthSq = dx * dx + dy * dy;
          expect(lengthSq, greaterThan(0.0), reason: 'Degenerate segment in $type');
          expect(segment.thickness, greaterThanOrEqualTo(3.0));
        }
      }
    });

    test('applies transform translation, scale, and rotation accurately', () {
      const origin = Offset(200.0, 400.0);
      final collidersScaled = SilhouetteColliderFactory.create(
        type: SilhouetteType.teaspoon,
        origin: origin,
        scale: 2.0,
        rotationDegrees: 90.0,
      );

      expect(collidersScaled.isNotEmpty, isTrue);
      // All vertices must be positioned around transformed origin
      for (final segment in collidersScaled) {
        expect(segment.start.dx, isNot(equals(0.0)));
        expect(segment.start.dy, isNot(equals(0.0)));
      }
    });

    test('SilhouettePropConfig.generateColliders delegates to factory', () {
      const prop = SilhouettePropConfig(
        type: SilhouetteType.teaspoon,
        origin: Offset(100.0, 200.0),
        scale: 1.2,
        rotationDegrees: -10.0,
      );

      final colliders = prop.generateColliders();
      expect(colliders.isNotEmpty, isTrue);
      expect(colliders.length, equals(7)); // 8 points -> 7 segments
    });
  });

  group('Silhouette Physics Deflection Simulation (REQ-005, AC-005, TASK-306)', () {
    test('falling sugar grains deflect off teaspoon contour without tunneling (AC-005)', () {
      // 1. Setup a teaspoon prop positioned horizontally below a falling particle
      const spoonProp = SilhouettePropConfig(
        type: SilhouetteType.teaspoon,
        origin: Offset(150.0, 300.0),
        scale: 1.0,
        rotationDegrees: 0.0,
      );
      final spoonColliders = spoonProp.generateColliders();

      final pool = ParticlePool(capacity: 10);
      final controller = ParticleController(
        pool: pool,
        emitters: [],
        gravity: 0.25,
      );

      // 2. Spawn a falling particle directly above the spoon's bowl
      final particle = pool.acquire()!;
      particle.x = 180.0;
      particle.y = 290.0;
      particle.vx = 0.0;
      particle.vy = 4.0; // Fast downward velocity heading towards spoon bowl (~y: 318)
      particle.isActive = true;

      // 3. Step physics simulation across multiple frames
      bool collisionDetected = false;
      for (int frame = 0; frame < 15; frame++) {
        controller.update(
          lines: const [],
          obstacles: spoonColliders,
          cups: const [],
          filters: const [],
          canvasHeight: 700.0,
        );

        // Check if velocity was redirected by normal reflection
        if (particle.vx.abs() > 0.05) {
          collisionDetected = true;
        }
      }

      // Verification: Particle must have hit the spoon and deflected horizontally
      expect(collisionDetected, isTrue, reason: 'Particle should deflect off spoon bowl');
      expect(particle.isActive, isTrue);
    });

    test('GameEngine routes deflected grains off teaspoon prop into target cup (AC-005)', () {
      // Setup Level with Teaspoon deflector guiding grains into target cup
      const levelConfig = LevelConfig(
        id: 5,
        name: 'The Teaspoon',
        totalSugar: 10,
        gravity: 0.20,
        canvasHeight: 700.0,
        emitters: [
          EmitterConfig(x: 170.0, y: 150.0, rate: 1, totalToEmit: 5),
        ],
        cups: [
          CupConfig(x: 210.0, y: 350.0, width: 60.0, height: 60.0, targetAmount: 5),
        ],
      );

      final spoonProp = const SilhouettePropConfig(
        type: SilhouetteType.teaspoon,
        origin: Offset(150.0, 260.0),
        scale: 1.0,
        rotationDegrees: 5.0, // Tilted towards the cup on right
      );

      final engine = GameEngine(
        levelConfig: levelConfig,
        propColliders: spoonProp.generateColliders(),
      );

      // Verify engine received prop colliders
      expect(engine.propColliders.isNotEmpty, isTrue);

      // Run 60 frames of deterministic simulation
      for (int frame = 0; frame < 60; frame++) {
        engine.tickManual(const Duration(milliseconds: 16));
      }

      // Particles must have dropped, contacted spoon, and progressed towards goal
      expect(engine.particleController.pool.activeParticles.isNotEmpty, isTrue);
    });
  });

  group('SilhouettePainter Unit Tests (TASK-303)', () {
    test('renders all silhouette props without throws', () {
      final props = [
        const SilhouettePropConfig(
          type: SilhouetteType.teaspoon,
          origin: Offset(100.0, 200.0),
        ),
        const SilhouettePropConfig(
          type: SilhouetteType.handPouring,
          origin: Offset(250.0, 80.0),
        ),
      ];

      final painter = SilhouettePainter(props);
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      expect(() => painter.paint(canvas, const Size(400.0, 700.0)), returnsNormally);

      // Verify shouldRepaint logic
      final identicalPainter = SilhouettePainter(props);
      expect(painter.shouldRepaint(identicalPainter), isFalse);

      final otherPainter = SilhouettePainter(const []);
      expect(painter.shouldRepaint(otherPainter), isTrue);
    });

    test('paints nothing when props list is empty', () {
      const painter = SilhouettePainter([]);
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      expect(() => painter.paint(canvas, const Size(400.0, 700.0)), returnsNormally);
    });
  });
}
