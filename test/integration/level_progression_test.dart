import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/core/constants.dart';
import 'package:micin_micin/data/level_repository.dart';
import 'package:micin_micin/models/level_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LevelProgression & 30-Level Asset Suite (TASK-402)', () {
    const repo = LevelRepository();

    test('all 30 levels load successfully from assets with native 400x700 virtual coordinates',
        () async {
      for (int i = 1; i <= kTotalLevels; i++) {
        final level = await repo.loadLevel(i);

        expect(level.id, equals(i), reason: 'Level $i has mismatched id');
        expect(level.canvasHeight, equals(kVirtualHeight),
            reason: 'Level $i canvasHeight must equal 700.0');
        expect(level.gravity, equals(kGravityDefault),
            reason: 'Level $i gravity must match calibrated kGravityDefault (0.14)');
        expect(level.totalSugar, greaterThan(0),
            reason: 'Level $i totalSugar must be positive');

        // Emitters validation
        expect(level.emitters, isNotEmpty,
            reason: 'Level $i must contain at least one emitter');
        for (final emitter in level.emitters) {
          expect(emitter.x, inInclusiveRange(0.0, kVirtualWidth),
              reason: 'Level $i emitter.x must be within [0, 400]');
          expect(emitter.y, inInclusiveRange(0.0, kVirtualHeight),
              reason: 'Level $i emitter.y must be within [0, 700]');
          expect(emitter.totalToEmit, greaterThan(0));
        }

        // Cups validation
        expect(level.cups, isNotEmpty,
            reason: 'Level $i must contain at least one cup');
        int cupTotalQuota = 0;
        for (final cup in level.cups) {
          expect(cup.x, inInclusiveRange(0.0, kVirtualWidth),
              reason: 'Level $i cup.x must be within [0, 400]');
          expect(cup.y, inInclusiveRange(0.0, kVirtualHeight),
              reason: 'Level $i cup.y must be within [0, 700]');
          expect(cup.width, greaterThan(0.0));
          expect(cup.height, greaterThan(0.0));
          expect(cup.targetAmount, greaterThan(0));
          cupTotalQuota += cup.targetAmount;
        }
        expect(level.totalSugar, equals(150 * level.cups.length),
            reason: 'Level $i totalSugar must equal 150 * cups.length (REQ-008, AC-007)');
        expect(cupTotalQuota, equals(100 * level.cups.length),
            reason: 'Level $i sum of cup target quotas must equal 100 * cups.length');

        // Emitters supply sum validation
        final emitterTotalSugar =
            level.emitters.fold<int>(0, (sum, e) => sum + e.totalToEmit);
        expect(emitterTotalSugar, equals(level.totalSugar),
            reason: 'Level $i sum of emitter supplies must equal totalSugar');

        // Filter gates validation (if present)
        for (final filter in level.filters) {
          expect(filter.x, inInclusiveRange(0.0, kVirtualWidth),
              reason: 'Level $i filter.x must be within [0, 400]');
          expect(filter.y, inInclusiveRange(0.0, kVirtualHeight),
              reason: 'Level $i filter.y must be within [0, 700]');
          expect(filter.width, greaterThan(0.0));
          expect(filter.height, greaterThan(0.0));
        }
      }
    });

    test('all 30 levels support JSON serialization round-trip without precision loss',
        () async {
      for (int i = 1; i <= kTotalLevels; i++) {
        final original = await repo.loadLevel(i);
        final json = original.toJson();
        final reconstructed = LevelConfig.fromJson(json);

        expect(reconstructed, equals(original),
            reason: 'Level $i must preserve exact equality after round-trip');
        expect(reconstructed.hashCode, equals(original.hashCode),
            reason: 'Level $i must preserve hashCode after round-trip');
      }
    });
  });
}
