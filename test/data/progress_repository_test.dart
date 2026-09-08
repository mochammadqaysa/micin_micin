import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/data/progress_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProgressRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('load() returns PlayerProgress.initial() when storage is empty', () async {
      const repo = ProgressRepository();
      final progress = await repo.load();

      expect(progress.levels.length, equals(30));
      expect(progress.getLevel(1).isUnlocked, isTrue);
      expect(progress.getLevel(2).isUnlocked, isFalse);
    });

    test('unlockLevel(2) unlocks level 2 and persists state', () async {
      const repo = ProgressRepository();
      final updated = await repo.unlockLevel(2);

      expect(updated.getLevel(2).isUnlocked, isTrue);

      // Verify reloaded from repository matches
      final reloaded = await repo.load();
      expect(reloaded.getLevel(2).isUnlocked, isTrue);
      expect(reloaded.getLevel(3).isUnlocked, isFalse);
    });

    test('markCompleted(1) marks level 1 completed and persists state', () async {
      const repo = ProgressRepository();
      final updated = await repo.markCompleted(1);

      expect(updated.getLevel(1).isCompleted, isTrue);

      final reloaded = await repo.load();
      expect(reloaded.getLevel(1).isCompleted, isTrue);
    });
  });
}
