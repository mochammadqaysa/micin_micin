import 'dart:convert';
import 'dart:io';

const String kWhite = '#FFFFFF';
const String kRose = '#F4A7B9';
const String kAqua = '#70C1B3';
const String kGold = '#E8C547';
const String kSage = '#95B8A2';

Map<String, dynamic> makeLevel({
  required int id,
  required String name,
  required List<Map<String, dynamic>> emitters,
  required List<Map<String, dynamic>> cups,
  List<Map<String, dynamic>> filters = const [],
  bool hasGravityToggle = false,
}) {
  final totalSugar = 150 * cups.length;
  return {
    'id': id,
    'name': name,
    'totalSugar': totalSugar,
    'gravity': 0.14,
    'hasGravityToggle': hasGravityToggle,
    'canvasHeight': 700.0,
    'emitters': emitters,
    'cups': cups,
    'filters': filters,
  };
}

Map<String, dynamic> makeEmitter({
  required double x,
  required double y,
  required int totalToEmit,
  int rate = 3,
  String color = kWhite,
}) => {
      'x': x,
      'y': y,
      'rate': rate,
      'color': color,
      'totalToEmit': totalToEmit,
    };

Map<String, dynamic> makeCup({
  required double x,
  required double y,
  double width = 40.0,
  double height = 56.0,
  String color = kWhite,
  int targetAmount = 100,
}) => {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'color': color,
      'targetAmount': targetAmount,
    };

Map<String, dynamic> makeFilter({
  required double x,
  required double y,
  double width = 80.0,
  double height = 25.0,
  required String targetColor,
}) => {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'targetColor': targetColor,
    };

final List<Map<String, dynamic>> allLevels = [
  // ==========================================
  // ACT I: GENTLE FLOW & CHUTES (Levels 1 - 7)
  // ==========================================
  makeLevel(
    id: 1,
    name: 'The First Slope',
    emitters: [makeEmitter(x: 100, y: 60, totalToEmit: 150)],
    cups: [makeCup(x: 280, y: 580)],
  ),
  makeLevel(
    id: 2,
    name: 'Counter Flow',
    emitters: [makeEmitter(x: 300, y: 60, totalToEmit: 150)],
    cups: [makeCup(x: 80, y: 580)],
  ),
  makeLevel(
    id: 3,
    name: 'Twin Basins',
    emitters: [makeEmitter(x: 200, y: 50, totalToEmit: 300)],
    cups: [makeCup(x: 60, y: 580), makeCup(x: 300, y: 580)],
  ),
  makeLevel(
    id: 4,
    name: 'The S-Curve',
    emitters: [makeEmitter(x: 70, y: 60, totalToEmit: 150)],
    cups: [makeCup(x: 290, y: 580)],
  ),
  makeLevel(
    id: 5,
    name: 'Zen Basin',
    emitters: [makeEmitter(x: 90, y: 60, totalToEmit: 150)],
    cups: [makeCup(x: 230, y: 560)],
  ),
  makeLevel(
    id: 6,
    name: 'Weaving Streams',
    emitters: [
      makeEmitter(x: 70, y: 60, totalToEmit: 150),
      makeEmitter(x: 330, y: 60, totalToEmit: 150),
    ],
    cups: [makeCup(x: 130, y: 580), makeCup(x: 270, y: 580)],
  ),
  makeLevel(
    id: 7,
    name: 'The Triad Cascade',
    emitters: [makeEmitter(x: 200, y: 50, totalToEmit: 450)],
    cups: [
      makeCup(x: 50, y: 560),
      makeCup(x: 130, y: 600),
      makeCup(x: 310, y: 560),
    ],
  ),

  // ==========================================
  // ACT II: THE CHROMATIC PRISM (Levels 8 - 15)
  // ==========================================
  makeLevel(
    id: 8,
    name: 'Rose Petal',
    emitters: [makeEmitter(x: 90, y: 50, totalToEmit: 150)],
    filters: [makeFilter(x: 60, y: 220, targetColor: kRose)],
    cups: [makeCup(x: 270, y: 580, color: kRose)],
  ),
  makeLevel(
    id: 9,
    name: 'Aqua Spring',
    emitters: [makeEmitter(x: 310, y: 50, totalToEmit: 150)],
    filters: [makeFilter(x: 260, y: 220, targetColor: kAqua)],
    cups: [makeCup(x: 90, y: 580, color: kAqua)],
  ),
  makeLevel(
    id: 10,
    name: 'Prism Terrace',
    emitters: [makeEmitter(x: 110, y: 60, totalToEmit: 150)],
    filters: [makeFilter(x: 80, y: 230, width: 90, targetColor: kRose)],
    cups: [makeCup(x: 260, y: 560, color: kRose)],
  ),
  makeLevel(
    id: 11,
    name: 'Rose Gate',
    emitters: [makeEmitter(x: 120, y: 50, totalToEmit: 150)],
    filters: [makeFilter(x: 80, y: 160, width: 80, height: 25, targetColor: kRose)],
    cups: [makeCup(x: 270, y: 580, color: kRose)],
  ),
  makeLevel(
    id: 12,
    name: 'Dual Harmony',
    emitters: [makeEmitter(x: 200, y: 50, totalToEmit: 300)],
    filters: [
      makeFilter(x: 60, y: 230, targetColor: kRose),
      makeFilter(x: 260, y: 230, targetColor: kAqua),
    ],
    cups: [
      makeCup(x: 70, y: 580, color: kRose),
      makeCup(x: 290, y: 580, color: kAqua),
    ],
  ),
  makeLevel(
    id: 13,
    name: 'Crossed Ribbons',
    emitters: [
      makeEmitter(x: 70, y: 50, totalToEmit: 150),
      makeEmitter(x: 330, y: 50, totalToEmit: 150),
    ],
    filters: [
      makeFilter(x: 240, y: 220, targetColor: kRose),
      makeFilter(x: 80, y: 220, targetColor: kAqua),
    ],
    cups: [
      makeCup(x: 120, y: 580, color: kRose),
      makeCup(x: 240, y: 580, color: kAqua),
    ],
  ),
  makeLevel(
    id: 14,
    name: 'The Spectrum Trio',
    emitters: [makeEmitter(x: 200, y: 50, totalToEmit: 450)],
    filters: [
      makeFilter(x: 60, y: 250, targetColor: kRose),
      makeFilter(x: 260, y: 250, targetColor: kAqua),
    ],
    cups: [
      makeCup(x: 60, y: 580, color: kRose),
      makeCup(x: 130, y: 580, color: kWhite),
      makeCup(x: 310, y: 580, color: kAqua),
    ],
  ),
  makeLevel(
    id: 15,
    name: 'Prismatic Labyrinth',
    emitters: [
      makeEmitter(x: 80, y: 50, totalToEmit: 225),
      makeEmitter(x: 320, y: 50, totalToEmit: 225),
    ],
    filters: [
      makeFilter(x: 60, y: 200, width: 75, targetColor: kRose),
      makeFilter(x: 265, y: 270, width: 75, targetColor: kAqua),
    ],
    cups: [
      makeCup(x: 30, y: 580, color: kRose),
      makeCup(x: 180, y: 580, color: kWhite),
      makeCup(x: 270, y: 580, color: kAqua),
    ],
  ),

  // ==========================================
  // ACT III: GRAVITY INVERSION (Levels 16 - 22)
  // ==========================================
  makeLevel(
    id: 16,
    name: 'Skyward Drift',
    hasGravityToggle: true,
    emitters: [makeEmitter(x: 90, y: 560, totalToEmit: 150)],
    cups: [makeCup(x: 270, y: 105.0)],
  ),
  makeLevel(
    id: 17,
    name: 'Bipolar Orbit',
    hasGravityToggle: true,
    emitters: [makeEmitter(x: 100, y: 350, totalToEmit: 300)],
    cups: [
      makeCup(x: 280, y: 580),
      makeCup(x: 280, y: 105.0),
    ],
  ),
  makeLevel(
    id: 18,
    name: 'Parabolic Arc',
    hasGravityToggle: true,
    emitters: [makeEmitter(x: 80, y: 560, totalToEmit: 150)],
    cups: [makeCup(x: 260, y: 105.0)],
  ),
  makeLevel(
    id: 19,
    name: 'Inverted Rose',
    hasGravityToggle: true,
    emitters: [makeEmitter(x: 290, y: 580, totalToEmit: 150)],
    filters: [makeFilter(x: 250, y: 320, targetColor: kRose)],
    cups: [makeCup(x: 90, y: 105.0, color: kRose)],
  ),
  makeLevel(
    id: 20,
    name: 'Ascent & Abyss',
    hasGravityToggle: true,
    emitters: [makeEmitter(x: 180, y: 340, totalToEmit: 300)],
    filters: [makeFilter(x: 240, y: 240, targetColor: kAqua)],
    cups: [
      makeCup(x: 70, y: 580, color: kWhite),
      makeCup(x: 280, y: 105.0, color: kAqua),
    ],
  ),
  makeLevel(
    id: 21,
    name: 'The Pendulum',
    hasGravityToggle: true,
    emitters: [makeEmitter(x: 80, y: 540, totalToEmit: 150)],
    cups: [makeCup(x: 180.0, y: 105.0)],
  ),
  makeLevel(
    id: 22,
    name: 'Zenith & Nadir',
    hasGravityToggle: true,
    emitters: [makeEmitter(x: 120, y: 340, totalToEmit: 450)],
    filters: [
      makeFilter(x: 40, y: 240, targetColor: kRose),
      makeFilter(x: 180, y: 440, targetColor: kAqua),
    ],
    cups: [
      makeCup(x: 290, y: 105.0, color: kWhite),
      makeCup(x: 50, y: 105.0, color: kRose),
      makeCup(x: 220, y: 580, color: kAqua),
    ],
  ),

  // ==========================================
  // ACT IV: THE MASTER ZEN GARDEN (Levels 23 - 30)
  // ==========================================
  makeLevel(
    id: 23,
    name: 'Golden Grain',
    emitters: [makeEmitter(x: 80, y: 50, totalToEmit: 150)],
    filters: [makeFilter(x: 160, y: 240, targetColor: kGold)],
    cups: [makeCup(x: 280, y: 580, color: kGold)],
  ),
  makeLevel(
    id: 24,
    name: 'Sage Sanctuary',
    emitters: [makeEmitter(x: 320, y: 50, totalToEmit: 150)],
    filters: [makeFilter(x: 160, y: 240, targetColor: kSage)],
    cups: [makeCup(x: 70, y: 580, color: kSage)],
  ),
  makeLevel(
    id: 25,
    name: 'Autumn Flow',
    emitters: [makeEmitter(x: 200, y: 50, totalToEmit: 300)],
    filters: [
      makeFilter(x: 60, y: 220, targetColor: kRose),
      makeFilter(x: 260, y: 220, targetColor: kGold),
    ],
    cups: [
      makeCup(x: 70, y: 580, color: kRose),
      makeCup(x: 290, y: 580, color: kGold),
    ],
  ),
  makeLevel(
    id: 26,
    name: 'The Quad Prism',
    emitters: [makeEmitter(x: 200, y: 50, totalToEmit: 450)],
    filters: [
      makeFilter(x: 40, y: 200, width: 70, targetColor: kRose),
      makeFilter(x: 165, y: 270, width: 70, targetColor: kAqua),
      makeFilter(x: 290, y: 200, width: 70, targetColor: kGold),
    ],
    cups: [
      makeCup(x: 50, y: 580, color: kRose),
      makeCup(x: 140, y: 580, color: kAqua),
      makeCup(x: 310, y: 580, color: kGold),
    ],
  ),
  makeLevel(
    id: 27,
    name: 'Equinox Inversion',
    hasGravityToggle: true,
    emitters: [makeEmitter(x: 200, y: 350, totalToEmit: 300)],
    filters: [
      makeFilter(x: 240, y: 220, targetColor: kSage),
      makeFilter(x: 70, y: 440, targetColor: kGold),
    ],
    cups: [
      makeCup(x: 280, y: 105.0, color: kSage),
      makeCup(x: 70, y: 580, color: kGold),
    ],
  ),
  makeLevel(
    id: 28,
    name: 'The Four Elements',
    emitters: [
      makeEmitter(x: 80, y: 50, totalToEmit: 300),
      makeEmitter(x: 280, y: 50, totalToEmit: 300),
    ],
    filters: [
      makeFilter(x: 30, y: 220, width: 65, targetColor: kRose),
      makeFilter(x: 120, y: 300, width: 65, targetColor: kAqua),
      makeFilter(x: 215, y: 300, width: 65, targetColor: kGold),
      makeFilter(x: 305, y: 220, width: 65, targetColor: kSage),
    ],
    cups: [
      makeCup(x: 30, y: 580, color: kRose),
      makeCup(x: 130, y: 580, color: kAqua),
      makeCup(x: 230, y: 580, color: kGold),
      makeCup(x: 330, y: 580, color: kSage),
    ],
  ),
  makeLevel(
    id: 29,
    name: 'The Hourglass',
    hasGravityToggle: true,
    emitters: [makeEmitter(x: 200, y: 350, totalToEmit: 600)],
    filters: [
      makeFilter(x: 60, y: 220, width: 75, targetColor: kRose),
      makeFilter(x: 265, y: 220, width: 75, targetColor: kAqua),
      makeFilter(x: 60, y: 450, width: 75, targetColor: kGold),
      makeFilter(x: 265, y: 450, width: 75, targetColor: kSage),
    ],
    cups: [
      makeCup(x: 70, y: 105.0, color: kRose),
      makeCup(x: 290, y: 105.0, color: kAqua),
      makeCup(x: 70, y: 580, color: kGold),
      makeCup(x: 290, y: 580, color: kSage),
    ],
  ),
  makeLevel(
    id: 30,
    name: 'The Master Zen Garden',
    hasGravityToggle: true,
    emitters: [
      makeEmitter(x: 80, y: 350, totalToEmit: 375),
      makeEmitter(x: 280, y: 350, totalToEmit: 375),
    ],
    filters: [
      makeFilter(x: 30, y: 440, width: 60, targetColor: kRose),
      makeFilter(x: 110, y: 440, width: 60, targetColor: kAqua),
      makeFilter(x: 230, y: 440, width: 60, targetColor: kGold),
      makeFilter(x: 310, y: 440, width: 60, targetColor: kSage),
    ],
    cups: [
      makeCup(x: 180, y: 105.0, color: kWhite),
      makeCup(x: 30, y: 580, color: kRose),
      makeCup(x: 120, y: 580, color: kAqua),
      makeCup(x: 240, y: 580, color: kGold),
      makeCup(x: 330, y: 580, color: kSage),
    ],
  ),
];

void main() {
  final outDir = Directory('assets/levels');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  const encoder = JsonEncoder.withIndent('  ');

  for (final level in allLevels) {
    final id = level['id'] as int;
    final fileName = 'level_${id.toString().padLeft(2, '0')}.json';
    final file = File('${outDir.path}/$fileName');
    file.writeAsStringSync('${encoder.convert(level)}\n');
    stdout.writeln('Generated $fileName');
  }

  stdout.writeln('Successfully generated all 30 Zen levels!');
}
