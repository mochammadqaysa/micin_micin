import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/core/pixel_terrain_tokens.dart';
import 'package:pixel_ui/pixel_ui.dart';

void main() {
  group('PixelTerrainTokens Tests', () {
    test('defines non-null core terrain palettes (Sage, Teal, Moss, Sand, Slate)', () {
      // Sage
      expect(PixelTerrainTokens.sageLight, const Color(0xFFA3B899));
      expect(PixelTerrainTokens.sage, const Color(0xFF7A9A7B));
      expect(PixelTerrainTokens.sageDark, const Color(0xFF567257));

      // Teal
      expect(PixelTerrainTokens.tealCaustic, const Color(0xFF8CE3D0));
      expect(PixelTerrainTokens.tealSurface, const Color(0xFF52B79A));
      expect(PixelTerrainTokens.tealMid, const Color(0xFF398C81));
      expect(PixelTerrainTokens.tealDeep, const Color(0xFF1E3F3B));

      // Moss
      expect(PixelTerrainTokens.mossLight, const Color(0xFF5A9451));
      expect(PixelTerrainTokens.moss, const Color(0xFF437A48));
      expect(PixelTerrainTokens.mossDark, const Color(0xFF376332));

      // Sand
      expect(PixelTerrainTokens.sandLight, const Color(0xFFFAF6E8));
      expect(PixelTerrainTokens.sand, const Color(0xFFE8DFCC));
      expect(PixelTerrainTokens.sandDark, const Color(0xFFD2C4A7));

      // Slate
      expect(PixelTerrainTokens.slateLight, const Color(0xFF37474F));
      expect(PixelTerrainTokens.slate, const Color(0xFF263238));
      expect(PixelTerrainTokens.slateDark, const Color(0xFF151B24));
      expect(PixelTerrainTokens.slateBedrock, const Color(0xFF0F141C));

      // Accents
      expect(PixelTerrainTokens.goldAccent, const Color(0xFFE5A93C));
      expect(PixelTerrainTokens.vermilionAccent, const Color(0xFFD9383A));
      expect(PixelTerrainTokens.indigoAccent, const Color(0xFF2A3D66));
      expect(PixelTerrainTokens.cyanGlow, const Color(0xFF00E5FF));
    });

    test('configures valid PixelShapeStyles with corners, borders, and shadows', () {
      // Badge Style
      expect(PixelTerrainTokens.badgeStyle.corners, PixelCorners.xs);
      expect(PixelTerrainTokens.badgeStyle.fillColor, PixelTerrainTokens.sandLight);
      expect(PixelTerrainTokens.badgeStyle.borderColor, PixelTerrainTokens.slate);
      expect(PixelTerrainTokens.badgeStyle.borderWidth, 1);
      expect(PixelTerrainTokens.badgeStyle.shadow, isNotNull);

      // Washi Box Style with texture
      expect(PixelTerrainTokens.washiBoxStyle.corners, PixelCorners.sm);
      expect(PixelTerrainTokens.washiBoxStyle.texture, isNotNull);
      expect(PixelTerrainTokens.washiBoxStyle.texture?.color, PixelTerrainTokens.sandDark);

      // Button styles
      expect(PixelTerrainTokens.audioButtonNormal.fillColor, PixelTerrainTokens.indigoAccent);
      expect(PixelTerrainTokens.resetButtonNormal.fillColor, PixelTerrainTokens.vermilionAccent);
      expect(PixelTerrainTokens.pauseButtonNormal.fillColor, PixelTerrainTokens.slate);
      expect(PixelTerrainTokens.gravityButtonNormal.fillColor, const Color(0xFF5B21B6));
      expect(PixelTerrainTokens.gravityButtonNormal.borderColor, PixelTerrainTokens.cyanGlow);
    });
  });
}
