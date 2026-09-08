import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/level_repository.dart';
import '../models/level_config.dart';

/// Provider exposing the [LevelRepository] instance.
final levelRepositoryProvider = Provider<LevelRepository>((ref) {
  return const LevelRepository();
});

/// Family provider loading a specific [LevelConfig] asynchronously by level ID.
final levelConfigProvider =
    FutureProvider.family<LevelConfig, int>((ref, id) async {
  final repository = ref.watch(levelRepositoryProvider);
  return repository.loadLevel(id);
});
