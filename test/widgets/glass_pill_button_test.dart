import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/core/theme.dart';
import 'package:micin_micin/widgets/glass_pill_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GlassPillButton Widget Tests (TASK-104)', () {
    testWidgets('renders label and optional icon cleanly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: GlassPillButton(
                icon: const Icon(Icons.play_arrow_rounded, key: Key('test_icon')),
                label: 'PLAY • ACT I',
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('PLAY • ACT I'), findsOneWidget);
      expect(find.byKey(const Key('test_icon')), findsOneWidget);
    });

    testWidgets('pointer press triggers squash and release triggers spring pop with onTap',
        (WidgetTester tester) async {
      bool tapped = false;
      bool soundPlayed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: GlassPillButton(
                label: 'TEST BUTTON',
                onTap: () => tapped = true,
                onPlaySound: () => soundPlayed = true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final buttonFinder = find.byType(GlassPillButton);
      final transformFinder = find.descendant(
        of: buttonFinder,
        matching: find.byType(Transform),
      );
      expect(transformFinder, findsOneWidget);

      // Verify resting scale is 1.0
      Transform transform = tester.widget<Transform>(transformFinder);
      expect(transform.transform.entry(0, 0), closeTo(1.0, 0.01));

      // Pointer down simulates press
      final gesture = await tester.press(buttonFinder);
      await tester.pump();

      // Verify pressed squash scale is 0.92
      transform = tester.widget<Transform>(transformFinder);
      expect(transform.transform.entry(0, 0), closeTo(0.92, 0.01));

      // Pointer up releases and triggers tap + sound
      await gesture.up();
      await tester.pump();

      expect(tapped, isTrue);
      expect(soundPlayed, isTrue);

      // Animate spring pop through overshoot (> 1.0)
      await tester.pump(const Duration(milliseconds: 130));
      transform = tester.widget<Transform>(transformFinder);
      expect(transform.transform.entry(0, 0), greaterThan(1.0));

      // Settle back to 1.0
      await tester.pump(const Duration(milliseconds: 150));
      transform = tester.widget<Transform>(transformFinder);
      expect(transform.transform.entry(0, 0), closeTo(1.0, 0.01));
    });

    testWidgets('isPrimary true applies luminous accent glow border',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: GlassPillButton(
                label: 'PRIMARY BUTTON',
                isPrimary: true,
                accentGlow: GlassTokens.neonCyan,
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('PRIMARY BUTTON'), findsOneWidget);
    });
  });
}
