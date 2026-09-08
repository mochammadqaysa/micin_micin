import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import 'level_progress.dart';

/// Aggregated player campaign progression state.
///
/// Contains unlock and completion status for all 30 levels.
class PlayerProgress {
  final List<LevelProgress> levels;

  const PlayerProgress({required this.levels});

  /// Generates the initial campaign state with exactly 30 levels,
  /// where only Level 1 is unlocked and none are completed.
  factory PlayerProgress.initial() {
    return PlayerProgress(
      levels: List.generate(
        kTotalLevels,
        (index) => LevelProgress(
          levelId: index + 1,
          isUnlocked: index == 0,
          isCompleted: false,
        ),
      ),
    );
  }

  /// Returns a new [PlayerProgress] where level [id] is unlocked.
  PlayerProgress withUnlocked(int id) {
    return PlayerProgress(
      levels: levels.map((level) {
        if (level.levelId == id) {
          return level.copyWith(isUnlocked: true);
        }
        return level;
      }).toList(),
    );
  }

  /// Returns a new [PlayerProgress] where level [id] is marked as completed.
  PlayerProgress withCompleted(int id) {
    return PlayerProgress(
      levels: levels.map((level) {
        if (level.levelId == id) {
          return level.copyWith(isCompleted: true);
        }
        return level;
      }).toList(),
    );
  }

  /// Retrieves progress for a specific level ID.
  LevelProgress getLevel(int id) {
    return levels.firstWhere(
      (level) => level.levelId == id,
      orElse: () => LevelProgress(levelId: id),
    );
  }

  /// Convenience check whether level [id] is unlocked.
  bool isUnlocked(int id) => getLevel(id).isUnlocked;

  /// Convenience check whether level [id] has been completed.
  bool isCompleted(int id) => getLevel(id).isCompleted;

  /// Returns the number of levels currently completed.
  int get completedCount => levels.where((l) => l.isCompleted).length;

  /// Returns the highest level ID currently unlocked.
  int get highestUnlockedLevel {
    int highest = 1;
    for (final level in levels) {
      if (level.isUnlocked && level.levelId > highest) {
        highest = level.levelId;
      }
    }
    return highest;
  }

  factory PlayerProgress.fromJson(Map<String, dynamic> json) {
    final rawLevels = json['levels'] as List<dynamic>?;
    if (rawLevels == null || rawLevels.isEmpty) {
      return PlayerProgress.initial();
    }
    return PlayerProgress(
      levels: rawLevels
          .map((item) => LevelProgress.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'levels': levels.map((l) => l.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerProgress &&
          runtimeType == other.runtimeType &&
          listEquals(levels, other.levels);

  @override
  int get hashCode => Object.hashAll(levels);

  @override
  String toString() =>
      'PlayerProgress(levelsCount: ${levels.length}, highestUnlocked: $highestUnlockedLevel)';
}
