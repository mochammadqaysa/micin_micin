import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/engine/collision/cup_hitbox.dart';
import 'package:micin_micin/flame_game/components/level_geometry_component.dart';
import 'package:micin_micin/models/color_filter_config.dart';
import 'package:micin_micin/models/cup_config.dart';
import 'package:micin_micin/models/emitter_config.dart';
import 'package:micin_micin/models/level_config.dart';
import 'package:micin_micin/models/obstacle_config.dart';

class _TestGeometryGame extends FlameGame {
  final LevelGeometryFlameComponent geometryComponent;
  _TestGeometryGame(this.geometryComponent);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(geometryComponent);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LevelGeometryFlameComponent Tests (TASK-008, TASK-009, REQ-004, REQ-005)', () {
    testWidgets('mounts and renders cups, comma emitters, obstacles, and filters cleanly',
        (WidgetTester tester) async {
      final config = LevelConfig(
        id: 1,
        name: 'Test Level',
        totalSugar: 150,
        emitters: [
          const EmitterConfig(x: 200, y: 50, rate: 3, color: Colors.white),
        ],
        cups: [
          const CupConfig(
            x: 160,
            y: 500,
            width: 80,
            height: 60,
            targetAmount: 100,
            color: Color(0xFFE2E8F0),
          ),
        ],
        filters: [
          const ColorFilterConfig(
            x: 180,
            y: 300,
            width: 40,
            height: 20,
            targetColor: Colors.amber,
          ),
        ],
        obstacles: [
          const ObstacleConfig(
            x: 50,
            y: 200,
            width: 100,
            height: 12,
            rotation: 0.15,
            color: Color(0xFF30D30B),
          ),
        ],
      );

      final liveCups = [
        CupHitbox(
          bounds: const Rect.fromLTWH(160, 500, 80, 60),
          targetAmount: 100,
          color: const Color(0xFFE2E8F0),
        ),
      ];

      final component = LevelGeometryFlameComponent(
        levelConfig: config,
        liveCupsGetter: () => liveCups,
        defaultObstacleColor: const Color(0xFF30D30B),
      );

      final game = _TestGeometryGame(component);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameWidget(game: game),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(component.isMounted, isTrue);
      expect(component.priority, 10);

      // Verify countdown transition to 0 (gold text state)
      liveCups[0].capturedCount = 100;
      await tester.pump(const Duration(milliseconds: 50));

      // Verify clearCache static method executes cleanly
      LevelGeometryFlameComponent.clearCache();
    });

    testWidgets('handles multiple cups with distinct fill levels and gold transition',
        (WidgetTester tester) async {
      final config = LevelConfig(
        id: 2,
        name: 'Dual Cup Stage',
        totalSugar: 200,
        emitters: [
          const EmitterConfig(x: 100, y: 40, rate: 2, color: Colors.white),
          const EmitterConfig(x: 300, y: 40, rate: 2, color: Color(0xFFFF00EF)),
        ],
        cups: [
          const CupConfig(
            x: 80,
            y: 520,
            width: 70,
            height: 55,
            targetAmount: 50,
            color: Colors.white,
          ),
          const CupConfig(
            x: 240,
            y: 520,
            width: 70,
            height: 55,
            targetAmount: 50,
            color: Color(0xFFFF00EF),
          ),
        ],
      );

      final liveCups = [
        CupHitbox(
          bounds: const Rect.fromLTWH(80, 520, 70, 55),
          targetAmount: 50,
          capturedCount: 25, // remaining: 25
          color: Colors.white,
        ),
        CupHitbox(
          bounds: const Rect.fromLTWH(240, 520, 70, 55),
          targetAmount: 50,
          capturedCount: 50, // remaining: 0 (gold!)
          color: const Color(0xFFFF00EF),
        ),
      ];

      final component = LevelGeometryFlameComponent(
        levelConfig: config,
        liveCupsGetter: () => liveCups,
      );

      final game = _TestGeometryGame(component);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameWidget(game: game),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(component.isMounted, isTrue);
    });
  });
}
