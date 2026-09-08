import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/core/constants.dart';
import 'package:micin_micin/engine/collision/cup_hitbox.dart';
import 'package:micin_micin/engine/game_engine.dart';
import 'package:micin_micin/models/cup_config.dart';
import 'package:micin_micin/models/emitter_config.dart';
import 'package:micin_micin/models/level_config.dart';
import 'package:micin_micin/models/sugar_particle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Sand Piling & Overflow Spill Integration Tests (REQ-006, REQ-007, REQ-008)', () {
    test('full-stage pouring: countdown decrements to 0, mound piles, overflow spills over rims, and level completes', () {
      // 1. Setup level: 1 cup needing 20 particles, 35 particles total supply (150%+ quota)
      const level = LevelConfig(
        id: 101,
        name: 'Overflow & Mound Test',
        totalSugar: 35,
        gravity: kGravityDefault,
        canvasHeight: kVirtualHeight,
        emitters: [
          EmitterConfig(
            x: 200.0,
            y: 300.0,
            rate: 2,
            color: Color(0xFFFFFFFF),
            totalToEmit: 35,
          ),
        ],
        cups: [
          CupConfig(
            x: 180.0,
            y: 400.0,
            width: 40.0,
            height: 30.0,
            color: Color(0xFFFFFFFF),
            targetAmount: 20,
          ),
        ],
      );

      final engine = GameEngine(levelConfig: level);
      final cup = engine.cups.first;

      expect(cup.remaining, equals(20));
      expect(cup.isFull, isFalse);
      expect(engine.isLevelComplete, isFalse);

      // 2. Simulate frames until the cup captures all 20 target particles
      int frames = 0;
      while (cup.remaining > 0 && frames < 300) {
        engine.tickManual(const Duration(milliseconds: 16));
        frames++;
      }

      // Cup must be satisfied and countdown reached 0
      expect(cup.remaining, equals(0), reason: 'Cup remaining countdown must reach 0');
      expect(cup.isFull, isTrue, reason: 'Cup must be marked full');
      expect(engine.isLevelComplete, isTrue, reason: 'Stage must be marked complete once all cups are satisfied');

      // 3. Conical mound must have formed
      expect(cup.settledParticleOffsets.length, greaterThanOrEqualTo(20));
      int populatedBins = 0;
      double peakHeight = 0.0;
      for (final h in cup.columnHeights) {
        if (h > 0) populatedBins++;
        if (h > peakHeight) peakHeight = h;
      }
      expect(populatedBins, greaterThan(4), reason: 'Sand mound should have spread across bins');
      expect(peakHeight, greaterThan(0.0));

      // 4. Fill the entire cup to rim height to test Overflow Spill
      final centerBin = cup.binCount ~/ 2;
      cup.columnHeights.fillRange(0, cup.binCount, cup.bounds.height);

      // Drop an excess particle directly onto the full cup
      final excessParticle = SugarParticle(
        x: cup.bounds.left + centerBin * kHeightmapBinWidth + 1.0,
        y: cup.bounds.top + 2.0,
        vx: 0.0,
        vy: 2.0,
        color: const Color(0xFFFFFFFF),
        isActive: true,
      );

      final settled = cup.processParticle(excessParticle);

      // Excess particle must NOT settle (returns false) and must spill over rim
      expect(settled, isFalse, reason: 'Overloaded particle must not settle in full cup');
      expect(excessParticle.isCaptured, isFalse, reason: 'Spilled particle must remain active');
      expect(
        excessParticle.x < cup.bounds.left || excessParticle.x > cup.bounds.right,
        isTrue,
        reason: 'Spilled particle must be ejected outside cup rim',
      );
      expect(excessParticle.vy, greaterThan(0.0), reason: 'Spilled particle must have downward velocity');
      expect(excessParticle.vx.abs(), greaterThan(0.0), reason: 'Spilled particle must have horizontal ejection velocity');
    });

    test('cascading overflow: excess particles spilling from top cup cascade into lower cup', () {
      // Top cup at y = 200, lower cup at y = 350
      final topCup = CupHitbox(
        bounds: const Rect.fromLTWH(180.0, 200.0, 40.0, 30.0),
        color: const Color(0xFFFFFFFF),
        targetAmount: 5,
      );
      // Fill top cup completely to rim height
      topCup.columnHeights.fillRange(0, topCup.binCount, topCup.bounds.height);

      // Lower wide cup situated underneath top cup left rim
      final bottomCup = CupHitbox(
        bounds: const Rect.fromLTWH(150.0, 350.0, 60.0, 30.0),
        color: const Color(0xFFFFFFFF),
        targetAmount: 10,
      );

      // Particle enters top cup left bin and spills over left rim
      final particle = SugarParticle(
        x: topCup.bounds.left + 1.0,
        y: topCup.bounds.top + 5.0,
        vx: 0.0,
        vy: 2.0,
        color: const Color(0xFFFFFFFF),
        isActive: true,
      );

      final settledInTop = topCup.processParticle(particle);
      expect(settledInTop, isFalse, reason: 'Particle overflows top cup');
      expect(particle.x, lessThan(topCup.bounds.left), reason: 'Ejected over left rim');

      // Now particle falls down into the bottom cup
      particle.y = bottomCup.bounds.bottom - 1.0;
      final settledInBottom = bottomCup.processParticle(particle);
      expect(settledInBottom, isTrue, reason: 'Overflowed particle caught by lower cup');
      expect(bottomCup.capturedCount, equals(1));
      expect(bottomCup.remaining, equals(9));
    });
  });
}
