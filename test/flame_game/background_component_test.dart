import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/flame_game/components/background_component.dart';

class _TestFlameGame extends FlameGame {
  final BackgroundFlameComponent bgComponent;
  _TestFlameGame(this.bgComponent);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(bgComponent);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BackgroundFlameComponent Tests (TASK-007, REQ-003, AC-003)', () {
    testWidgets('mounts and renders authentic flat solid background per stage theme',
        (WidgetTester tester) async {
      final bg = BackgroundFlameComponent(
        backgroundColor: const Color(0xFF076B07),
        canvasLabel: 'STAGE 01',
        canvasLabelColor: const Color(0xFF30D30B),
        canvasLabelOpacity: 0.25,
      );

      final game = _TestFlameGame(bg);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameWidget(game: game),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(bg.isMounted, isTrue);
      expect(bg.priority, -10);

      // Verify setParallax is safely callable and does not throw
      bg.setParallax(15.0, -10.0);
      await tester.pump(const Duration(milliseconds: 50));

      bg.setParallax(0.0, 0.0);
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('handles null or empty canvasLabel gracefully',
        (WidgetTester tester) async {
      final bg = BackgroundFlameComponent(
        backgroundColor: const Color(0xFF6B256B),
        canvasLabel: null,
        canvasLabelColor: Colors.transparent,
      );

      final game = _TestFlameGame(bg);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameWidget(game: game),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(bg.isMounted, isTrue);
    });
  });
}
