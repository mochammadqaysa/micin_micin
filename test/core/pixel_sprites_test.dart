import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/core/pixel_sprites.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PixelSprites Tests', () {
    test('defines correct asset paths within registered subdirectories', () {
      expect(PixelSprites.cupPath, 'vessels/cup_pixel.png');
      expect(PixelSprites.emitterPath, 'emitters/emitter_pixel.png');
      expect(PixelSprites.filterPath, 'gates/filter_pixel.png');
      expect(PixelSprites.gravityPath, 'gates/gravity_pixel.png');
      expect(PixelSprites.terrainPath, 'terrain/terrain_pixel.png');
      expect(PixelSprites.emitterSheetPath, 'spritesheets/emitter_strip6.png');
      expect(PixelSprites.vortexSheetPath, 'spritesheets/vortex_strip6.png');
      expect(PixelSprites.cupSheetPath, 'spritesheets/cup_strip8.png');
      expect(PixelSprites.filterSheetPath, 'spritesheets/filter_strip6.png');
      expect(PixelSprites.zenLogoPath, 'spritesheets/zen_pixel_logo.png');
    });

    test('getters return null safely when cache is empty', () {
      PixelSprites.clear();
      expect(PixelSprites.isLoaded, isFalse);
      expect(PixelSprites.cup, isNull);
      expect(PixelSprites.emitter, isNull);
      expect(PixelSprites.filter, isNull);
      expect(PixelSprites.gravity, isNull);
      expect(PixelSprites.terrain, isNull);
      expect(PixelSprites.emitterSheet, isNull);
      expect(PixelSprites.vortexSheet, isNull);
      expect(PixelSprites.cupSheet, isNull);
      expect(PixelSprites.filterSheet, isNull);
      expect(PixelSprites.zenLogo, isNull);
    });

    test('loadAll executes gracefully in test environment without throwing', () async {
      PixelSprites.clear();
      await expectLater(PixelSprites.loadAll(), completes);
    });
  });
}
