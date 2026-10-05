import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Canonical Zen Mineral Palette tokens for Micin Micin.
/// Derived from the approved art direction brief and Stitch Zen Granular Minimalist design system.
abstract final class ZenPalette {
  /// Base canvas field tone: Deep matte charcoal slate.
  static const Color slateFloor = Color(0xFF13171C);

  /// Elevated inert basalt geometry: cup bodies and deflectors.
  static const Color basaltContainer = Color(0xFF191F26);

  /// Subtle radial vignette darkened screen edge.
  static const Color edgeVignette = Color(0xFF101418);

  /// Unfiltered crystalline grains, player guide strokes, and critical counters.
  static const Color pureWhite = Color(0xFFFFFFFF);

  /// Primary chromatic filter gate and calming cooling dynamic.
  static const Color softAqua = Color(0xFF70C1B3);

  /// Resonant warm chromatic filter gate and dyed mineral stream.
  static const Color pastelRose = Color(0xFFF4A7B9);

  /// High-density grains, inverted gravity vectors, and completion highlights.
  static const Color mutedGold = Color(0xFFE8C547);

  /// Radiant gold bloom wash for victory state.
  static const Color goldBloom = Color(0xFFFFD54F);

  /// Viscous flow modifiers and kinetic deflection bumpers.
  static const Color sageGreen = Color(0xFF95B8A2);

  /// Unfocused / resting HUD glyph alpha (0.35 - 0.40).
  static const double restingAlpha = 0.35;

  /// Active HUD glyph interaction alpha.
  static const double activeAlpha = 0.90;
}

/// Canonical Modern Minimalist & Glassmorphism Design Tokens for Micin Micin.
/// Derived from spec-design-modern-glassmorphism-ui.md.
abstract final class GlassTokens {
  // Base Canvas & Void
  static const Color obsidianVoid = Color(0xFF0B0E14);
  static const Color obsidianVignette = Color(0xFF06080C);

  // Frosted Glass Surfaces (Translucency)
  static const Color surfaceLight = Color(0x14FFFFFF);    // 8% white
  static const Color surfaceSubtle = Color(0x0AFFFFFF);   // 4% white
  static const Color surfaceElevated = Color(0x1FFFFFFF); // 12% white

  // Glass Specular Borders (1px Gradient)
  static const Color borderHighlight = Color(0x3DFFFFFF); // 24% white (Top-Left)
  static const Color borderShadow = Color(0x0DFFFFFF);    // 5% white (Bottom-Right)
  static const Color borderActive = Color(0x6600F2FE);    // Neon Cyan glow border

  // Refractive Neon Accents
  static const Color neonCyan = Color(0xFF00F2FE);
  static const Color neonCyanGlow = Color(0x4D00F2FE);
  static const Color neonRose = Color(0xFFFF6584);
  static const Color radiantGold = Color(0xFFFFD200);
  static const Color radiantGoldGlow = Color(0x66FFD200);
  static const Color mintFlora = Color(0xFF4EECD5);
  static const Color textSpecular = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF8E9AA8);
  static const Color textDim = Color(0xFF64748B);

  // Standard Glass Blur Radii
  static const double blurSubtle = 8.0;
  static const double blurLight = 12.0;
  static const double blurStandard = 18.0;
  static const double blurHeavy = 24.0;
  static const double blurOverlay = 24.0;

  // Corner Radii
  static const double radiusSmall = 10.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusPill = 999.0;
}

/// Design system and theme configurations for Micin Micin.
///
/// Features a Modern Minimalist & Glassmorphism dark theme with obsidian void canvas,
/// frosted glass containers, and refractive neon accents, using the bundled offline Outfit font family.
class AppTheme {
  AppTheme._();

  static const Color background = GlassTokens.obsidianVoid;
  static const Color surface = GlassTokens.surfaceElevated;
  static const Color primaryAccent = GlassTokens.radiantGold;
  static const Color secondaryAccent = GlassTokens.neonCyan;
  static const Color textPrimary = GlassTokens.textSpecular;
  static const Color textSecondary = GlassTokens.textMuted;
  static const Color dividerColor = Color(0xFF1E2630);


  static ThemeData get darkTheme {
    final baseTheme = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.outfitTextTheme(baseTheme.textTheme).copyWith(
      displayLarge: GoogleFonts.outfit(
        color: textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 32,
      ),
      displayMedium: GoogleFonts.outfit(
        color: textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      titleLarge: GoogleFonts.outfit(
        color: textPrimary,
        fontWeight: FontWeight.w600,
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
        fontWeight: FontWeight.bold,
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
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
