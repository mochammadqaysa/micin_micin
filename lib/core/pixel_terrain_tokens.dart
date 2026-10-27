import 'package:flutter/widgets.dart';
import 'package:pixel_ui/pixel_ui.dart';

/// Semantic color palette and pixel shape styles for the Pixel Terrain & Texture overhaul.
///
/// Features an earthy, organic zen topography aesthetic:
/// - Sage: Muted organic foliage and highland vegetation.
/// - Teal: Tiered water pools, caustics, and mineral basins.
/// - Moss: Deep shaded embankments and verdant soil.
/// - Sand: Weathered sedimentary shelves, riverbanks, and washi paper surfaces.
/// - Slate: Hard rock outcroppings, contour shadows, and boundary lines.
abstract final class PixelTerrainTokens {
  // ── 1. Sage Palette (Foliage & Highland Mute) ──────────────────────────────
  static const Color sageLight = Color(0xFFA3B899);
  static const Color sage = Color(0xFF7A9A7B);
  static const Color sageDark = Color(0xFF567257);

  // ── 2. Teal Palette (Aquatic Pools & Caustics) ─────────────────────────────
  static const Color tealCaustic = Color(0xFF8CE3D0);
  static const Color tealSurface = Color(0xFF52B79A);
  static const Color tealMid = Color(0xFF398C81);
  static const Color tealDeep = Color(0xFF1E3F3B);
  static const Color teal = tealSurface;

  // ── 3. Moss Palette (Vegetation & Moist Banks) ─────────────────────────────
  static const Color mossLight = Color(0xFF5A9451);
  static const Color moss = Color(0xFF437A48);
  static const Color mossDark = Color(0xFF376332);

  // ── 4. Sand Palette (Sedimentary Shelves & Paper) ──────────────────────────
  static const Color sandLight = Color(0xFFFAF6E8);
  static const Color sand = Color(0xFFE8DFCC);
  static const Color sandDark = Color(0xFFD2C4A7);

  // ── 5. Slate Palette (Bedrock, Shadows & Outlines) ─────────────────────────
  static const Color slateLight = Color(0xFF37474F);
  static const Color slate = Color(0xFF263238);
  static const Color slateDark = Color(0xFF151B24);
  static const Color slateBedrock = Color(0xFF0F141C);

  // ── 6. UI Accent Tokens ───────────────────────────────────────────────────
  static const Color goldAccent = Color(0xFFE5A93C);
  static const Color goldLight = Color(0xFFFFD166);
  static const Color vermilionAccent = Color(0xFFD9383A);
  static const Color vermilionDark = Color(0xFF8F1E20);
  static const Color indigoAccent = Color(0xFF2A3D66);
  static const Color indigoDark = Color(0xFF1B2844);
  static const Color cyanGlow = Color(0xFF00E5FF);

  // ── 7. PixelShapeStyles for UI Elements ───────────────────────────────────

  /// Badge container style (Level indicator, info chips).
  static const PixelShapeStyle badgeStyle = PixelShapeStyle(
    corners: PixelCorners.xs,
    fillColor: sandLight,
    borderColor: slate,
    borderWidth: 1,
    shadow: PixelShadow(
      offset: Offset(1, 1),
      color: slateDark,
    ),
  );

  /// Standard Washi Paper container with fine stippling texture.
  static const PixelShapeStyle washiBoxStyle = PixelShapeStyle(
    corners: PixelCorners.sm,
    fillColor: sandLight,
    borderColor: sand,
    borderWidth: 1,
    shadow: PixelShadow(
      offset: Offset(2, 2),
      color: slateDark,
    ),
    texture: PixelTexture(
      color: sandDark,
      density: 0.12,
      seed: 108,
    ),
  );

  /// Bedrock / Slate container style for dark panels or modals.
  static const PixelShapeStyle bedrockBoxStyle = PixelShapeStyle(
    corners: PixelCorners.sm,
    fillColor: slate,
    borderColor: slateLight,
    borderWidth: 1,
    shadow: PixelShadow(
      offset: Offset(2, 2),
      color: slateBedrock,
    ),
  );

  /// Teal panel style for dialogs and hero containers.
  static const PixelShapeStyle tealBoxStyle = PixelShapeStyle(
    corners: PixelCorners.sm,
    fillColor: tealSurface,
    borderColor: sage,
    borderWidth: 1,
    shadow: PixelShadow(
      offset: Offset(2, 2),
      color: slateBedrock,
    ),
  );

  /// Moss container style for victory plaques or active acts.
  static const PixelShapeStyle mossBoxStyle = PixelShapeStyle(
    corners: PixelCorners.sm,
    fillColor: moss,
    borderColor: sand,
    borderWidth: 1,
    shadow: PixelShadow(
      offset: Offset(2, 2),
      color: slateBedrock,
    ),
  );

  /// Sand container style for completed levels and milestone cards.
  static const PixelShapeStyle sandBoxStyle = PixelShapeStyle(
    corners: PixelCorners.sm,
    fillColor: sand,
    borderColor: sage,
    borderWidth: 1,
    shadow: PixelShadow(
      offset: Offset(2, 2),
      color: slateBedrock,
    ),
  );

  /// Slate container style for locked levels and dim plaques.
  static const PixelShapeStyle slateBoxStyle = PixelShapeStyle(
    corners: PixelCorners.sharp,
    fillColor: slate,
    borderColor: slateLight,
    borderWidth: 1,
  );

  // Button styles: Audio
  static const PixelShapeStyle audioButtonNormal = PixelShapeStyle(
    corners: PixelCorners.xs,
    fillColor: indigoAccent,
    borderColor: slateDark,
    borderWidth: 1,
    shadow: PixelShadow(
      offset: Offset(1, 1),
      color: slateBedrock,
    ),
  );

  static const PixelShapeStyle audioButtonPressed = PixelShapeStyle(
    corners: PixelCorners.xs,
    fillColor: indigoDark,
    borderColor: slateDark,
    borderWidth: 1,
  );

  // Button styles: Reset
  static const PixelShapeStyle resetButtonNormal = PixelShapeStyle(
    corners: PixelCorners.xs,
    fillColor: vermilionAccent,
    borderColor: slateDark,
    borderWidth: 1,
    shadow: PixelShadow(
      offset: Offset(1, 1),
      color: slateBedrock,
    ),
  );

  static const PixelShapeStyle resetButtonPressed = PixelShapeStyle(
    corners: PixelCorners.xs,
    fillColor: vermilionDark,
    borderColor: slateDark,
    borderWidth: 1,
  );

  // Button styles: Pause
  static const PixelShapeStyle pauseButtonNormal = PixelShapeStyle(
    corners: PixelCorners.xs,
    fillColor: slate,
    borderColor: slateLight,
    borderWidth: 1,
    shadow: PixelShadow(
      offset: Offset(1, 1),
      color: slateBedrock,
    ),
  );

  static const PixelShapeStyle pauseButtonPressed = PixelShapeStyle(
    corners: PixelCorners.xs,
    fillColor: slateBedrock,
    borderColor: slateDark,
    borderWidth: 1,
  );

  // Button styles: Gravity
  static const PixelShapeStyle gravityButtonNormal = PixelShapeStyle(
    corners: PixelCorners.sm,
    fillColor: Color(0xFF5B21B6),
    borderColor: cyanGlow,
    borderWidth: 1,
    shadow: PixelShadow(
      offset: Offset(1, 1),
      color: slateBedrock,
    ),
  );

  static const PixelShapeStyle gravityButtonPressed = PixelShapeStyle(
    corners: PixelCorners.sm,
    fillColor: Color(0xFF3B0764),
    borderColor: cyanGlow,
    borderWidth: 1,
  );

  // Button styles: Play / Next Level (Hero)
  static const PixelShapeStyle playButtonNormal = PixelShapeStyle(
    corners: PixelCorners.sm,
    fillColor: moss,
    borderColor: sageLight,
    borderWidth: 1,
    shadow: PixelShadow(
      offset: Offset(2, 2),
      color: slateBedrock,
    ),
  );

  static const PixelShapeStyle playButtonPressed = PixelShapeStyle(
    corners: PixelCorners.sm,
    fillColor: mossDark,
    borderColor: sageLight,
    borderWidth: 1,
  );

  // Button styles: Action / Menu Secondary
  static const PixelShapeStyle actionButtonNormal = PixelShapeStyle(
    corners: PixelCorners.xs,
    fillColor: tealSurface,
    borderColor: sageLight,
    borderWidth: 1,
    shadow: PixelShadow(
      offset: Offset(1, 1),
      color: slateBedrock,
    ),
  );

  static const PixelShapeStyle actionButtonPressed = PixelShapeStyle(
    corners: PixelCorners.xs,
    fillColor: tealDeep,
    borderColor: sageLight,
    borderWidth: 1,
  );
}
