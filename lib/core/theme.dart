import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Cartoonish Casual Mobile Game Design System Tokens for Micin Micin.
///
/// Features bold, playful candy colors, 3D extruded button slabs,
/// specular gloss highlights, golden victory ribbons, and tactile bouncy UI.
abstract final class CartoonTokens {
  // Canvas & Background (Vibrant Midnight Indigo Gradient)
  static const Color canvasTop = Color(0xFF1E1645);
  static const Color canvasBottom = Color(0xFF110C29);
  static const Color canvasLight = Color(0xFF2C2263);

  // Panels & Containers
  static const Color panelBg = Color(0xFF241C52);
  static const Color panelBorder = Color(0xFF45368E);
  static const Color panelCreamBg = Color(0xFFFFF9E8);
  static const Color panelCreamBorder = Color(0xFFE8C888);
  static const Color panelCreamHeader = Color(0xFFFDE68A);

  // Buttons - 3D Beveled Faces, Gloss, and Sunk Shadows
  // Green Button (PLAY / PRIMARY / NEXT)
  static const Color greenTop = Color(0xFF4ADE80);
  static const Color greenBottom = Color(0xFF16A34A);
  static const Color greenShadow = Color(0xFF15803D);

  // Amber / Gold Button (LEVELS / SECONDARY / STARS)
  static const Color amberTop = Color(0xFFFBBF24);
  static const Color amberBottom = Color(0xFFD97706);
  static const Color amberShadow = Color(0xFFB45309);

  // Blue / Cyan Button (INFO / RESET / UTILITY)
  static const Color cyanTop = Color(0xFF38BDF8);
  static const Color cyanBottom = Color(0xFF0284C7);
  static const Color cyanShadow = Color(0xFF0369A1);

  // Red / Coral Button (CANCEL / PAUSE / DANGER)
  static const Color coralTop = Color(0xFFFB7185);
  static const Color coralBottom = Color(0xFFE11D48);
  static const Color coralShadow = Color(0xFFBE123C);

  // Aliases for intuitive palette access
  static const Color blueTop = cyanTop;
  static const Color blueBottom = cyanBottom;
  static const Color blueShadow = cyanShadow;
  static const Color redTop = coralTop;
  static const Color redBottom = coralBottom;
  static const Color redShadow = coralShadow;

  // Purple / Violet Button (MAGIC / GRAVITY / CREDITS)
  static const Color purpleTop = Color(0xFFC084FC);
  static const Color purpleBottom = Color(0xFF9333EA);
  static const Color purpleShadow = Color(0xFF7E22CE);

  // Star & Rating Accents
  static const Color starGold = Color(0xFFFFD700);
  static const Color starOrange = Color(0xFFFFA000);
  static const Color starEmpty = Color(0x40FFFFFF);

  // Gloss and Shadows
  static const Color glossWhite = Color(0x66FFFFFF);
  static const Color bevelDark = Color(0x4D000000);
  static const Color textShadow = Color(0x80000000);

  // Text
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textCream = Color(0xFFFFFBEB);
  static const Color textDarkBrown = Color(0xFF451A03);
  static const Color textMuted = Color(0xFF9CA3AF);
}

/// Pure Neumorphism (Soft UI) Design System Tokens for Micin Micin.
///
/// Implements authentic Neumorphism with dual directional lighting (135° Top-Left -> Bottom-Right),
/// extruded tactile convex elements, sunken debossed bays, and energetic mobile game accents.
abstract final class NeuTokens {
  // ---------------------------------------------------------------------------
  // Canvas & Surfaces (Titanium Clay / Slate Base)
  // ---------------------------------------------------------------------------
  /// The unifying canvas plane tone. In Neumorphism, all elements share this material base.
  static const Color canvas = Color(0xFF1E222A);

  /// Slightly elevated / illuminated surface stop (Top-Left of convex gradient).
  static const Color surfaceLight = Color(0xFF262C36);

  /// Standard flat surface plane tone.
  static const Color surfaceBase = Color(0xFF1E222A);

  /// Recessed / shaded surface stop (Bottom-Right of convex gradient).
  static const Color surfaceDark = Color(0xFF161920);

  // ---------------------------------------------------------------------------
  // Dual Cast Shadows (Directional Lighting @ 135°)
  // ---------------------------------------------------------------------------
  /// Light specular reflection cast upward and left (-dx, -dy).
  static const Color shadowLight = Color(0x24FFFFFF);

  /// Deep ambient drop shadow cast downward and right (+dx, +dy).
  static const Color shadowDark = Color(0xB8090B0E);

  // ---------------------------------------------------------------------------
  // Inner Inset Shadows (for Sunken / Debossed / Pressed States)
  // ---------------------------------------------------------------------------
  /// Deep inner groove shadow at top-left inside of sunken wells.
  static const Color insetDark = Color(0xD9080A0D);

  /// Subtle inner highlight reflection at bottom-right inside of sunken wells.
  static const Color insetLight = Color(0x1FFFFFFF);

  // ---------------------------------------------------------------------------
  // Specular Edge Bevel (1px Subtle Chamfer)
  // ---------------------------------------------------------------------------
  static const Color bevelLight = Color(0x2EFFFFFF);
  static const Color bevelDark = Color(0x1F000000);

  // ---------------------------------------------------------------------------
  // Energetic Play Store Game Accents
  // ---------------------------------------------------------------------------
  /// Primary Game Action CTA, Star Rating, and Victory Trophy Gold.
  static const Color accentAmber = Color(0xFFFFB300);
  static const Color accentAmberGlow = Color(0x66FFB300);

  /// High-energy secondary accent: Inverted gravity, dynamic tech gates.
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color accentCyanGlow = Color(0x6600E5FF);

  /// Vibrant completion & positive action emerald green.
  static const Color accentEmerald = Color(0xFF00E676);
  static const Color accentEmeraldGlow = Color(0x6600E676);

  /// Playful warm filter gate, powerup coral, danger accent.
  static const Color accentCoral = Color(0xFFFF5252);
  static const Color accentCoralGlow = Color(0x66FF5252);

  /// Royal purple challenge accent.
  static const Color accentPurple = Color(0xFFBD00FF);

  // ---------------------------------------------------------------------------
  // Typography & Content
  // ---------------------------------------------------------------------------
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textDark = Color(0xFF0F172A);

  // ---------------------------------------------------------------------------
  // Standard Geometric Radii
  // ---------------------------------------------------------------------------
  static const double radiusSmall = 10.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusPill = 999.0;

  // ---------------------------------------------------------------------------
  // Standard Shadow Elevation Depths
  // ---------------------------------------------------------------------------
  static const double depthCard = 8.0;
  static const double blurCard = 16.0;

  static const double depthButton = 5.0;
  static const double blurButton = 10.0;

  static const double depthChip = 3.0;
  static const double blurChip = 6.0;
}

/// Backwards-compatible bridge mapping legacy GlassTokens to NeuTokens.
abstract final class GlassTokens {
  static const Color obsidianVoid = NeuTokens.canvas;
  static const Color obsidianVignette = NeuTokens.surfaceDark;

  static const Color surfaceLight = NeuTokens.surfaceLight;
  static const Color surfaceSubtle = NeuTokens.surfaceBase;
  static const Color surfaceElevated = NeuTokens.surfaceLight;

  static const Color borderHighlight = NeuTokens.bevelLight;
  static const Color borderShadow = NeuTokens.bevelDark;
  static const Color borderActive = NeuTokens.accentCyan;

  static const Color neonCyan = NeuTokens.accentCyan;
  static const Color neonCyanGlow = NeuTokens.accentCyanGlow;
  static const Color neonRose = NeuTokens.accentCoral;
  static const Color radiantGold = NeuTokens.accentAmber;
  static const Color radiantGoldGlow = NeuTokens.accentAmberGlow;
  static const Color mintFlora = NeuTokens.accentEmerald;
  static const Color textSpecular = NeuTokens.textPrimary;
  static const Color textMuted = NeuTokens.textSecondary;
  static const Color textDim = NeuTokens.textMuted;

  static const double blurSubtle = 8.0;
  static const double blurLight = 12.0;
  static const double blurStandard = 18.0;
  static const double blurHeavy = 24.0;
  static const double blurOverlay = 24.0;

  static const double radiusSmall = NeuTokens.radiusSmall;
  static const double radiusMedium = NeuTokens.radiusMedium;
  static const double radiusLarge = NeuTokens.radiusLarge;
  static const double radiusPill = NeuTokens.radiusPill;
}

/// Backwards-compatible bridge for legacy ZenPalette references.
abstract final class ZenPalette {
  static const Color slateFloor = NeuTokens.canvas;
  static const Color basaltContainer = NeuTokens.surfaceDark;
  static const Color edgeVignette = NeuTokens.surfaceDark;
  static const Color pureWhite = NeuTokens.textPrimary;
  static const Color softAqua = NeuTokens.accentCyan;
  static const Color pastelRose = NeuTokens.accentCoral;
  static const Color mutedGold = NeuTokens.accentAmber;
  static const Color goldBloom = NeuTokens.accentAmber;
  static const Color sageGreen = NeuTokens.accentEmerald;
  static const double restingAlpha = 0.50;
  static const double activeAlpha = 1.0;
}

/// Design system and theme configurations for Micin Micin.
///
/// Features the Chunky Arcade theme with CartoonTokens, high-contrast
/// dark indigo canvas, and energetic candy mobile game accents.
class AppTheme {
  AppTheme._();

  static const Color background = NeuTokens.canvas;
  static const Color surface = NeuTokens.surfaceLight;
  static const Color primaryAccent = NeuTokens.accentAmber;
  static const Color secondaryAccent = NeuTokens.accentCyan;
  static const Color textPrimary = NeuTokens.textPrimary;
  static const Color textSecondary = NeuTokens.textSecondary;
  static const Color dividerColor = Color(0xFF262C36);

  static ThemeData get darkTheme {
    final baseTheme = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.outfitTextTheme(baseTheme.textTheme).copyWith(
      displayLarge: GoogleFonts.outfit(
        color: textPrimary,
        fontWeight: FontWeight.w800,
        fontSize: 32,
      ),
      displayMedium: GoogleFonts.outfit(
        color: textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 24,
      ),
      titleLarge: GoogleFonts.outfit(
        color: textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
      bodyLarge: GoogleFonts.outfit(
        color: textPrimary,
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.outfit(
        color: textSecondary,
        fontSize: 14,
      ),
      labelLarge: GoogleFonts.outfit(
        color: Colors.black,
        fontWeight: FontWeight.w800,
        fontSize: 16,
      ),
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: background,
      canvasColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primaryAccent,
        secondary: secondaryAccent,
        surface: surface,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: textPrimary,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: Colors.black,
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
