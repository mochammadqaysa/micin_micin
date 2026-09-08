/// Progress tracking state for an individual level.
///
/// NOTE: `bestScore` is intentionally deferred to v1.1 per CON-004
/// and clarification report resolutions.
class LevelProgress {
  final int levelId;
  final bool isUnlocked;
  final bool isCompleted;

  const LevelProgress({
    required this.levelId,
    this.isUnlocked = false,
    this.isCompleted = false,
  });

  LevelProgress copyWith({
    bool? isUnlocked,
    bool? isCompleted,
  }) {
    return LevelProgress(
      levelId: levelId,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    return LevelProgress(
      levelId: (json['levelId'] as num).toInt(),
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'levelId': levelId,
        'isUnlocked': isUnlocked,
        'isCompleted': isCompleted,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LevelProgress &&
          runtimeType == other.runtimeType &&
          levelId == other.levelId &&
          isUnlocked == other.isUnlocked &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode => Object.hash(levelId, isUnlocked, isCompleted);

  @override
  String toString() =>
      'LevelProgress(levelId: $levelId, isUnlocked: $isUnlocked, isCompleted: $isCompleted)';
}
