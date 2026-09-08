import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/data/level_repository.dart';
import 'package:micin_micin/models/level_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LevelRepository', () {
    test('loads and parses level_01.json from asset bundle in native 400x700 coordinates', () async {
      const repo = LevelRepository();
      final level = await repo.loadLevel(1);

      expect(level.id, equals(1));
      expect(level.name, equals('The First Slope'));
      expect(level.totalSugar, equals(150));
      expect(level.canvasHeight, equals(700.0));
      expect(level.emitters.length, equals(1));
      expect(level.emitters.first.x, equals(100.0));
      expect(level.emitters.first.y, equals(60.0));
      expect(level.cups.length, equals(1));
      expect(level.cups.first.x, equals(280.0));
      expect(level.cups.first.y, equals(580.0));
      expect(level.cups.first.width, equals(40.0));
      expect(level.cups.first.height, equals(56.0));

      // Serialization round-trip
      final json = level.toJson();
      final reconstructed = LevelConfig.fromJson(json);
      expect(reconstructed, equals(level));
    });

    test('loads level_10.json accurately with Zen stage specifications', () async {
      const repo = LevelRepository();
      final level = await repo.loadLevel(10);

      expect(level.id, equals(10));
      expect(level.name, equals('Prism Terrace'));
      expect(level.canvasHeight, equals(700.0));
      expect(level.cups.first.width, equals(40.0));
      expect(level.cups.first.height, equals(56.0));
      expect(level.cups.first.x, equals(260.0));
      expect(level.cups.first.y, equals(560.0));
    });
  });
}
