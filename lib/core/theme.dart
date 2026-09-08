import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design system and theme configurations for Micin Micin.
///
/// Features a minimalist dark theme with black canvas and amber/white accents,
/// using the bundled offline Outfit font family.
class AppTheme {
  AppTheme._();

  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color primaryAccent = Color(0xFFFFD54F); // Warm sugar yellow
  static const Color secondaryAccent = Colors.white;
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color dividerColor = Color(0xFF2C2C2C);

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
