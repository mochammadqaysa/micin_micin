import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/game_state.dart';

/// State machine controller governing top-level game navigation and lifecycles.
class GameStateMachine extends StateNotifier<GameState> {
  GameStateMachine([super.initialState = GameState.init]);

  /// Transitions explicitly to the designated [next] state.
  void transition(GameState next) {
    state = next;
  }

  /// Triggered when the user taps 'PLAY' from the main menu.
  void onPlayPressed() => transition(GameState.initLevelSelect);

  /// Triggered when a level button is selected.
  void onLevelSelected() => transition(GameState.initLevel);

  /// Triggered when a level is successfully solved.
  void onLevelComplete() => transition(GameState.levelSelectLoop);

  /// Triggered when resetting the current board.
  void onReset() => transition(GameState.initLevel);

  /// Triggered when navigating back to the main menu.
  void onBackToMenu() => transition(GameState.menuLoop);
}

/// Global Riverpod provider exposing the [GameStateMachine].
final gameStateMachineProvider =
    StateNotifierProvider<GameStateMachine, GameState>(
  (ref) => GameStateMachine(),
);
