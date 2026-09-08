import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme.dart';
import 'models/level_config.dart';
import 'screens/game/game_screen.dart';

import 'screens/level_select/level_select_screen.dart';
import 'screens/menu/credits_screen.dart';
import 'screens/menu/menu_screen.dart';
import 'screens/splash/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/menu',
      builder: (context, state) => const MenuScreen(),
    ),
    GoRoute(
      path: '/levels',
      builder: (context, state) => const LevelSelectScreen(),
    ),
    GoRoute(
      path: '/credits',
      builder: (context, state) => const CreditsScreen(),
    ),
    GoRoute(
      path: '/game/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
        final config = state.extra as LevelConfig?;
        return GameScreen(levelId: id, levelConfig: config);
      },
    ),
  ],
);

/// Root application widget configuring routing and design system theme.
class MicinApp extends StatelessWidget {
  const MicinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Micin, Micin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
