import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/progress_repository.dart';
import '../models/player_progress.dart';

/// Provider exposing the singleton [ProgressRepository].
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return const ProgressRepository();
});

/// Riverpod state notifier managing active player progress and unlock state.
class PlayerProgressNotifier extends StateNotifier<AsyncValue<PlayerProgress>> {
  final ProgressRepository _repository;

  PlayerProgressNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  /// Loads stored progress from local storage.
  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final progress = await _repository.load();
      state = AsyncValue.data(progress);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Unlocks level [id] and propagates state changes.
  Future<void> unlockLevel(int id) async {
    try {
      final updated = await _repository.unlockLevel(id);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Marks level [id] as completed and propagates state changes.
  Future<void> markCompleted(int id) async {
    try {
      final updated = await _repository.markCompleted(id);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Global provider for player progress state.
final playerProgressProvider =
    StateNotifierProvider<PlayerProgressNotifier, AsyncValue<PlayerProgress>>(
  (ref) => PlayerProgressNotifier(ref.watch(progressRepositoryProvider)),
);
