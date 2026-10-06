import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:micin_micin/screens/game/painters/background_painter.dart';
import 'package:micin_micin/screens/menu/menu_screen.dart';
import 'package:micin_micin/widgets/glass_container.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestWidget() {
    final router = GoRouter(
      initialLocation: '/menu',
      routes: [
        GoRoute(
          path: '/menu',
          builder: (context, state) => const MenuScreen(),
        ),
        GoRoute(
          path: '/levels',
          builder: (context, state) => const Scaffold(
            body: Text('LevelSelectScreen Arrived'),
          ),
        ),
        GoRoute(
          path: '/credits',
          builder: (context, state) => const Scaffold(
            body: Text('CreditsScreen Arrived'),
          ),
        ),
      ],
    );

    return ProviderScope(
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('MenuScreen Zen Redesign Tests', () {
    testWidgets('renders brand emblem, title, and background painters',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Micin, Micin'), findsOneWidget);
      expect(find.text('Teka-teki Garis & Butiran Gula'), findsOneWidget);
      expect(find.byIcon(Icons.grain_rounded), findsOneWidget);
      expect(find.byType(GlassContainer), findsWidgets);

      final hasBackgroundPainter = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .any((cp) => cp.painter is BackgroundPainter);
      expect(hasBackgroundPainter, isTrue);
    });

    testWidgets('renders PLAY button under logo and navigates to /levels on tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify PLAY button exists
      final playButton = find.text('PLAY');
      expect(playButton, findsOneWidget);

      // Tap PLAY button
      await tester.tap(playButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500)); // Allow route transition

      expect(find.text('LevelSelectScreen Arrived'), findsOneWidget);
    });

    testWidgets('renders LEVELS button and navigates to /levels on tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final levelsButton = find.text('LEVELS');
      expect(levelsButton, findsOneWidget);

      await tester.tap(levelsButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('LevelSelectScreen Arrived'), findsOneWidget);
    });

    testWidgets('renders CREDITS button and navigates to /credits on tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final creditsButton = find.text('CREDITS');
      expect(creditsButton, findsOneWidget);

      await tester.tap(creditsButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('CreditsScreen Arrived'), findsOneWidget);
    });

    testWidgets('renders Campaign Progress snapshot status',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.textContaining('Level Selesai'), findsOneWidget);
    });

    testWidgets('toggles audio on music icon button tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final musicButton = find.byIcon(Icons.music_note_rounded);
      expect(musicButton, findsOneWidget);

      await tester.tap(musicButton);
      await tester.pump();

      expect(find.byIcon(Icons.music_off_rounded), findsOneWidget);
    });

    testWidgets('responds to pointer interaction on living sugar stream without crash',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Simulate dragging across screen to deflect sugar motes
      final gesture = await tester.startGesture(const Offset(200, 200));
      await gesture.moveTo(const Offset(200, 350));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Micin, Micin'), findsOneWidget);
    });

    testWidgets('dragging across canvas does not draw lines or show CLEAR button',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Drag across the canvas
      final gesture = await tester.startGesture(const Offset(120, 250));
      await gesture.moveTo(const Offset(180, 280));
      await gesture.moveTo(const Offset(240, 310));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      // No CLEAR button appears
      expect(find.text('CLEAR'), findsNothing);

      // Verify no LinePainter exists in MenuScreen
      final hasLinePainter = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .any((cp) => cp.painter?.runtimeType.toString() == 'LinePainter');
      expect(hasLinePainter, isFalse);
    });
  });
}
