import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:micin_micin/data/progress_repository.dart';
import 'package:micin_micin/models/cup_config.dart';
import 'package:micin_micin/models/emitter_config.dart';
import 'package:micin_micin/models/level_config.dart';
import 'package:micin_micin/models/player_progress.dart';
import 'package:micin_micin/providers/player_progress_provider.dart';
import 'package:micin_micin/screens/game/game_screen.dart';
import 'package:micin_micin/screens/level_select/level_button.dart';
import 'package:micin_micin/screens/level_select/level_select_screen.dart';
import 'package:micin_micin/screens/menu/menu_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testConfig = LevelConfig(
    id: 1,
    name: 'Level 1',
    totalSugar: 100,
    gravity: 0.2,
    hasGravityToggle: false,
    emitters: [
      EmitterConfig(x: 0.5, y: 0.05, rate: 3, totalToEmit: 100),
    ],
    cups: [
      CupConfig(x: 0.45, y: 0.85, width: 0.1, height: 0.08, targetAmount: 100),
    ],
  );

  Widget createTestApp({
    String initialLocation = '/menu',
    PlayerProgress? progress,
  }) {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/menu',
          builder: (context, state) => const MenuScreen(),
        ),
        GoRoute(
          path: '/levels',
          builder: (context, state) => const LevelSelectScreen(),
        ),
        GoRoute(
          path: '/game/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
            return GameScreen(
              levelId: id,
              levelConfig: id == 1 ? testConfig : null,
            );
          },
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

  group('Navigation Flow Tests (TASK-053)', () {
    testWidgets('(a) Tap PLAY from MenuScreen -> GameScreen terender langsung',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(initialLocation: '/menu'));
      await tester.pump();

      // Verify MenuScreen is visible — new arcade logo uses 'micin' (repeated)
      expect(find.text('micin'), findsWidgets);
      expect(find.text('PLAY'), findsOneWidget);

      // Tap the PLAY button — new behavior: goes directly to GameScreen
      await tester.tap(find.text('PLAY'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300)); // Allow route transition

      // PLAY navigates directly to GameScreen (not LevelSelectScreen)
      expect(find.byType(GameScreen), findsOneWidget);
    });

    testWidgets('(a2) Tap LEVELS from MenuScreen -> LevelSelectScreen terender',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(initialLocation: '/menu'));
      await tester.pump();

      expect(find.text('LEVELS'), findsOneWidget);

      await tester.tap(find.text('LEVELS'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Pilih Level'), findsOneWidget);
    });

    testWidgets('(b) Tap Level 1 -> GameScreen terender',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        initialLocation: '/levels',
        progress: PlayerProgress.initial(),
      ));
      await tester.pump();

      // Find and tap the unlocked Level 1 button
      final level1Button = find.widgetWithText(LevelButton, '1');
      expect(level1Button, findsOneWidget);

      await tester.tap(level1Button);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300)); // Allow transition

      // Verify GameScreen is rendered with Level 1 HUD (new badge: '01', no space)
      expect(find.byType(GameScreen), findsOneWidget);
      expect(find.text('01'), findsOneWidget);
    });

    testWidgets('(c) Tap Level 2 (terkunci) -> tetap di LevelSelectScreen tanpa SnackBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        initialLocation: '/levels',
        progress: PlayerProgress.initial(), // Level 2 is locked by default
      ));
      await tester.pump();

      // Find and tap locked Level 2 button
      final level2Button = find.widgetWithText(LevelButton, '2');
      expect(level2Button, findsOneWidget);

      await tester.tap(level2Button);
      await tester.pump();

      // Verify we stayed on LevelSelectScreen (did NOT navigate to GameScreen)
      expect(find.byType(GameScreen), findsNothing);
      expect(find.text('Pilih Level'), findsOneWidget);
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
