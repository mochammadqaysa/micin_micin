import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/screens/game/game_hud.dart';
import 'package:micin_micin/widgets/glass_container.dart';

void main() {
  group('GameHud Widget Tests (TASK-206)', () {
    testWidgets('renders level indicator in Mode B glass container and action keys',
        (WidgetTester tester) async {
      bool resetPressed = false;
      bool pausePressed = false;
      bool audioPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameHud(
              levelId: 7,
              onReset: () => resetPressed = true,
              onPause: () => pausePressed = true,
              onToggleMusic: () => audioPressed = true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('0 7'), findsOneWidget);
      expect(find.byKey(const Key('hud_reset')), findsOneWidget);
      expect(find.byKey(const Key('hud_pause')), findsOneWidget);
      expect(find.byKey(const Key('hud_audio')), findsOneWidget);

      // Verify Mode B: GlassContainer inside HUD has enableLiveBlur false
      final glassContainers = tester.widgetList<GlassContainer>(
        find.byType(GlassContainer),
      );
      expect(glassContainers.isNotEmpty, isTrue);
      for (final container in glassContainers) {
        expect(container.enableLiveBlur, isFalse);
      }

      await tester.tap(find.byKey(const Key('hud_reset')));
      expect(resetPressed, isTrue);

      await tester.tap(find.byKey(const Key('hud_pause')));
      expect(pausePressed, isTrue);

      await tester.tap(find.byKey(const Key('hud_audio')));
      expect(audioPressed, isTrue);
    });

    testWidgets('renders gravity toggle pill button when hasGravityToggle is true',
        (WidgetTester tester) async {
      bool gravityToggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameHud(
              levelId: 10,
              hasGravityToggle: true,
              onReset: () {},
              onPause: () {},
              onToggleGravity: () => gravityToggled = true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('hud_gravity')), findsOneWidget);
      expect(find.text('GRAVITY'), findsOneWidget);

      await tester.tap(find.byKey(const Key('hud_gravity')));
      expect(gravityToggled, isTrue);
    });
  });
}
