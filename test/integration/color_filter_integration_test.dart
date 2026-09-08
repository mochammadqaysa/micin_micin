import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/data/level_repository.dart';
import 'package:micin_micin/engine/collision/cup_hitbox.dart';
import 'package:micin_micin/engine/game_engine.dart';
import 'package:micin_micin/models/sugar_particle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Color Filter Integration Tests', () {
    test('Level 11: Particle passes through red filter and captures into red cup', () async {
      const repo = LevelRepository();
      final level11Config = await repo.loadLevel(11);

      final engine = GameEngine(levelConfig: level11Config);

      // Verify Level 11 has pastel rose filter and rose cup
      expect(level11Config.filters.length, equals(1));
      expect(level11Config.cups.length, equals(1));
      expect(level11Config.filters.first.targetColor, equals(const Color(0xFFF4A7B9)));
      expect(level11Config.cups.first.color, equals(const Color(0xFFF4A7B9)));

      // Spawn a particle directly from emitter location
      final particle = engine.particleController.pool.acquire()!;
      particle.x = level11Config.emitters.first.x;
      particle.y = level11Config.emitters.first.y;
      particle.vx = 0.0;
      particle.vy = 0.0;
      particle.color = const Color(0xFFFFFFFF); // Starts white

      // Simulate until particle falls through the filter zone
      final filterBottom =
          level11Config.filters.first.y + level11Config.filters.first.height;
      while (particle.y <= filterBottom && particle.isActive) {
        engine.tickManual(Duration.zero);
      }

      // Particle should now be mutated to pastel rose (#F4A7B9)
      expect(particle.color, equals(const Color(0xFFF4A7B9)));

      // Place the dyed red particle directly at the bottom surface of the red cup
      particle.x = level11Config.cups.first.x + level11Config.cups.first.width / 2.0;
      particle.y = level11Config.cups.first.y + level11Config.cups.first.height - 1.0;
      particle.vx = 0.0;
      particle.vy = 0.0;

      engine.tickManual(Duration.zero);

      // Verify particle is captured by red cup
      expect(particle.isCaptured, isTrue);
      expect(engine.cups.first.capturedCount, equals(1));
      expect(engine.particleController.capturedCount, equals(1));
    });

    test('Red dyed particle entering a white cup is REJECTED and NOT captured', () {
      final whiteCup = CupHitbox(
        bounds: const Rect.fromLTWH(0.4, 0.8, 0.2, 0.1),
        color: const Color(0xFFFFFFFF), // White cup
      );

      final redParticle = SugarParticle(
        x: 0.45,
        y: 0.85,
        color: const Color(0xFFFF3B30), // Dyed red
      );

      expect(whiteCup.contains(redParticle.x, redParticle.y), isTrue);
      expect(whiteCup.matches(redParticle), isFalse,
          reason: 'Colored particle cannot be captured by a white cup');
    });
  });
}
