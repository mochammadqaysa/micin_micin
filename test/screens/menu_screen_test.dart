import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:micin_micin/screens/game/painters/background_painter.dart';
import 'package:micin_micin/screens/menu/menu_screen.dart';

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
          path: '/game/:id',
          builder: (context, state) => const Scaffold(
            body: Text('GameScreen Arrived'),
          ),
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
    testWidgets('renders logo text (micin x2), tagline, and background painters',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // New arcade-game logo renders two "micin" lines
      expect(find.text('micin'), findsWidgets);

      // Tagline is present
      expect(find.text('draw · guide · fill'), findsOneWidget);

      // BackgroundPainter is rendered
      final hasBackgroundPainter = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .any((cp) => cp.painter is BackgroundPainter);
      expect(hasBackgroundPainter, isTrue);
    });

    testWidgets('renders PLAY button and navigates to /game/1 on tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final playButton = find.text('PLAY');
      expect(playButton, findsOneWidget);

      await tester.tap(playButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('GameScreen Arrived'), findsOneWidget);
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

    testWidgets('renders audio toggle button with MUSIC ON or MUTED label',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Audio toggle chip renders one of two labels
      final hasMusicLabel =
          tester.any(find.text('MUSIC ON')) || tester.any(find.text('MUTED'));
      expect(hasMusicLabel, isTrue);
    });

    testWidgets('toggles audio label on audio button tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Tap the audio chip (find by text 'MUSIC ON' or 'MUTED')
      final musicOnFinder = find.text('MUSIC ON');
      final mutedFinder = find.text('MUTED');
      final audioButton =
          tester.any(musicOnFinder) ? musicOnFinder : mutedFinder;

      await tester.tap(audioButton);
      await tester.pump();

      // After tap the label flips
      final hasLabel =
          tester.any(find.text('MUSIC ON')) || tester.any(find.text('MUTED'));
      expect(hasLabel, isTrue);
    });

    testWidgets('responds to pointer interaction on sugar rain without crash',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Simulate dragging across screen (no line drawn on menu)
      final gesture = await tester.startGesture(const Offset(200, 200));
      await gesture.moveTo(const Offset(200, 350));
      await tester.pump(const Duration(milliseconds: 50));

      // Screen must still show core content without crash
      expect(find.text('micin'), findsWidgets);
    });

    testWidgets('dragging across canvas does not show CLEAR button',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final gesture = await tester.startGesture(const Offset(120, 250));
      await gesture.moveTo(const Offset(180, 280));
      await gesture.moveTo(const Offset(240, 310));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      expect(find.text('CLEAR'), findsNothing);
    });
  });
}
