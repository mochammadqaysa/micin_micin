import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/data/level_repository.dart';
import 'package:micin_micin/engine/game_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Gravity Toggle Integration Tests', () {
    test('Level 21: Gravity toggle inverts direction and propels particle upwards into top cup', () async {
      const repo = LevelRepository();
      final level21Config = await repo.loadLevel(21);

      expect(level21Config.hasGravityToggle, isTrue);
      expect(level21Config.cups.first.y, equals(105.0)); // Top cup (0.15 * 700)

      final engine = GameEngine(levelConfig: level21Config);
      expect(engine.particleController.gravity, greaterThan(0));

      final particle = engine.particleController.pool.acquire()!;
      particle.x = 200.0;
      particle.y = 300.0;
      particle.vx = 0.0;
      particle.vy = 0.0;

      // Invert gravity
      engine.toggleGravity();
      expect(engine.particleController.gravity, lessThan(0));

      // Simulate upward motion
      for (int i = 0; i < 5; i++) {
        engine.tickManual(Duration.zero);
      }

      // Particle should now be moving upwards (negative vy and y decreased)
      expect(particle.vy, lessThan(0.0));
      expect(particle.y, lessThan(300.0));

      // Guide particle into the top cup
      particle.x = level21Config.cups.first.x + level21Config.cups.first.width / 2.0;
      particle.y = level21Config.cups.first.y + level21Config.cups.first.height / 2.0;

      engine.tickManual(Duration.zero);

      expect(particle.isCaptured, isTrue);
      expect(engine.cups.first.capturedCount, greaterThanOrEqualTo(1));
    });
  });
}
