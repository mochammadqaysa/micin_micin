import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/level_config.dart';

/// Repository responsible for loading and parsing level blueprints from asset bundles.
class LevelRepository {
  const LevelRepository();

  /// Loads the [LevelConfig] for a specified level [id].
  ///
  /// Reads from asset path `assets/levels/level_XX.json`.
  Future<LevelConfig> loadLevel(int id) async {
    final paddedId = id.toString().padLeft(2, '0');
    final path = 'assets/levels/level_$paddedId.json';
    final jsonStr = await rootBundle.loadString(path);
    final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
    return LevelConfig.fromJson(jsonMap);
  }
}
