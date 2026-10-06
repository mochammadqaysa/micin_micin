import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/core/theme.dart';
import 'package:micin_micin/models/level_visual_theme.dart';
import 'package:micin_micin/models/silhouette_prop_config.dart';
import 'package:micin_micin/screens/game/painters/background_painter.dart';

void main() {
  group('LevelVisualTheme 30-Stage Matrix Tests (REQ-003, AC-003, TASK-204)', () {
    final expectedHexColors = <int, int>{
      // Act I: The Fundamentals
      1: 0xFF0B2545,  // Midnight Navy
      2: 0xFF0D3B2E,  // Forest Pine
      3: 0xFF7A3015,  // Terracotta Warmth
      4: 0xFF1E293B,  // Slate Charcoal
      5: 0xFF855A08,  // Vintage Mustard
      6: 0xFF4A1E35,  // Dusty Plum
      7: 0xFF0F3A40,  // Deep Teal

      // Act II: The Prismatic Spectrum
      8: 0xFF0F511D,  // Classic Kelly Green
      9: 0xFF6A0D18,  // Deep Crimson
      10: 0xFF161B40, // Midnight Indigo
      11: 0xFF6E2E10, // Warm Auburn
      12: 0xFF2D4119, // Olive Grove
      13: 0xFF3B1B36, // Dark Mauve
      14: 0xFF1C3B5E, // Steel Blue
      15: 0xFF5C2412, // Burnt Sienna

      // Act III: Gravity Inversion
      16: 0xFF2E114D, // Royal Violet
      17: 0xFF381447, // Deep Amethyst
      18: 0xFF4D101E, // Dark Maroon
      19: 0xFF0B1226, // Midnight Abyss
      20: 0xFF0E3322, // Deep Pine
      21: 0xFF3B2219, // Warm Espresso
      22: 0xFF240B2B, // Dark Blackberry

      // Act IV: The Master Puzzles
      23: 0xFF540909, // Blood Crimson
      24: 0xFF1E252D, // Vintage Slate
      25: 0xFF422B08, // Dark Ochre
      26: 0xFF360F26, // Deep Mulberry
      27: 0xFF591313, // Venetian Red
      28: 0xFF181A20, // Dark Iron
      29: 0xFF131138, // Cosmic Indigo
      30: 0xFF151B24, // Pure Chalkboard Slate
    };

    test('all 30 levels resolve canonical background colors matching GDD Matrix (AC-003)', () {
      for (int levelId = 1; levelId <= 30; levelId++) {
        final theme = LevelVisualTheme.forLevel(levelId);
        expect(theme.levelId, equals(levelId), reason: 'Mismatch on levelId $levelId');
        final expectedHex = expectedHexColors[levelId]!;
        expect(
          theme.backgroundColor.toARGB32(),
          equals(expectedHex),
          reason: 'Level $levelId background color does not match GDD specification',
        );
      }
    });

    test('stage labels follow canonical Bonte typography format (AC-004)', () {
      // Levels 1 and 30 feature tribute "sugar, sugar"
      expect(LevelVisualTheme.forLevel(1).stageLabel, equals('sugar, sugar'));
      expect(LevelVisualTheme.forLevel(30).stageLabel, equals('sugar, sugar'));

      // Other levels feature lowercase "level $id"
      for (int levelId = 2; levelId <= 29; levelId++) {
        expect(LevelVisualTheme.forLevel(levelId).stageLabel, equals('level $levelId'));
      }
    });

    test('canvasLabelOpacity stays within harmonized range [0.18, 0.25]', () {
      for (int levelId = 1; levelId <= 30; levelId++) {
        final theme = LevelVisualTheme.forLevel(levelId);
        expect(theme.canvasLabelOpacity, greaterThanOrEqualTo(0.18));
        expect(theme.canvasLabelOpacity, lessThanOrEqualTo(0.25));
      }
    });

    test('unregistered or out-of-bounds level IDs safely fallback to default theme', () {
      final fallbackTheme = LevelVisualTheme.forLevel(99);
      expect(fallbackTheme.levelId, equals(99));
      expect(fallbackTheme.stageLabel, equals('level 99'));
      expect(fallbackTheme.backgroundColor.toARGB32(), equals(GlassTokens.obsidianVoid.toARGB32()));
      expect(fallbackTheme.silhouetteProps, isEmpty);
    });

    test('thematic silhouette props are registered for designated signature levels', () {
      // Level 5: Silver Teaspoon
      final theme5 = LevelVisualTheme.forLevel(5);
      expect(theme5.silhouetteProps.length, equals(1));
      expect(theme5.silhouetteProps.first.type, equals(SilhouetteType.teaspoon));

      // Level 8: Green Double Spoons
      final theme8 = LevelVisualTheme.forLevel(8);
      expect(theme8.silhouetteProps.length, equals(1));
      expect(theme8.silhouetteProps.first.type, equals(SilhouetteType.teaspoonDouble));

      // Level 23: Hands of the Maker
      final theme23 = LevelVisualTheme.forLevel(23);
      expect(theme23.silhouetteProps.length, equals(2));
      expect(theme23.silhouetteProps[0].type, equals(SilhouetteType.handPouring));
      expect(theme23.silhouetteProps[1].type, equals(SilhouetteType.handHoldingCup));

      // Level 24: Teapot Spout
      final theme24 = LevelVisualTheme.forLevel(24);
      expect(theme24.silhouetteProps.length, equals(1));
      expect(theme24.silhouetteProps.first.type, equals(SilhouetteType.teapotSpout));

      // Level 25: Hourglass Frame
      final theme25 = LevelVisualTheme.forLevel(25);
      expect(theme25.silhouetteProps.length, equals(1));
      expect(theme25.silhouetteProps.first.type, equals(SilhouetteType.hourglassFrame));

      // Level 27: Twin Hands
      final theme27 = LevelVisualTheme.forLevel(27);
      expect(theme27.silhouetteProps.length, equals(2));
      expect(theme27.silhouetteProps[0].type, equals(SilhouetteType.handHoldingCup));
      expect(theme27.silhouetteProps[1].type, equals(SilhouetteType.handHoldingCup));
    });

    test('BackgroundPainter paints with chromatic palette and diegetic label without errors (AC-004)', () {
      final theme = LevelVisualTheme.forLevel(8);
      final painter = BackgroundPainter(
        backgroundColor: theme.backgroundColor,
        canvasLabel: theme.stageLabel,
        canvasLabelColor: theme.canvasLabelColor,
        canvasLabelOpacity: theme.canvasLabelOpacity,
        canvasLabelPosition: theme.canvasLabelPosition,
        virtualOffset: const Offset(10.0, 20.0),
        virtualScale: 1.2,
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      expect(() => painter.paint(canvas, const Size(400, 700)), returnsNormally);

      // Verify shouldRepaint logic
      final identicalPainter = BackgroundPainter(
        backgroundColor: theme.backgroundColor,
        canvasLabel: theme.stageLabel,
        canvasLabelColor: theme.canvasLabelColor,
        canvasLabelOpacity: theme.canvasLabelOpacity,
        canvasLabelPosition: theme.canvasLabelPosition,
        virtualOffset: const Offset(10.0, 20.0),
        virtualScale: 1.2,
      );
      expect(painter.shouldRepaint(identicalPainter), isFalse);

      final differentThemePainter = BackgroundPainter(
        backgroundColor: const Color(0xFF6A0D18),
        canvasLabel: 'level 9',
      );
      expect(painter.shouldRepaint(differentThemePainter), isTrue);
    });
  });
}
