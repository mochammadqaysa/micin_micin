import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/screens/level_select/level_button.dart';
import 'package:micin_micin/widgets/lock_badge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildButton({
    required int levelId,
    required bool isUnlocked,
    required bool isCompleted,
    required VoidCallback onTap,
    Color accentColor = const Color(0xFFFFD54F),
    bool isNextPlayable = false,
    bool isMilestone = false,
    String? milestoneLabel,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 80,
            height: 80,
            child: LevelButton(
              levelId: levelId,
              isUnlocked: isUnlocked,
              isCompleted: isCompleted,
              onTap: onTap,
              accentColor: accentColor,
              isNextPlayable: isNextPlayable,
              isMilestone: isMilestone,
              milestoneLabel: milestoneLabel,
            ),
          ),
        ),
      ),
    );
  }

  group('LevelButton Widget Tests', () {
    testWidgets('unlocked button renders levelId and triggers onTap',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(buildButton(
        levelId: 1,
        isUnlocked: true,
        isCompleted: false,
        onTap: () => tapped = true,
      ));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
      expect(find.byType(LockBadge), findsNothing);

      await tester.tap(find.byType(LevelButton));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('completed button renders completion accent',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildButton(
        levelId: 5,
        isUnlocked: true,
        isCompleted: true,
        onTap: () {},
        accentColor: const Color(0xFFFFD54F),
      ));
      await tester.pump();

      expect(find.text('5'), findsOneWidget);
      expect(find.byType(LockBadge), findsNothing);
    });

    testWidgets('locked button renders lock badge and micro-shakes on tap',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(buildButton(
        levelId: 2,
        isUnlocked: false,
        isCompleted: false,
        onTap: () => tapped = true,
      ));
      await tester.pump();

      expect(find.text('2'), findsOneWidget);
      expect(find.byType(LockBadge), findsOneWidget);

      // Tap locked node -> triggers shake animation and calls onTap callback
      await tester.tap(find.byType(LevelButton));
      await tester.pump();

      expect(tapped, isTrue);

      // Advance halfway through shake animation
      await tester.pump(const Duration(milliseconds: 150));
      // Finish animation
      await tester.pump(const Duration(milliseconds: 200));
    });

    testWidgets('milestone button renders milestoneLabel',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildButton(
        levelId: 10,
        isUnlocked: true,
        isCompleted: false,
        isMilestone: true,
        milestoneLabel: 'Prisma Harmoni',
        onTap: () {},
      ));
      await tester.pump();

      expect(find.text('10'), findsOneWidget);
      expect(find.text('Prisma Harmoni'), findsOneWidget);
    });

    testWidgets('nextPlayable button animates breathing pulse without errors',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildButton(
        levelId: 3,
        isUnlocked: true,
        isCompleted: false,
        isNextPlayable: true,
        onTap: () {},
      ));
      await tester.pump();

      // Pump through breathing cycle
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.text('3'), findsOneWidget);
    });
  });
}
