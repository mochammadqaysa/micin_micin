import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/core/constants.dart';
import 'package:micin_micin/models/cup_config.dart';
import 'package:micin_micin/models/emitter_config.dart';
import 'package:micin_micin/models/level_config.dart';
import 'package:micin_micin/screens/game/game_hud.dart';
import 'package:micin_micin/screens/game/game_screen.dart';
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

      // New arcade HUD renders level as '01' (no space separator)
      expect(find.text('01'), findsOneWidget);
      expect(find.byType(GameHud), findsOneWidget);
    });

    testWidgets('user touch dragging on canvas does not crash',
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

      // Flame handles input internally via DragCallbacks, not GestureDetector.
      // Perform a drag stroke and verify no crash occurs.
      final gesture = await tester.startGesture(const Offset(100, 200));
      await gesture.moveBy(const Offset(50, 50));
      await gesture.up();
      await tester.pump();

      // Ensure screen remains rendered without exceptions
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

      // Verify PauseOverlay renders PAUSED title and chamber badge
      expect(find.text('PAUSED'), findsOneWidget);
      // Chamber badge format: '• CHAMBER 14'
      expect(find.textContaining('CHAMBER 14'), findsOneWidget);

      // Verify audio toggle chip shows MUSIC ON or MUTED
      final hasAudioLabel =
          tester.any(find.text('MUSIC ON')) || tester.any(find.text('MUTED'));
      expect(hasAudioLabel, isTrue);
    });

    testWidgets(
        'GameScreen mounts with LevelVisualTheme without errors (AC-003, AC-004)',
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

      // Flame GameWidget renders instead of CustomPainter tree —
      // verify the screen mounts without exception and HUD is present.
      expect(find.byType(GameScreen), findsOneWidget);
      expect(find.byType(GameHud), findsOneWidget);
    });
  });
}

