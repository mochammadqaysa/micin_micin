import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/widgets/glass_container.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GlassContainer Widget Tests (TASK-104)', () {
    testWidgets('renders child content inside RepaintBoundary', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: GlassContainer(
                child: Text('Glass Content'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Glass Content'), findsOneWidget);
      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    testWidgets('Mode A: enableLiveBlur true instantiates BackdropFilter with blurSigma',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: GlassContainer(
                enableLiveBlur: true,
                blurSigma: 18.0,
                child: Text('Mode A'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final backdropFinder = find.byType(BackdropFilter);
      expect(backdropFinder, findsOneWidget);

      final backdropWidget = tester.widget<BackdropFilter>(backdropFinder);
      expect(backdropWidget.filter, ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0));
    });

    testWidgets('Mode B: enableLiveBlur false omits BackdropFilter for performance',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: GlassContainer(
                enableLiveBlur: false,
                child: Text('Mode B'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(BackdropFilter), findsNothing);
      expect(find.text('Mode B'), findsOneWidget);
    });

    testWidgets('supports BoxShape.circle with ClipOval', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: GlassContainer(
                shape: BoxShape.circle,
                enableLiveBlur: true,
                child: SizedBox(width: 50, height: 50),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ClipOval), findsOneWidget);
    });

    testWidgets('renders custom border gradient and margins cleanly',
        (WidgetTester tester) async {
      const customGradient = LinearGradient(
        colors: [Colors.cyan, Colors.blue],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: GlassContainer(
                borderGradient: customGradient,
                borderWidth: 2.0,
                margin: EdgeInsets.all(12),
                child: Text('Custom Border'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Custom Border'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
