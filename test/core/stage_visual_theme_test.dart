import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/core/stage_visual_theme.dart';

void main() {
  group('StageVisualTheme 30-Stage Matrix Tests (TASK-006, REQ-003, AC-003)', () {
    test('all 30 levels resolve authentic decompiled solid background colors', () {
      final expectedColors = {
        1: const Color(0xFF076B07), // Green
        2: const Color(0xFF6B256B), // Magenta
        3: const Color(0xFF6B0025), // Crimson
        4: const Color(0xFF076B07), // Green
        5: const Color(0xFF6B256B), // Magenta
        6: const Color(0xFF07456B), // Blue
        7: const Color(0xFF6B0025), // Crimson
        8: const Color(0xFF076B07), // Green
        9: const Color(0xFF6B2507), // Orange
        10: const Color(0xFF6B256B), // Magenta
        11: const Color(0xFF07456B), // Blue
        12: const Color(0xFF6B0025), // Crimson
        13: const Color(0xFF6B256B), // Magenta
        14: const Color(0xFF076B07), // Green
        15: const Color(0xFF6B0025), // Crimson
        16: const Color(0xFF07456B), // Blue
        17: const Color(0xFF6B256B), // Magenta
        18: const Color(0xFF6B0025), // Crimson
        19: const Color(0xFF07456B), // Blue
        20: const Color(0xFF076B07), // Green
        21: const Color(0xFF6B256B), // Magenta
        22: const Color(0xFF07456B), // Blue
        23: const Color(0xFF6B0025), // Crimson
        24: const Color(0xFF07456B), // Blue
        25: const Color(0xFF6B256B), // Magenta
        26: const Color(0xFF07456B), // Blue
        27: const Color(0xFF076B07), // Green
        28: const Color(0xFF07456B), // Blue
        29: const Color(0xFF6B256B), // Magenta
        30: const Color(0xFF6B0025), // Crimson
      };

      for (int i = 1; i <= 30; i++) {
        final theme = StageVisualTheme.forLevel(i);
        expect(
          theme.backgroundColor,
          equals(expectedColors[i]),
          reason: 'Stage $i background color mismatch',
        );
      }
    });

    test('obstacle, line, and accent colors match authentic decompiled Flash specs', () {
      final stage1 = StageVisualTheme.forLevel(1);
      expect(stage1.obstacleColor, equals(const Color(0xFF30D30B)));
      expect(stage1.lineColor, equals(const Color(0xFF30D30B)));

      final stage2 = StageVisualTheme.forLevel(2);
      expect(stage2.obstacleColor, equals(const Color(0xFFFF00EF)));
      expect(stage2.lineColor, equals(const Color(0xFFFF00EF)));

      final stage3 = StageVisualTheme.forLevel(3);
      expect(stage3.obstacleColor, equals(const Color(0xFFFF0021)));
      expect(stage3.lineColor, equals(const Color(0xFFFF0022)));

      final stage6 = StageVisualTheme.forLevel(6);
      expect(stage6.obstacleColor, equals(const Color(0xFF7ACAED)));
      expect(stage6.lineColor, equals(const Color(0xFF7ACAED)));

      final stage9 = StageVisualTheme.forLevel(9);
      expect(stage9.obstacleColor, equals(const Color(0xFFF44E0C)));
      expect(stage9.lineColor, equals(const Color(0xFFF44E0C)));
    });

    test('menu theme resolves authentic slate background and accents', () {
      const menu = StageVisualTheme.menu;
      expect(menu.backgroundColor, equals(const Color(0xFF07456B)));
      expect(menu.obstacleColor, equals(const Color(0xFF00ADB5)));
      expect(menu.lineColor, equals(const Color(0xFFEEEEEE)));
      expect(menu.accentColor, equals(const Color(0xFFF38181)));
    });

    test('unknown level fallback resolves stage1 green safely', () {
      final fallback = StageVisualTheme.forLevel(999);
      expect(fallback, equals(StageVisualTheme.stage1));
    });
  });
}

