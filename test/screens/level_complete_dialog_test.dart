import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/widgets/level_complete_dialog.dart';

void main() {
  group('LevelCompleteDialog Widget Tests (TASK-050)', () {
    testWidgets('renders Level 1 completion dialog with Next Level button',
        (WidgetTester tester) async {
      bool nextLevelTapped = false;
      bool replayTapped = false;
      bool menuTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LevelCompleteDialog(
              levelId: 1,
              onNextLevel: () => nextLevelTapped = true,
              onReplay: () => replayTapped = true,
              onMenu: () => menuTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Level 1 Selesai!'), findsOneWidget);
      expect(find.text('Level Berikutnya'), findsOneWidget);
      expect(find.text('Ulangi'), findsOneWidget);
      expect(find.text('Level'), findsOneWidget);

      await tester.tap(find.text('Level Berikutnya'));
      expect(nextLevelTapped, isTrue);

      await tester.tap(find.text('Ulangi'));
      expect(replayTapped, isTrue);

      await tester.tap(find.text('Level'));
      expect(menuTapped, isTrue);
    });

    testWidgets('renders final Level 30 completion celebration ending screen',
        (WidgetTester tester) async {
      bool menuTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LevelCompleteDialog(
              levelId: 30,
              onReplay: () {},
              onMenu: () => menuTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Selamat!'), findsOneWidget);
      expect(find.text('Semua 30 level telah berhasil Anda selesaikan!'), findsOneWidget);
      expect(find.text('Kembali ke Menu'), findsOneWidget);
      expect(find.text('Level Berikutnya'), findsNothing);

      await tester.tap(find.text('Kembali ke Menu'));
      expect(menuTapped, isTrue);
    });
  });
}
