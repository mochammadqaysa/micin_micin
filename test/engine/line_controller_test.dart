import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/engine/drawing/line_controller.dart';

void main() {
  group('LineController', () {
    late LineController controller;

  setUp(() {
    controller = LineController();
  });

  test('initial state has zero lines and empty allSegments', () {
    expect(controller.lines, isEmpty);
    expect(controller.allSegments, isEmpty);
  });

  test('onPanStart and onPanUpdate construct line stroke and segments', () {
    controller.onPanStart(const Offset(10, 10));
    expect(controller.lines.length, equals(1));
    expect(controller.lines.first.points.length, equals(1));
    // Single point produces zero segments
    expect(controller.allSegments, isEmpty);

    controller.onPanUpdate(const Offset(50, 50));
    expect(controller.lines.first.points.length, equals(2));
    expect(controller.allSegments.length, equals(1));
    expect(controller.allSegments.first.start, equals(const Offset(10, 10)));
    expect(controller.allSegments.first.end, equals(const Offset(50, 50)));
  });

  test('caches allSegments across repeated getter calls without state changes (PRN-002)', () {
    controller.onPanStart(const Offset(0, 0));
    controller.onPanUpdate(const Offset(100, 100));
    controller.onPanEnd();

    final segments1 = controller.allSegments;
    final segments2 = controller.allSegments;

    // Both calls must return the identical cached List instance
    expect(identical(segments1, segments2), isTrue);
    expect(segments1.length, equals(1));
  });

  test('invalidates allSegments cache on onPanStart, onPanUpdate, and clearAll', () {
    controller.onPanStart(const Offset(0, 0));
    controller.onPanUpdate(const Offset(10, 10));
    final initialSegments = controller.allSegments;
    expect(initialSegments.length, equals(1));

    // Update line -> cache must invalidate
    controller.onPanUpdate(const Offset(20, 20));
    final updatedSegments = controller.allSegments;
    expect(identical(initialSegments, updatedSegments), isFalse);
    expect(updatedSegments.length, equals(2));

    // Start new line -> cache must invalidate
    controller.onPanEnd();
    controller.onPanStart(const Offset(50, 50));
    final newStrokeSegments = controller.allSegments;
    expect(identical(updatedSegments, newStrokeSegments), isFalse);

    // Clear all -> cache must invalidate to empty
    controller.clearAll();
    expect(controller.allSegments, isEmpty);
  });
  });
}
