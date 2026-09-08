import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/core/game_state.dart';
import 'package:micin_micin/providers/game_state_provider.dart';

void main() {
  group('GameStateMachine', () {
    test('initial state is GameState.init', () {
      final machine = GameStateMachine();
      expect(machine.state, equals(GameState.init));
    });

    test('transitions cleanly between lifecycle states', () {
      final machine = GameStateMachine();

      machine.transition(GameState.menuLoop);
      expect(machine.state, equals(GameState.menuLoop));

      machine.onPlayPressed();
      expect(machine.state, equals(GameState.initLevelSelect));

      machine.onLevelSelected();
      expect(machine.state, equals(GameState.initLevel));

      machine.onLevelComplete();
      expect(machine.state, equals(GameState.levelSelectLoop));

      machine.onReset();
      expect(machine.state, equals(GameState.initLevel));

      machine.onBackToMenu();
      expect(machine.state, equals(GameState.menuLoop));
    });
  });
}
