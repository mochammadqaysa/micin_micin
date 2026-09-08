import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/core/constants.dart';
import 'package:micin_micin/models/level_progress.dart';
import 'package:micin_micin/models/player_progress.dart';

void main() {
  group('LevelProgress', () {
    test('initializes with default flags', () {
      const progress = LevelProgress(levelId: 1);

      expect(progress.levelId, equals(1));
      expect(progress.isUnlocked, isFalse);
      expect(progress.isCompleted, isFalse);
    });

    test('copyWith() updates individual properties accurately', () {
      const original = LevelProgress(levelId: 5, isUnlocked: false, isCompleted: false);
      final unlocked = original.copyWith(isUnlocked: true);

      expect(unlocked.levelId, equals(5));
      expect(unlocked.isUnlocked, isTrue);
      expect(unlocked.isCompleted, isFalse);

      final completed = unlocked.copyWith(isCompleted: true);
      expect(completed.isCompleted, isTrue);
      expect(completed.isUnlocked, isTrue);
    });

    test('serializes to JSON and performs round-trip correctly', () {
      const original = LevelProgress(levelId: 12, isUnlocked: true, isCompleted: true);
      final json = original.toJson();

      expect(json, equals({
        'levelId': 12,
        'isUnlocked': true,
        'isCompleted': true,
      }));

      // Explicitly verify bestScore is NOT part of the serialized payload
      expect(json.containsKey('bestScore'), isFalse);

      final reconstructed = LevelProgress.fromJson(json);
      expect(reconstructed, equals(original));
      expect(reconstructed.hashCode, equals(original.hashCode));
    });
  });

  group('PlayerProgress', () {
    test('initial() creates exactly 30 levels with only Level 1 unlocked', () {
      final initial = PlayerProgress.initial();

      expect(initial.levels.length, equals(kTotalLevels));
      expect(initial.levels.length, equals(30));

      // Level 1 must be unlocked and not completed
      final level1 = initial.getLevel(1);
      expect(level1.levelId, equals(1));
      expect(level1.isUnlocked, isTrue);
      expect(level1.isCompleted, isFalse);

      // Levels 2 to 30 must all be locked and not completed
      for (int i = 2; i <= 30; i++) {
        final level = initial.getLevel(i);
        expect(level.levelId, equals(i));
        expect(level.isUnlocked, isFalse, reason: 'Level $i should be locked initially');
        expect(level.isCompleted, isFalse);
      }

      expect(initial.highestUnlockedLevel, equals(1));
    });

    test('withUnlocked() unlocks target level immutably without altering others', () {
      final initial = PlayerProgress.initial();
      final updated = initial.withUnlocked(2);

      expect(initial.getLevel(2).isUnlocked, isFalse); // Immutability check
      expect(updated.getLevel(2).isUnlocked, isTrue);
      expect(updated.getLevel(3).isUnlocked, isFalse);
      expect(updated.highestUnlockedLevel, equals(2));
    });

    test('withCompleted() marks target level completed immutably', () {
      final initial = PlayerProgress.initial();
      final updated = initial.withCompleted(1);

      expect(initial.getLevel(1).isCompleted, isFalse);
      expect(updated.getLevel(1).isCompleted, isTrue);
      expect(updated.getLevel(2).isCompleted, isFalse);
    });

    test('serializes to JSON and performs round-trip correctly', () {
      final progress = PlayerProgress.initial()
          .withCompleted(1)
          .withUnlocked(2)
          .withCompleted(2)
          .withUnlocked(3);

      final json = progress.toJson();
      final reconstructed = PlayerProgress.fromJson(json);

      expect(reconstructed, equals(progress));
      expect(reconstructed.highestUnlockedLevel, equals(3));
      expect(reconstructed.getLevel(1).isCompleted, isTrue);
      expect(reconstructed.getLevel(2).isCompleted, isTrue);
      expect(reconstructed.getLevel(3).isCompleted, isFalse);
      expect(reconstructed.getLevel(3).isUnlocked, isTrue);
    });

    test('fromJson() with empty or null levels falls back to initial()', () {
      final emptyJson = <String, dynamic>{'levels': []};
      final parsed = PlayerProgress.fromJson(emptyJson);

      expect(parsed.levels.length, equals(30));
      expect(parsed.getLevel(1).isUnlocked, isTrue);
      expect(parsed.getLevel(2).isUnlocked, isFalse);
    });
  });
}
