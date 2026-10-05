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
        transitionDuration: const Duration(milliseconds: 550),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final isReverse = animation.status == AnimationStatus.reverse;

          if (isReverse) {
            // Reverse (Select Level -> Menu): Preserved smoothly as user confirmed ("sudah sesuai")
            final curvedReverse = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutSine,
            );
            return FadeTransition(
              opacity: curvedReverse,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(curvedReverse),
                child: child,
              ),
            );
          } else {
            // Forward (Menu -> Select Level): Stitch Interactive Transition Spec
            // Holds LevelSelectScreen transparent during interval 0.0 -> 0.28 while
            // MenuScreen performs its title aperture expansion, guide dematerialize, and CTA morph.
            // Then smoothly scales from 0.92 to 1.0 and fades in (28% -> 100%).
            final forwardFade = CurvedAnimation(
              parent: animation,
              curve: const Interval(0.28, 1.0, curve: Curves.easeOutCubic),
            );
            final forwardScale = Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.28, 1.0, curve: Curves.easeOutCubic),
              ),
            );

            return FadeTransition(
              opacity: forwardFade,
              child: ScaleTransition(
                scale: forwardScale,
                child: child,
              ),
            );
          }
        },
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
