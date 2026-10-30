import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/widgets/victory_overlay.dart';

void main() {
  group('VictoryOverlay Widget Tests (TASK-013)', () {
    testWidgets('renders centered NEXT circular button (spr_buttonnext) and triggers onNext callback',
        (WidgetTester tester) async {
      bool nextTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VictoryOverlay(
              levelId: 1,
              isLastLevel: false,
              onNext: () => nextTapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Semantic keys
      expect(find.byKey(const Key('spr_buttonnext')), findsOneWidget);
      expect(find.byKey(const Key('victory_next_button')), findsOneWidget);
      expect(find.text('NEXT'), findsOneWidget);

      await tester.tap(find.byKey(const Key('spr_buttonnext')));
      await tester.pump();

      expect(nextTapped, isTrue);
    });

    testWidgets('renders FINISH on final level 30',
        (WidgetTester tester) async {
      bool finishTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VictoryOverlay(
              levelId: 30,
              isLastLevel: true,
              onNext: () => finishTapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('FINISH'), findsOneWidget);
      expect(find.text('NEXT'), findsNothing);

      await tester.tap(find.byKey(const Key('spr_buttonnext')));
      await tester.pump();

      expect(finishTapped, isTrue);
    });
  });
}

