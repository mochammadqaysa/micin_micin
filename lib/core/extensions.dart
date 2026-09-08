import 'package:flutter/material.dart';

/// Extension methods for [Color] manipulation and hex string conversion.
extension HexColor on Color {
  /// Parses a hex color string such as `#RRGGBB`, `#AARRGGBB`, `RRGGBB`, or `#RGB`.
  ///
  /// If the alpha channel is omitted, defaults to full opacity (0xFF).
  static Color fromHex(String hexString) {
    String cleanHex = hexString.replaceFirst('#', '').trim();

    // Handle short form #RGB -> #RRGGBB
    if (cleanHex.length == 3) {
      cleanHex = cleanHex.split('').map((c) => '$c$c').join();
    }

    if (cleanHex.length == 6) {
      cleanHex = 'FF$cleanHex';
    }

    final int? value = int.tryParse(cleanHex, radix: 16);
    if (value == null) {
      return Colors.white;
    }

    return Color(value);
  }

  /// Converts this [Color] to a hex string format (e.g. `#FFFFFFFF` or `#FFFFFF`).
  String toHex({bool leadingHash = true, bool includeAlpha = false}) {
    final alphaHex =
        (a * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase();
    final redHex =
        (r * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase();
    final greenHex =
        (g * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase();
    final blueHex =
        (b * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase();

    final buffer = StringBuffer();
    if (leadingHash) buffer.write('#');
    if (includeAlpha) buffer.write(alphaHex);
    buffer.write(redHex);
    buffer.write(greenHex);
    buffer.write(blueHex);
    return buffer.toString();
  }
}

/// Convenience extension on [String] to parse hex color easily.
extension HexColorString on String {
  /// Converts this hex string directly to a [Color].
  Color toColor() => HexColor.fromHex(this);
}
