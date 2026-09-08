import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/player_progress.dart';

/// Repository handling local progression persistence using [SharedPreferences].
///
/// Persists campaign unlock states under the key [kSharedPrefsKey] ('sugarshared').
/// NOTE: `saveBestScore` is intentionally excluded from v1.0 per CON-004.
class ProgressRepository {
  static const String _key = kSharedPrefsKey;

  const ProgressRepository();

  /// Loads the player's saved campaign progression.
  ///
  /// Returns [PlayerProgress.initial] if no saved record exists.
  Future<PlayerProgress> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null || jsonString.isEmpty) {
      return PlayerProgress.initial();
    }

    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return PlayerProgress.fromJson(jsonMap);
    } catch (_) {
      return PlayerProgress.initial();
    }
  }

  /// Persists the updated [PlayerProgress] state to storage.
  Future<void> save(PlayerProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(progress.toJson());
    await prefs.setString(_key, jsonString);
  }

  /// Unlocks level [id] and persists the updated progress.
  Future<PlayerProgress> unlockLevel(int id) async {
    final current = await load();
    final updated = current.withUnlocked(id);
    await save(updated);
    return updated;
  }

  /// Marks level [id] as completed and persists the updated progress.
  Future<PlayerProgress> markCompleted(int id) async {
    final current = await load();
    final updated = current.withCompleted(id);
    await save(updated);
    return updated;
  }
}
