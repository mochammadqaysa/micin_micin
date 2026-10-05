import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:micin_micin/data/progress_repository.dart';
import 'package:micin_micin/models/player_progress.dart';
import 'package:micin_micin/providers/player_progress_provider.dart';
import 'package:micin_micin/screens/game/painters/background_painter.dart';
import 'package:micin_micin/screens/level_select/level_button.dart';
import 'package:micin_micin/screens/level_select/level_select_screen.dart';
import 'package:micin_micin/widgets/glass_container.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestWidget({PlayerProgress? progress}) {
    final router = GoRouter(
      initialLocation: '/levels',
      routes: [
        GoRoute(
          path: '/levels',
          builder: (context, state) => const LevelSelectScreen(),
        ),
        GoRoute(
          path: '/game/:id',
          builder: (context, state) => Scaffold(
            body: Text('GameScreen ${state.pathParameters['id']}'),
          ),
        ),
        GoRoute(
          path: '/menu',
          builder: (context, state) => const Scaffold(
            body: Text('MenuScreen'),
          ),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        if (progress != null)
          playerProgressProvider.overrideWith(
            (ref) => _FakePlayerProgressNotifier(progress),
          ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('LevelSelectScreen Zen Bento Grid Tests', () {
    testWidgets('renders title, progress pill, and background parallax painter',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify borderless header title
      expect(find.text('Pilih Level'), findsOneWidget);

      // Verify total progress counter pill
      expect(find.text('0/30'), findsOneWidget);

      // Verify BackgroundPainter exists for optical depth
      expect(find.byType(CustomPaint), findsWidgets);
      final hasBackgroundPainter = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .any((cp) => cp.painter is BackgroundPainter);
      expect(hasBackgroundPainter, isTrue);
    });

    testWidgets('renders all 4 Act tabs in the quick-jump capsule navigator',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Babak I'), findsOneWidget);
      expect(find.text('Babak II'), findsOneWidget);
      expect(find.text('Babak III'), findsOneWidget);
      expect(find.text('Babak IV'), findsOneWidget);
    });

    testWidgets('renders Act I content and stages in Bento layout',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify Act I hero card title
      expect(find.text('BABAK I'), findsOneWidget);
      expect(find.text('Aliran Lembut & Curam'), findsOneWidget);

      // Verify Act I stages (1 to 7) exist as LevelButtons
      for (int i = 1; i <= 7; i++) {
        expect(find.widgetWithText(LevelButton, '$i'), findsOneWidget);
      }

      // Verify Act I milestone label
      expect(find.text('Taman Bebas I'), findsOneWidget);
    });

    testWidgets('tapping quick-jump tab triggers scrolling smoothly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Tap Babak IV tab
      await tester.tap(find.text('Babak IV'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600)); // Allow scroll animation

      // Verify Babak IV is now visible
      expect(find.text('BABAK IV'), findsOneWidget);
      expect(find.text('Taman Zen Agung'), findsOneWidget);
      expect(find.widgetWithText(LevelButton, '30'), findsOneWidget);
    });

    testWidgets('tapping back button navigates to menu',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Tap back button
      final backButton = find.byIcon(Icons.arrow_back_rounded);
      expect(backButton, findsOneWidget);

      await tester.tap(backButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('MenuScreen'), findsOneWidget);
    });

    testWidgets('renders GlassContainer components across header, tabs, and act cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify presence of GlassContainer widgets
      expect(find.byType(GlassContainer), findsWidgets);
    });

    testWidgets('tapping unlocked level 1 navigates to game screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Find and tap Level 1 button
      final level1 = find.widgetWithText(LevelButton, '1');
      expect(level1, findsOneWidget);

      await tester.tap(level1);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('GameScreen 1'), findsOneWidget);
    });

    testWidgets('tapping locked level 2 stays on screen without SnackBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Find and tap locked Level 2 button
      final level2 = find.widgetWithText(LevelButton, '2');
      expect(level2, findsOneWidget);

      await tester.tap(level2);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SnackBar), findsNothing);
      expect(find.text('Pilih Level'), findsOneWidget);
      expect(find.text('GameScreen 2'), findsNothing);
    });
  });
}

class _FakePlayerProgressNotifier extends PlayerProgressNotifier {
  _FakePlayerProgressNotifier(PlayerProgress progress)
      : super(const ProgressRepository()) {
    state = AsyncValue.data(progress);
  }

  @override
  Future<void> load() async {}
}
