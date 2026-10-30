import 'package:flutter/material.dart';

/// Authentic color palettes extracted 1:1 from decompiled Sugar, Sugar (Flash SWF) bytecode.
///
/// In Bart Bonte's engine, stage colors are defined by:
/// - `backkleur`: solid canvas backdrop color (`screenBmp`, `screenSprite`)
/// - `tekenkleur`: player drawn barrier line color (`lineStyle`)
/// - `balk*`: obstacle beam colors (`balkgroen`, `balkroze`, `balkrood`, `balkblauw`, `balkoranje`)
/// - `accent`: contrast highlight color for UI counters and accents
class StageVisualTheme {
  final Color backgroundColor;
  final Color obstacleColor;
  final Color lineColor;
  final Color accentColor;

  const StageVisualTheme({
    required this.backgroundColor,
    required this.obstacleColor,
    required this.lineColor,
    required this.accentColor,
  });

  // ── Core Archetype Palettes (from decompiled ActionScript) ───────────────────

  /// Green archetype (backkleur 486151 = #076B07, tekenkleur 3199755 = #30D30B, balkgroen #30D30B)
  static const StageVisualTheme green = StageVisualTheme(
    backgroundColor: Color(0xFF076B07),
    obstacleColor: Color(0xFF30D30B),
    lineColor: Color(0xFF30D30B),
    accentColor: Color(0xFFFFFFFF),
  );

  /// Magenta archetype (backkleur 7021931 = #6B256B, tekenkleur 16711919 = #FF00EF, balkroze #FF00EF)
  static const StageVisualTheme magenta = StageVisualTheme(
    backgroundColor: Color(0xFF6B256B),
    obstacleColor: Color(0xFFFF00EF),
    lineColor: Color(0xFFFF00EF),
    accentColor: Color(0xFFFFFFFF),
  );

  /// Crimson archetype (backkleur 7012389 = #6B0025, tekenkleur 16711714 = #FF0022, balkrood #FF0021)
  static const StageVisualTheme crimson = StageVisualTheme(
    backgroundColor: Color(0xFF6B0025),
    obstacleColor: Color(0xFFFF0021),
    lineColor: Color(0xFFFF0022),
    accentColor: Color(0xFFFFFFFF),
  );

  /// Blue archetype (backkleur 476523 = #07456B, tekenkleur 8047341 = #7ACAED, balkblauw #7ACAED)
  static const StageVisualTheme blue = StageVisualTheme(
    backgroundColor: Color(0xFF07456B),
    obstacleColor: Color(0xFF7ACAED),
    lineColor: Color(0xFF7ACAED),
    accentColor: Color(0xFFFFFFFF),
  );

  /// Orange archetype (backkleur 7021831 = #6B2507, tekenkleur 16010764 = #F44E0C, balkoranje #F44E0C)
  static const StageVisualTheme orange = StageVisualTheme(
    backgroundColor: Color(0xFF6B2507),
    obstacleColor: Color(0xFFF44E0C),
    lineColor: Color(0xFFF44E0C),
    accentColor: Color(0xFFFFFFFF),
  );

  /// Menu archetype (backkleur 476523 = #07456B with teal and white accents)
  static const StageVisualTheme menu = StageVisualTheme(
    backgroundColor: Color(0xFF07456B),
    obstacleColor: Color(0xFF00ADB5),
    lineColor: Color(0xFFEEEEEE),
    accentColor: Color(0xFFF38181),
  );

  // ── Stage-Specific Constants ──────────────────────────────────────────────

  static const StageVisualTheme stage1 = green;
  static const StageVisualTheme stage2 = magenta;
  static const StageVisualTheme stage3 = crimson;
  static const StageVisualTheme stage4 = green;
  static const StageVisualTheme stage5 = magenta;
  static const StageVisualTheme stage6 = blue;
  static const StageVisualTheme stage7 = crimson;
  static const StageVisualTheme stage8 = green;
  static const StageVisualTheme stage9 = orange;
  static const StageVisualTheme stage10 = magenta;
  static const StageVisualTheme stage11 = blue;
  static const StageVisualTheme stage12 = crimson;
  static const StageVisualTheme stage13 = magenta;
  static const StageVisualTheme stage14 = green;
  static const StageVisualTheme stage15 = crimson;
  static const StageVisualTheme stage16 = blue;
  static const StageVisualTheme stage17 = magenta;
  static const StageVisualTheme stage18 = crimson;
  static const StageVisualTheme stage19 = blue;
  static const StageVisualTheme stage20 = green;
  static const StageVisualTheme stage21 = magenta;
  static const StageVisualTheme stage22 = blue;
  static const StageVisualTheme stage23 = crimson;
  static const StageVisualTheme stage24 = blue;
  static const StageVisualTheme stage25 = magenta;
  static const StageVisualTheme stage26 = blue;
  static const StageVisualTheme stage27 = green;
  static const StageVisualTheme stage28 = blue;
  static const StageVisualTheme stage29 = magenta;
  static const StageVisualTheme stage30 = crimson;

  // ── 30-Stage Matrix ───────────────────────────────────────────────────────

  static const Map<int, StageVisualTheme> stageThemes = {
    1: stage1,
    2: stage2,
    3: stage3,
    4: stage4,
    5: stage5,
    6: stage6,
    7: stage7,
    8: stage8,
    9: stage9,
    10: stage10,
    11: stage11,
    12: stage12,
    13: stage13,
    14: stage14,
    15: stage15,
    16: stage16,
    17: stage17,
    18: stage18,
    19: stage19,
    20: stage20,
    21: stage21,
    22: stage22,
    23: stage23,
    24: stage24,
    25: stage25,
    26: stage26,
    27: stage27,
    28: stage28,
    29: stage29,
    30: stage30,
  };

  /// Resolves the authentic [StageVisualTheme] for any given stage ID (1..30).
  /// Falls back to [stage1] (Pine Green) for unknown stage IDs.
  static StageVisualTheme forLevel(int levelId) {
    return stageThemes[levelId] ?? stage1;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StageVisualTheme &&
          runtimeType == other.runtimeType &&
          backgroundColor == other.backgroundColor &&
          obstacleColor == other.obstacleColor &&
          lineColor == other.lineColor &&
          accentColor == other.accentColor;

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        obstacleColor,
        lineColor,
        accentColor,
      );
}

