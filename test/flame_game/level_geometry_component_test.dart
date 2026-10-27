import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/engine/collision/cup_hitbox.dart';
import 'package:micin_micin/flame_game/components/level_geometry_component.dart';
import 'package:micin_micin/models/color_filter_config.dart';
import 'package:micin_micin/models/cup_config.dart';
import 'package:micin_micin/models/emitter_config.dart';
import 'package:micin_micin/models/level_config.dart';

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

  group('LevelGeometryFlameComponent Tests', () {
    testWidgets('mounts and renders cups, emitters, and filters without throwing',
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

      // Verify clearCache static method executes cleanly
      LevelGeometryFlameComponent.clearCache();
    });
  });
}
