import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/core/constants.dart';
import 'package:micin_micin/engine/drawing/virtual_coordinate_adapter.dart';

void main() {
  group('VirtualCoordinateAdapter Tests', () {
    test('computeScale calculates correct scale for exact 4:7 aspect ratio', () {
      const viewport = Size(800, 1400); // exactly 2x
      final scale = VirtualCoordinateAdapter.computeScale(viewport);
      expect(scale, equals(2.0));

      final offset = VirtualCoordinateAdapter.computeOffset(viewport, scale);
      expect(offset.dx, equals(0.0));
      expect(offset.dy, equals(0.0));
    });

    test('computes letterbox offsets for taller screens (e.g., 19.5:9 or 400x900)', () {
      const viewport = Size(400, 900); // taller than 4:7
      final scale = VirtualCoordinateAdapter.computeScale(viewport);
      expect(scale, equals(1.0)); // width-constrained

      final offset = VirtualCoordinateAdapter.computeOffset(viewport, scale);
      expect(offset.dx, equals(0.0));
      expect(offset.dy, equals(100.0)); // (900 - 700) / 2 = 100
    });

    test('computes pillarbox offsets for wider screens (e.g., tablet 800x700)', () {
      const viewport = Size(800, 700); // wider than 4:7
      final scale = VirtualCoordinateAdapter.computeScale(viewport);
      expect(scale, equals(1.0)); // height-constrained

      final offset = VirtualCoordinateAdapter.computeOffset(viewport, scale);
      expect(offset.dx, equals(200.0)); // (800 - 400) / 2 = 200
      expect(offset.dy, equals(0.0));
    });

    test('screenToVirtual transforms screen touch accurately and performs round-trip', () {
      const viewport = Size(1080, 1920); // 9:16 mobile
      final scale = VirtualCoordinateAdapter.computeScale(viewport);
      final offset = VirtualCoordinateAdapter.computeOffset(viewport, scale);

      // Virtual center is (200, 350)
      const virtualCenter = Offset(200, 350);
      final screenCenter = VirtualCoordinateAdapter.virtualToScreen(virtualCenter, viewport);

      expect(screenCenter.dx, closeTo(200 * scale + offset.dx, 0.001));
      expect(screenCenter.dy, closeTo(350 * scale + offset.dy, 0.001));

      // Reverse transform
      final backToVirtual = VirtualCoordinateAdapter.screenToVirtual(screenCenter, viewport);
      expect(backToVirtual.dx, closeTo(virtualCenter.dx, 0.001));
      expect(backToVirtual.dy, closeTo(virtualCenter.dy, 0.001));
    });

    test('screenToVirtual clamps touches in letterbox margins to valid bounds', () {
      const viewport = Size(400, 900); // vertical letterbox dy = 100

      // Touch above canvas in top letterbox
      final topTouch = VirtualCoordinateAdapter.screenToVirtual(const Offset(200, 20), viewport);
      expect(topTouch.dx, equals(200.0));
      expect(topTouch.dy, equals(0.0)); // clamped to 0.0

      // Touch below canvas in bottom letterbox
      final bottomTouch = VirtualCoordinateAdapter.screenToVirtual(const Offset(200, 880), viewport);
      expect(bottomTouch.dx, equals(200.0));
      expect(bottomTouch.dy, equals(kVirtualHeight)); // clamped to 700.0
    });

    test('screenToVirtual clamps touches in horizontal pillar margins', () {
      const viewport = Size(800, 700); // horizontal pillarbox dx = 200

      // Touch in left pillar
      final leftTouch = VirtualCoordinateAdapter.screenToVirtual(const Offset(50, 350), viewport);
      expect(leftTouch.dx, equals(0.0)); // clamped to 0.0
      expect(leftTouch.dy, equals(350.0));

      // Touch in right pillar
      final rightTouch = VirtualCoordinateAdapter.screenToVirtual(const Offset(750, 350), viewport);
      expect(rightTouch.dx, equals(kVirtualWidth)); // clamped to 400.0
      expect(rightTouch.dy, equals(350.0));
    });

    test('handles degenerate zero or negative viewport sizes gracefully', () {
      const zeroViewport = Size.zero;
      final scale = VirtualCoordinateAdapter.computeScale(zeroViewport);
      expect(scale, equals(1.0));

      final point = VirtualCoordinateAdapter.screenToVirtual(const Offset(10, 10), zeroViewport);
      expect(point.dx, inInclusiveRange(0.0, kVirtualWidth));
      expect(point.dy, inInclusiveRange(0.0, kVirtualHeight));
    });
  });
}
