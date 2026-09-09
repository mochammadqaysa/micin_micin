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
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const MenuScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
    ),
    GoRoute(
      path: '/levels',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LevelSelectScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    ),
    GoRoute(
      path: '/credits',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const CreditsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
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
