import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:micin_micin/screens/game/painters/background_painter.dart';
import 'package:micin_micin/screens/splash/splash_screen.dart';
import 'package:micin_micin/widgets/glass_container.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestWidget() {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/menu',
          builder: (context, state) => const Scaffold(
            body: Text('MenuScreen Arrived'),
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

  group('SplashScreen Zen Redesign Tests', () {
    testWidgets('renders emblem, title, subtitle, and background painters',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify title & subtitle
      expect(find.text('Micin, Micin'), findsOneWidget);
      expect(find.text('Teka-teki Garis & Butiran Gula'), findsOneWidget);
      expect(find.text('Sebuah Penghormatan untuk Sugar, Sugar'), findsOneWidget);

      // Verify Zen vessel icon and GlassContainer portal
      expect(find.byIcon(Icons.grain_rounded), findsOneWidget);
      expect(find.byType(GlassContainer), findsWidgets);

      // Verify BackgroundPainter exists
      final hasBackgroundPainter = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .any((cp) => cp.painter is BackgroundPainter);
      expect(hasBackgroundPainter, isTrue);
    });

    testWidgets('navigates to /menu when timer elapses',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Fast-forward past entrance animation & navigation timer (2.2s)
      await tester.pump(const Duration(milliseconds: 2300));
      await tester.pumpAndSettle();

      expect(find.text('MenuScreen Arrived'), findsOneWidget);
    });
  });
}
