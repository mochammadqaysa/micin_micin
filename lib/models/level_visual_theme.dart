import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'silhouette_prop_config.dart';

/// Bespoke visual profile and diegetic canvas theme for each of the 30 stages (REQ-003, AC-003).
class LevelVisualTheme {
  final int levelId;
  final String stageLabel; // e.g. "level 8", "sugar, sugar"
  final Color backgroundColor;
  final Color canvasLabelColor;
  final double canvasLabelOpacity;
  final Offset canvasLabelPosition;
  final List<SilhouettePropConfig> silhouetteProps;

  const LevelVisualTheme({
    required this.levelId,
    required this.stageLabel,
    required this.backgroundColor,
    required this.canvasLabelColor,
    this.canvasLabelOpacity = 0.22,
    this.canvasLabelPosition = const Offset(280.0, 640.0),
    this.silhouetteProps = const [],
  });

  /// Factory resolving the canonical theme for a given levelId (1..30).
  static LevelVisualTheme forLevel(int levelId) {
    return _themes[levelId] ?? _defaultTheme(levelId);
  }

  static LevelVisualTheme _defaultTheme(int id) => LevelVisualTheme(
    levelId: id,
    stageLabel: 'level $id',
    backgroundColor: GlassTokens.obsidianVoid,
    canvasLabelColor: const Color(0xFFFFFFFF),
    canvasLabelOpacity: 0.22,
  );

  static final Map<int, LevelVisualTheme> _themes = {
    // ==========================================
    // Act I: The Fundamentals (Levels 1–7)
    // ==========================================
    1: const LevelVisualTheme(
      levelId: 1,
      stageLabel: 'sugar, sugar',
      backgroundColor: Color(0xFF0B2545), // Midnight Navy
      canvasLabelColor: Color(0xFFE2E8F0),
      canvasLabelPosition: Offset(60.0, 360.0),
    ),
    2: const LevelVisualTheme(
      levelId: 2,
      stageLabel: 'level 2',
      backgroundColor: Color(0xFF0D3B2E), // Forest Pine
      canvasLabelColor: Color(0xFFA7F3D0),
    ),
    3: const LevelVisualTheme(
      levelId: 3,
      stageLabel: 'level 3',
      backgroundColor: Color(0xFF7A3015), // Terracotta Warmth
      canvasLabelColor: Color(0xFFFED7AA),
    ),
    4: const LevelVisualTheme(
      levelId: 4,
      stageLabel: 'level 4',
      backgroundColor: Color(0xFF1E293B), // Slate Charcoal
      canvasLabelColor: Color(0xFFCBD5E1),
    ),
    5: const LevelVisualTheme(
      levelId: 5,
      stageLabel: 'level 5',
      backgroundColor: Color(0xFF855A08), // Vintage Mustard
      canvasLabelColor: Color(0xFFFDE68A),
      silhouetteProps: [
        SilhouettePropConfig(
          type: SilhouetteType.teaspoon,
          origin: Offset(120.0, 420.0),
          rotationDegrees: -15.0,
          scale: 1.0,
        ),
      ],
    ),
    6: const LevelVisualTheme(
      levelId: 6,
      stageLabel: 'level 6',
      backgroundColor: Color(0xFF4A1E35), // Dusty Plum
      canvasLabelColor: Color(0xFFFBCFE8),
    ),
    7: const LevelVisualTheme(
      levelId: 7,
      stageLabel: 'level 7',
      backgroundColor: Color(0xFF0F3A40), // Deep Teal
      canvasLabelColor: Color(0xFF99F6E4),
    ),

    // ==========================================
    // Act II: The Prismatic Spectrum (Levels 8–15)
    // ==========================================
    8: const LevelVisualTheme(
      levelId: 8,
      stageLabel: 'level 8',
      backgroundColor: Color(0xFF0F511D), // Classic Kelly Green
      canvasLabelColor: Color(0xFF4ADE80),
      canvasLabelPosition: Offset(240.0, 620.0),
      silhouetteProps: [
        SilhouettePropConfig(
          type: SilhouetteType.teaspoonDouble,
          origin: Offset(80.0, 480.0),
          scale: 1.1,
        ),
      ],
    ),
    9: const LevelVisualTheme(
      levelId: 9,
      stageLabel: 'level 9',
      backgroundColor: Color(0xFF6A0D18), // Deep Crimson
      canvasLabelColor: Color(0xFFFCA5A5),
    ),
    10: const LevelVisualTheme(
      levelId: 10,
      stageLabel: 'level 10',
      backgroundColor: Color(0xFF161B40), // Midnight Indigo
      canvasLabelColor: Color(0xFFC7D2FE),
    ),
    11: const LevelVisualTheme(
      levelId: 11,
      stageLabel: 'level 11',
      backgroundColor: Color(0xFF6E2E10), // Warm Auburn
      canvasLabelColor: Color(0xFFFDBA74),
    ),
    12: const LevelVisualTheme(
      levelId: 12,
      stageLabel: 'level 12',
      backgroundColor: Color(0xFF2D4119), // Olive Grove
      canvasLabelColor: Color(0xFFBBF7D0),
    ),
    13: const LevelVisualTheme(
      levelId: 13,
      stageLabel: 'level 13',
      backgroundColor: Color(0xFF3B1B36), // Dark Mauve
      canvasLabelColor: Color(0xFFE9D5FF),
    ),
    14: const LevelVisualTheme(
      levelId: 14,
      stageLabel: 'level 14',
      backgroundColor: Color(0xFF1C3B5E), // Steel Blue
      canvasLabelColor: Color(0xFFBAE6FD),
    ),
    15: const LevelVisualTheme(
      levelId: 15,
      stageLabel: 'level 15',
      backgroundColor: Color(0xFF5C2412), // Burnt Sienna
      canvasLabelColor: Color(0xFFFED7AA),
    ),

    // ==========================================
    // Act III: Gravity Inversion (Levels 16–22)
    // ==========================================
    16: const LevelVisualTheme(
      levelId: 16,
      stageLabel: 'level 16',
      backgroundColor: Color(0xFF2E114D), // Royal Violet
      canvasLabelColor: Color(0xFFD8B4FE),
    ),
    17: const LevelVisualTheme(
      levelId: 17,
      stageLabel: 'level 17',
      backgroundColor: Color(0xFF381447), // Deep Amethyst
      canvasLabelColor: Color(0xFFE9D5FF),
    ),
    18: const LevelVisualTheme(
      levelId: 18,
      stageLabel: 'level 18',
      backgroundColor: Color(0xFF4D101E), // Dark Maroon
      canvasLabelColor: Color(0xFFFECDD3),
    ),
    19: const LevelVisualTheme(
      levelId: 19,
      stageLabel: 'level 19',
      backgroundColor: Color(0xFF0B1226), // Midnight Abyss
      canvasLabelColor: Color(0xFFBAE6FD),
    ),
    20: const LevelVisualTheme(
      levelId: 20,
      stageLabel: 'level 20',
      backgroundColor: Color(0xFF0E3322), // Deep Pine
      canvasLabelColor: Color(0xFFA7F3D0),
    ),
    21: const LevelVisualTheme(
      levelId: 21,
      stageLabel: 'level 21',
      backgroundColor: Color(0xFF3B2219), // Warm Espresso
      canvasLabelColor: Color(0xFFFED7AA),
    ),
    22: const LevelVisualTheme(
      levelId: 22,
      stageLabel: 'level 22',
      backgroundColor: Color(0xFF240B2B), // Dark Blackberry
      canvasLabelColor: Color(0xFFF5D0FE),
    ),

    // ==========================================
    // Act IV: The Master Puzzles (Levels 23–30)
    // ==========================================
    23: const LevelVisualTheme(
      levelId: 23,
      stageLabel: 'level 23',
      backgroundColor: Color(0xFF540909), // Blood Crimson
      canvasLabelColor: Color(0xFFFECACA),
      silhouetteProps: [
        SilhouettePropConfig(
          type: SilhouetteType.handPouring,
          origin: Offset(260.0, 60.0),
          scale: 1.2,
        ),
        SilhouettePropConfig(
          type: SilhouetteType.handHoldingCup,
          origin: Offset(40.0, 360.0),
          scale: 1.2,
        ),
      ],
    ),
    24: const LevelVisualTheme(
      levelId: 24,
      stageLabel: 'level 24',
      backgroundColor: Color(0xFF1E252D), // Vintage Slate
      canvasLabelColor: Color(0xFFE2E8F0),
      silhouetteProps: [
        SilhouettePropConfig(
          type: SilhouetteType.teapotSpout,
          origin: Offset(200.0, 70.0),
        ),
      ],
    ),
    25: const LevelVisualTheme(
      levelId: 25,
      stageLabel: 'level 25',
      backgroundColor: Color(0xFF422B08), // Dark Ochre
      canvasLabelColor: Color(0xFFFEF08A),
      silhouetteProps: [
        SilhouettePropConfig(
          type: SilhouetteType.hourglassFrame,
          origin: Offset(200.0, 350.0),
        ),
      ],
    ),
    26: const LevelVisualTheme(
      levelId: 26,
      stageLabel: 'level 26',
      backgroundColor: Color(0xFF360F26), // Deep Mulberry
      canvasLabelColor: Color(0xFFFBCFE8),
    ),
    27: const LevelVisualTheme(
      levelId: 27,
      stageLabel: 'level 27',
      backgroundColor: Color(0xFF591313), // Venetian Red
      canvasLabelColor: Color(0xFFFECACA),
      silhouetteProps: [
        SilhouettePropConfig(
          type: SilhouetteType.handHoldingCup,
          origin: Offset(60.0, 380.0),
        ),
        SilhouettePropConfig(
          type: SilhouetteType.handHoldingCup,
          origin: Offset(340.0, 380.0),
        ),
      ],
    ),
    28: const LevelVisualTheme(
      levelId: 28,
      stageLabel: 'level 28',
      backgroundColor: Color(0xFF181A20), // Dark Iron
      canvasLabelColor: Color(0xFFE2E8F0),
    ),
    29: const LevelVisualTheme(
      levelId: 29,
      stageLabel: 'level 29',
      backgroundColor: Color(0xFF131138), // Cosmic Indigo
      canvasLabelColor: Color(0xFFC7D2FE),
    ),
    30: const LevelVisualTheme(
      levelId: 30,
      stageLabel: 'sugar, sugar',
      backgroundColor: Color(0xFF151B24), // Pure Chalkboard Slate
      canvasLabelColor: Color(0xFFF8FAFC),
      canvasLabelPosition: Offset(100.0, 620.0),
    ),
  };
}
