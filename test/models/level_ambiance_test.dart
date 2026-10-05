import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/models/cup_config.dart';
import 'package:micin_micin/models/level_ambiance.dart';
import 'package:micin_micin/models/level_config.dart';

void main() {
  group('LevelAmbiance', () {
    test('provides distinct ambiances for all 30 levels across 4 acts', () {
      for (int i = 1; i <= 30; i++) {
        final ambiance = LevelAmbiance.forLevel(i);
        expect(ambiance.levelId, equals(i));
        expect(ambiance.name.isNotEmpty, isTrue);
        expect(ambiance.actTitle.isNotEmpty, isTrue);
        expect(ambiance.zenReflection.isNotEmpty, isTrue);
        expect(ambiance.accentColor, isA<Color>());
        expect(ambiance.glowColor, isA<Color>());
        expect(ambiance.moteColor, isA<Color>());

        if (i <= 7) {
          expect(ambiance.actNumeral, equals('I'));
          expect(ambiance.actIndex, equals(0));
        } else if (i <= 15) {
          expect(ambiance.actNumeral, equals('II'));
          expect(ambiance.actIndex, equals(1));
        } else if (i <= 22) {
          expect(ambiance.actNumeral, equals('III'));
          expect(ambiance.actIndex, equals(2));
        } else {
          expect(ambiance.actNumeral, equals('IV'));
          expect(ambiance.actIndex, equals(3));
        }
      }
    });

    test('dynamically adapts accent color when level has colored cups', () {
      const customPink = Color(0xFFF4A7B9);
      final config = LevelConfig(
        id: 8,
        name: 'Prisma 8',
        emitters: const [],
        cups: [
          CupConfig(
            x: 100,
            y: 400,
            width: 60,
            height: 50,
            color: customPink,
            targetAmount: 30,
          ),
        ],
        totalSugar: 100,
      );

      final ambiance = LevelAmbiance.forLevel(8, config);
      expect(ambiance.accentColor.toARGB32(), equals(customPink.toARGB32()));
    });
  });
}
