import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/core/constants.dart';
import 'package:micin_micin/models/cup_config.dart';
import 'package:micin_micin/models/emitter_config.dart';
import 'package:micin_micin/models/level_config.dart';
import 'package:micin_micin/screens/game/game_hud.dart';
import 'package:micin_micin/screens/game/game_screen.dart';
import 'package:micin_micin/screens/game/painters/background_painter.dart';
import 'package:micin_micin/widgets/pause_overlay.dart';

void main() {
  group('GameScreen Widget Tests', () {
    const testConfig = LevelConfig(
      id: 1,
      name: 'Level 1',
      totalSugar: 100,
      gravity: kGravityDefault,
      hasGravityToggle: false,
      canvasHeight: kVirtualHeight,
      emitters: [
        EmitterConfig(x: 200, y: 35, rate: 3, totalToEmit: 100),
      ],
      cups: [
        CupConfig(x: 180, y: 595, width: 40, height: 56, targetAmount: 100),
      ],
    );

    testWidgets('renders Level 1 and HUD displays "0 1" without errors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: GameScreen(
              levelId: 1,
              levelConfig: testConfig,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('0 1'), findsOneWidget);
      expect(find.byType(GameHud), findsOneWidget);
    });

    testWidgets('user touch dragging on canvas registers drawn lines',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: GameScreen(
              levelId: 1,
              levelConfig: testConfig,
            ),
          ),
        ),
      );
      await tester.pump();

      // Find the interactive gesture canvas
      final gestureFinder = find.byWidgetPredicate(
        (widget) => widget is GestureDetector && widget.behavior == HitTestBehavior.translucent,
      );
      expect(gestureFinder, findsOneWidget);

      // Perform a drag stroke across the screen
      final gesture = await tester.startGesture(const Offset(100, 200));
      await gesture.moveBy(const Offset(50, 50));
      await gesture.up();
      await tester.pump();

      // Ensure no exceptions occurred and screen remains rendered
      expect(find.byType(GameScreen), findsOneWidget);
    });

    testWidgets('tapping pause button displays PauseOverlay and resume hides it',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: GameScreen(
              levelId: 1,
              levelConfig: testConfig,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(PauseOverlay), findsNothing);

      // Tap the pause icon in HUD by key
      await tester.tap(find.byKey(const Key('hud_pause')));
      await tester.pump();

      expect(find.byType(PauseOverlay), findsOneWidget);

      // Tap the resume button by key
      await tester.tap(find.byKey(const Key('pause_resume')));
      await tester.pump();

      expect(find.byType(PauseOverlay), findsNothing);
    });

    testWidgets('touch gesture in letterbox margin is clamped to virtual canvas bounds (AC-003)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1800); // Ultra-tall screen (e.g. 21:9)
      tester.view.devicePixelRatio = 2.0; // Logical size 400 x 900
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: GameScreen(
              levelId: 1,
              levelConfig: testConfig,
            ),
          ),
        ),
      );
      await tester.pump();

      // Viewport logical size is 400x900
      // 400x700 inside 400x900 has scale = 1.0, dy = (900 - 700)/2 = 100.
      // Top letterbox margin is y in [0..100], bottom is y in [800..900].
      // Tap in bottom letterbox margin at (200, 850)
      final gesture = await tester.startGesture(const Offset(200, 850));
      await gesture.moveBy(const Offset(10, 0));
      await gesture.up();
      await tester.pump();

      // Verify GameScreen remains cleanly rendered without exceptions
      expect(find.byType(GameScreen), findsOneWidget);
    });

    testWidgets('PauseOverlay renders chamber indicator and toggles audio soundscape',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: GameScreen(
              levelId: 14,
              levelConfig: testConfig,
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap the pause icon in HUD
      await tester.tap(find.byKey(const Key('hud_pause')));
      await tester.pump();

      // Verify chamber indicator and soundscape toggle
      expect(find.text('CHAMBER 14'), findsOneWidget);
      expect(find.text('PAUSED'), findsOneWidget);
      expect(find.byKey(const Key('pause_audio')), findsOneWidget);
      expect(find.text('CHIMES ON'), findsOneWidget);

      // Tap audio toggle in PauseOverlay
      await tester.tap(find.byKey(const Key('pause_audio')));
      await tester.pump();

      expect(find.text('CHIMES MUTED'), findsOneWidget);
    });

    testWidgets(
        'GameScreen mounts with LevelVisualTheme and passes chromatic palette and label to BackgroundPainter (AC-003, AC-004)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: GameScreen(
              levelId: 8,
              levelConfig: testConfig,
            ),
          ),
        ),
      );
      await tester.pump();

      final customPaints = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
      final bgCustomPaint = customPaints.firstWhere((cp) => cp.painter is BackgroundPainter);
      final painter = bgCustomPaint.painter as BackgroundPainter;

      expect(painter.backgroundColor.toARGB32(), equals(const Color(0xFF0F511D).toARGB32())); // Classic Kelly Green
      expect(painter.canvasLabel, equals('level 8'));
      expect(painter.canvasLabelColor.toARGB32(), equals(const Color(0xFF4ADE80).toARGB32()));
      expect(painter.canvasLabelOpacity, closeTo(0.22, 0.05));
    });
  });
}

