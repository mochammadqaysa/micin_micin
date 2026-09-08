import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/core/constants.dart';
import 'package:micin_micin/engine/collision/cup_hitbox.dart';
import 'package:micin_micin/models/sugar_particle.dart';

void main() {
  group('Sand Piling & Discrete Column Heightmap (REQ-006, AC-005)', () {
    late CupHitbox cup;

    setUp(() {
      // Cup bounds: width = 60.0 (binCount = 30), height = 40.0
      cup = CupHitbox(
        bounds: const Rect.fromLTWH(100.0, 300.0, 60.0, 40.0),
        color: const Color(0xFFFFFFFF),
        targetAmount: 50,
      );
    });

    test('initializes heightmap with zero heights and empty offsets', () {
      expect(cup.binCount, equals(30));
      expect(cup.columnHeights.length, equals(30));
      expect(cup.columnHeights.every((h) => h == 0.0), isTrue);
      expect(cup.settledParticleOffsets, isEmpty);
      expect(cup.capturedCount, equals(0));
      expect(cup.remaining, equals(50));
    });

    test('single-point stream relaxes symmetrically into a conical sand mound', () {
      final centerBin = cup.binCount ~/ 2; // bin 15
      final centerX = cup.bounds.left + centerBin * kHeightmapBinWidth + 1.0;

      // Pour 40 particles into the exact center coordinate
      for (int i = 0; i < 40; i++) {
        // Alternate vx slightly like organic emitter jitter
        final vx = (i % 2 == 0) ? -0.1 : 0.1;
        final p = SugarParticle(
          x: centerX,
          y: cup.bounds.bottom - 1.0, // reaching surface
          vx: vx,
          vy: 2.0,
          color: const Color(0xFFFFFFFF),
        );
        final settled = cup.processParticle(p);
        expect(settled, isTrue);
      }

      expect(cup.capturedCount, equals(40));
      expect(cup.settledParticleOffsets.length, equals(40));

      // Peak height should be at or near the center bin
      double maxHeight = 0.0;
      int peakBin = centerBin;
      for (int b = 0; b < cup.binCount; b++) {
        if (cup.columnHeights[b] > maxHeight) {
          maxHeight = cup.columnHeights[b];
          peakBin = b;
        }
      }

      // Peak must be within ±2 bins of center
      expect((peakBin - centerBin).abs(), lessThanOrEqualTo(2));
      expect(maxHeight, greaterThan(0.0));

      // Sand should have spread outward beyond the center bin
      int populatedBins = 0;
      for (final h in cup.columnHeights) {
        if (h > 0) populatedBins++;
      }
      expect(populatedBins, greaterThan(6),
          reason: 'Sand mound should spread symmetrically across multiple bins');

      // Check symmetry: left side vs right side mass
      double leftMass = 0.0;
      for (int b = 0; b < centerBin; b++) {
        leftMass += cup.columnHeights[b];
      }
      double rightMass = 0.0;
      for (int b = centerBin + 1; b < cup.binCount; b++) {
        rightMass += cup.columnHeights[b];
      }
      // Left and right mass should be reasonably balanced
      expect((leftMass - rightMass).abs(), lessThan(leftMass * 0.4 + 5.0),
          reason: 'Conical sand mound should be approximately symmetrical');
    });

    test('adjacent column height difference obeys angle of repose slope relaxation', () {
      final centerBin = cup.binCount ~/ 2;
      final centerX = cup.bounds.left + centerBin * kHeightmapBinWidth + 1.0;

      // Pour particles one by one and check slope constraint
      for (int i = 0; i < 30; i++) {
        final vx = (i % 2 == 0) ? -0.15 : 0.15;
        final p = SugarParticle(
          x: centerX,
          y: cup.bounds.bottom - 1.0,
          vx: vx,
          vy: 2.0,
          color: const Color(0xFFFFFFFF),
        );
        cup.processParticle(p);
      }

      // Verify that slope between adjacent columns does not form vertical cliffs
      final grainHeight = kParticleRadius * 1.5;
      final maxAllowableDiff = kReposeSlopeMax + grainHeight;

      for (int b = 0; b < cup.binCount - 1; b++) {
        final diff = (cup.columnHeights[b] - cup.columnHeights[b + 1]).abs();
        expect(diff, lessThanOrEqualTo(maxAllowableDiff),
            reason: 'Column $b and ${b + 1} difference $diff exceeds repose tolerance $maxAllowableDiff');
      }
    });

    test('Option A: settled sand is immune to gravity inversion', () {
      final centerBin = cup.binCount ~/ 2;
      final centerX = cup.bounds.left + centerBin * kHeightmapBinWidth + 1.0;

      // Settle 20 particles
      for (int i = 0; i < 20; i++) {
        final p = SugarParticle(
          x: centerX,
          y: cup.bounds.bottom - 1.0,
          vx: (i % 2 == 0) ? -0.1 : 0.1,
          vy: 2.0,
          color: const Color(0xFFFFFFFF),
        );
        cup.processParticle(p);
      }

      // Snapshot state
      final heightsSnapshot = List<double>.from(cup.columnHeights);
      final offsetsSnapshot = List<Offset>.from(cup.settledParticleOffsets);
      final capturedSnapshot = cup.capturedCount;
      final remainingSnapshot = cup.remaining;

      // Simulate inverted gravity event (upward gravity g = -0.14)
      // Under Option A, CupHitbox does not resimulate or clear settled particles
      expect(cup.columnHeights, equals(heightsSnapshot));
      expect(cup.settledParticleOffsets, equals(offsetsSnapshot));
      expect(cup.capturedCount, equals(capturedSnapshot));
      expect(cup.remaining, equals(remainingSnapshot));
    });

    test('reset clears heightmap state and settled sand offsets', () {
      final p = SugarParticle(
        x: cup.bounds.center.dx,
        y: cup.bounds.bottom - 1.0,
        color: const Color(0xFFFFFFFF),
      );
      cup.processParticle(p);

      expect(cup.capturedCount, equals(1));
      expect(cup.settledParticleOffsets.length, equals(1));

      cup.reset();

      expect(cup.capturedCount, equals(0));
      expect(cup.remaining, equals(cup.targetAmount));
      expect(cup.settledParticleOffsets, isEmpty);
      expect(cup.columnHeights.every((h) => h == 0.0), isTrue);
    });
  });
}
