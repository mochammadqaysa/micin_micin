import 'package:flutter/material.dart';
import 'level_config.dart';

/// Defines the unique contemplative visual atmosphere, color wash, and poetic reflection
/// for a level's Victory State (Diegetic HUD - Ambient Victory State).
class LevelAmbiance {
  final int levelId;
  final String name;
  final int actIndex; // 0..3
  final String actNumeral; // "I", "II", "III", "IV"
  final String actTitle;
  final Color accentColor;
  final Color glowColor;
  final Color moteColor;
  final String zenReflection;

  const LevelAmbiance({
    required this.levelId,
    required this.name,
    required this.actIndex,
    required this.actNumeral,
    required this.actTitle,
    required this.accentColor,
    required this.glowColor,
    required this.moteColor,
    required this.zenReflection,
  });

  /// 30 bespoke atmospheric themes curated across the 4 Zen Movements.
  static const List<LevelAmbiance> _ambiances = [
    // Act I: Aliran Lembut & Curam (Levels 1–7) — Pure Crystalline Silver & Moonlit White
    LevelAmbiance(
      levelId: 1,
      name: 'Kabut Fajar',
      actIndex: 0,
      actNumeral: 'I',
      actTitle: 'Aliran Lembut & Curam',
      accentColor: Color(0xFFF1F5F9), // Crystalline White
      glowColor: Color(0xFF94A3B8),
      moteColor: Color(0xFFE2E8F0),
      zenReflection: 'Titik awal perjalanan. Butiran mineral mengalir tenang dalam keheningan fajar.',
    ),
    LevelAmbiance(
      levelId: 2,
      name: 'Embun Kristal',
      actIndex: 0,
      actNumeral: 'I',
      actTitle: 'Aliran Lembut & Curam',
      accentColor: Color(0xFFE0F2FE), // Soft Ice
      glowColor: Color(0xFF7DD3FC),
      moteColor: Color(0xFFBAE6FD),
      zenReflection: 'Aliran menemukan ritmenya, laksana tetesan embun membasahi dedaunan pagi.',
    ),
    LevelAmbiance(
      levelId: 3,
      name: 'Batu Sungai',
      actIndex: 0,
      actNumeral: 'I',
      actTitle: 'Aliran Lembut & Curam',
      accentColor: Color(0xFFCBD5E1), // River Stone
      glowColor: Color(0xFF64748B),
      moteColor: Color(0xFF94A3B8),
      zenReflection: 'Garis yang Anda goreskan membimbing butiran melewati rintangan dengan anggun.',
    ),
    LevelAmbiance(
      levelId: 4,
      name: 'Hutan Bambu',
      actIndex: 0,
      actNumeral: 'I',
      actTitle: 'Aliran Lembut & Curam',
      accentColor: Color(0xFFD1FAE5), // Pale Jade
      glowColor: Color(0xFF6EE7B7),
      moteColor: Color(0xFFA7F3D0),
      zenReflection: 'Keseimbangan lentur tercipta, seperti rumpun bambu yang meliuk mengikuti angin.',
    ),
    LevelAmbiance(
      levelId: 5,
      name: 'Taman Bebas I',
      actIndex: 0,
      actNumeral: 'I',
      actTitle: 'Aliran Lembut & Curam',
      accentColor: Color(0xFFE2E8F0), // Pure Alabaster
      glowColor: Color(0xFFA8B2D1),
      moteColor: Color(0xFFF8FAFC),
      zenReflection: 'Ruang terbuka menyambut aliran bebas. Ketenangan pikiran terpancar sempurna.',
    ),
    LevelAmbiance(
      levelId: 6,
      name: 'Arus Sejuk',
      actIndex: 0,
      actNumeral: 'I',
      actTitle: 'Aliran Lembut & Curam',
      accentColor: Color(0xFFCFFAFE), // Cyan Dew
      glowColor: Color(0xFF67E8F9),
      moteColor: Color(0xFFA5F3FC),
      zenReflection: 'Kecepatan dan kelokan bersatu tanpa hambatan, mengisi bejana hingga penuh.',
    ),
    LevelAmbiance(
      levelId: 7,
      name: 'Gerbang Babak Pertama',
      actIndex: 0,
      actNumeral: 'I',
      actTitle: 'Aliran Lembut & Curam',
      accentColor: Color(0xFFFFFFFF), // Pristine Diamond
      glowColor: Color(0xFFCBD5E1),
      moteColor: Color(0xFFF1F5F9),
      zenReflection: 'Babak pertama terselesaikan. Pondasi ketenangan gravitasi telah Anda kuasai.',
    ),

    // Act II: Prisma Kromatik (Levels 8–15) — Pastel Rose, Lotus, & Coral Blush
    LevelAmbiance(
      levelId: 8,
      name: 'Kelopak Sakura',
      actIndex: 1,
      actNumeral: 'II',
      actTitle: 'Prisma Kromatik',
      accentColor: Color(0xFFF4A7B9), // Sakura Rose
      glowColor: Color(0xFFF472B6),
      moteColor: Color(0xFFFBCFE8),
      zenReflection: 'Butiran melintasi filter warna, bermutasi menjadi rona merah muda yang anggun.',
    ),
    LevelAmbiance(
      levelId: 9,
      name: 'Bunga Teratai',
      actIndex: 1,
      actNumeral: 'II',
      actTitle: 'Prisma Kromatik',
      accentColor: Color(0xFFFDA4AF), // Lotus Pink
      glowColor: Color(0xFFFB7185),
      moteColor: Color(0xFFFECDD3),
      zenReflection: 'Mekar di atas ketenangan air, warna terpisah dan berlabuh pada cawan yang tepat.',
    ),
    LevelAmbiance(
      levelId: 10,
      name: 'Prisma Harmoni',
      actIndex: 1,
      actNumeral: 'II',
      actTitle: 'Prisma Kromatik',
      accentColor: Color(0xFFF0ABFC), // Dawn Mauve
      glowColor: Color(0xFFE879F9),
      moteColor: Color(0xFFF5D0FE),
      zenReflection: 'Dua spektrum bersilangan harmonis tanpa saling mengganggu aliran satu sama lain.',
    ),
    LevelAmbiance(
      levelId: 11,
      name: 'Lembayung Sutra',
      actIndex: 1,
      actNumeral: 'II',
      actTitle: 'Prisma Kromatik',
      accentColor: Color(0xFFE879F9), // Soft Magenta
      glowColor: Color(0xFFC084FC),
      moteColor: Color(0xFFF0ABFC),
      zenReflection: 'Kelembutan sutra memandu warna ungu pastel mengalir memenuhi wadah takdirnya.',
    ),
    LevelAmbiance(
      levelId: 12,
      name: 'Senja Koral',
      actIndex: 1,
      actNumeral: 'II',
      actTitle: 'Prisma Kromatik',
      accentColor: Color(0xFFFB7185), // Coral Blossom
      glowColor: Color(0xFFF43F5E),
      moteColor: Color(0xFFFECDD3),
      zenReflection: 'Rona senja merambat pada butiran gula, memancarkan kehangatan di atas batu basal.',
    ),
    LevelAmbiance(
      levelId: 13,
      name: 'Bara Merah Delima',
      actIndex: 1,
      actNumeral: 'II',
      actTitle: 'Prisma Kromatik',
      accentColor: Color(0xFFF87171), // Ruby Warmth
      glowColor: Color(0xFFEF4444),
      moteColor: Color(0xFFFCA5A5),
      zenReflection: 'Daya tarik warna semakin mendalam, menyalakan semangat presisi dalam ketenangan.',
    ),
    LevelAmbiance(
      levelId: 14,
      name: 'Air Tenang Basal',
      actIndex: 1,
      actNumeral: 'II',
      actTitle: 'Prisma Kromatik',
      accentColor: Color(0xFF84D5C7), // Still Water Basalt (Stitch Act II Canon)
      glowColor: Color(0xFF00685D),
      moteColor: Color(0xFFA0F2E3),
      zenReflection: 'Granular equilibrium attained. The vessels resonate in quiet alignment.',
    ),
    LevelAmbiance(
      levelId: 15,
      name: 'Klimaks Spektrum',
      actIndex: 1,
      actNumeral: 'II',
      actTitle: 'Prisma Kromatik',
      accentColor: Color(0xFFF472B6), // Deep Radiant Rose
      glowColor: Color(0xFFDB2777),
      moteColor: Color(0xFFFBCFE8),
      zenReflection: 'Seluruh spektrum warna telah bersatu dalam kepatuhan pada hukum harmoni.',
    ),

    // Act III: Inversi Gravitasi (Levels 16–22) — Soft Aqua, Celadon Teal, Sky Inversion
    LevelAmbiance(
      levelId: 16,
      name: 'Mata Air Langit',
      actIndex: 2,
      actNumeral: 'III',
      actTitle: 'Inversi Gravitasi',
      accentColor: Color(0xFF70C1B3), // Soft Emerald Aqua
      glowColor: Color(0xFF0D9488),
      moteColor: Color(0xFF99F6E4),
      zenReflection: 'Arah gravitasi berbalik menuju cakrawala. Butiran naik melawan kelaziman alam.',
    ),
    LevelAmbiance(
      levelId: 17,
      name: 'Danau Giok',
      actIndex: 2,
      actNumeral: 'III',
      actTitle: 'Inversi Gravitasi',
      accentColor: Color(0xFF34D399), // Jade Spring
      glowColor: Color(0xFF059669),
      moteColor: Color(0xFFA7F3D0),
      zenReflection: 'Kejernihan giok memayungi cawan langit yang terbalik menerima tumpahan mineral.',
    ),
    LevelAmbiance(
      levelId: 18,
      name: 'Air Mancur Zen',
      actIndex: 2,
      actNumeral: 'III',
      actTitle: 'Inversi Gravitasi',
      accentColor: Color(0xFF2DD4BF), // Celestial Turquoise
      glowColor: Color(0xFF0F766E),
      moteColor: Color(0xFF5EEAD4),
      zenReflection: 'Lompatan gravitasi melahirkan pancuran butiran yang menari di angkasa.',
    ),
    LevelAmbiance(
      levelId: 19,
      name: 'Seladon Samudera',
      actIndex: 2,
      actNumeral: 'III',
      actTitle: 'Inversi Gravitasi',
      accentColor: Color(0xFF38BDF8), // Ocean Sky
      glowColor: Color(0xFF0284C7),
      moteColor: Color(0xFF7DD3FC),
      zenReflection: 'Kedalaman dan ketinggian bertukar peran. Pikiran tetap teguh di poros keseimbangan.',
    ),
    LevelAmbiance(
      levelId: 20,
      name: 'Cakrawala Terbalik',
      actIndex: 2,
      actNumeral: 'III',
      actTitle: 'Inversi Gravitasi',
      accentColor: Color(0xFF06B6D4), // Cyan Horizon
      glowColor: Color(0xFF0891B2),
      moteColor: Color(0xFF67E8F9),
      zenReflection: 'Pembalikan arah menjadi keindahan saat garis pemandu Anda mengarahkan takdir.',
    ),
    LevelAmbiance(
      levelId: 21,
      name: 'Aurora Pesisir',
      actIndex: 2,
      actNumeral: 'III',
      actTitle: 'Inversi Gravitasi',
      accentColor: Color(0xFF22D3EE), // Luminous Aurora
      glowColor: Color(0xFF0E7490),
      moteColor: Color(0xFFA5F3FC),
      zenReflection: 'Pendaran cahaya aqua menyinari partikel yang melayang bebas dalam ruang hening.',
    ),
    LevelAmbiance(
      levelId: 22,
      name: 'Pusaran Langit Biru',
      actIndex: 2,
      actNumeral: 'III',
      actTitle: 'Inversi Gravitasi',
      accentColor: Color(0xFF0EA5E9), // Deep Celestial
      glowColor: Color(0xFF0369A1),
      moteColor: Color(0xFF38BDF8),
      zenReflection: 'Ujian gravitasi ganda telah tuntas. Cawan di langit dan bumi kini bersatu.',
    ),

    // Act IV: Taman Zen Agung (Levels 23–30) — Warm Imperial Gold, Honey Amber & Saffron
    LevelAmbiance(
      levelId: 23,
      name: 'Matahari Pagi Emas',
      actIndex: 3,
      actNumeral: 'IV',
      actTitle: 'Taman Zen Agung',
      accentColor: Color(0xFFFFD54F), // Imperial Amber
      glowColor: Color(0xFFD97706),
      moteColor: Color(0xFFFDE68A),
      zenReflection: 'Pancaran emas kehangatan menyambut Anda di gerbang Taman Zen Agung.',
    ),
    LevelAmbiance(
      levelId: 24,
      name: 'Kunyit Kencana',
      actIndex: 3,
      actNumeral: 'IV',
      actTitle: 'Taman Zen Agung',
      accentColor: Color(0xFFFBBF24), // Saffron Ochre
      glowColor: Color(0xFFB45309),
      moteColor: Color(0xFFFEF08A),
      zenReflection: 'Kemewahan harmoni terpancar dari butiran yang mengisi cawan emas tanpa tumpah.',
    ),
    LevelAmbiance(
      levelId: 25,
      name: 'Kayu Cendana',
      actIndex: 3,
      actNumeral: 'IV',
      actTitle: 'Taman Zen Agung',
      accentColor: Color(0xFFF59E0B), // Sandalwood Gold
      glowColor: Color(0xFF92400E),
      moteColor: Color(0xFFFDE68A),
      zenReflection: 'Aroma ketenangan terwujud dalam aliran multi-cawan yang presisi dan anggun.',
    ),
    LevelAmbiance(
      levelId: 26,
      name: 'Topaz Keabadian',
      actIndex: 3,
      actNumeral: 'IV',
      actTitle: 'Taman Zen Agung',
      accentColor: Color(0xFFE8C547), // Muted Gold (Canon)
      glowColor: Color(0xFF78350F),
      moteColor: Color(0xFFFEF3C7),
      zenReflection: 'Setiap butiran laksana permata topaz yang menemukan tempat peristirahatan abadinya.',
    ),
    LevelAmbiance(
      levelId: 27,
      name: 'Fatamorgana Senja',
      actIndex: 3,
      actNumeral: 'IV',
      actTitle: 'Taman Zen Agung',
      accentColor: Color(0xFFF97316), // Warm Amber Dusk
      glowColor: Color(0xFFC2410C),
      moteColor: Color(0xFFFED7AA),
      zenReflection: 'Cahaya jingga keemasan memancarkan keagungan konsentrasi dan ketelitian Anda.',
    ),
    LevelAmbiance(
      levelId: 28,
      name: 'Batu Kuarsa Emas',
      actIndex: 3,
      actNumeral: 'IV',
      actTitle: 'Taman Zen Agung',
      accentColor: Color(0xFFFBBF24), // Golden Quartz
      glowColor: Color(0xFFB45309),
      moteColor: Color(0xFFFFFBEB),
      zenReflection: 'Menjelang garis akhir, ketenangan batin Anda terbukti kokoh bagai kuarsa.',
    ),
    LevelAmbiance(
      levelId: 29,
      name: 'Zenith Surya',
      actIndex: 3,
      actNumeral: 'IV',
      actTitle: 'Taman Zen Agung',
      accentColor: Color(0xFFFFD54F), // Molten Gold
      glowColor: Color(0xFFEA580C),
      moteColor: Color(0xFFFEF08A),
      zenReflection: 'Satu langkah menuju kesempurnaan. Seluruh elemen fisika berpadu secara mutlak.',
    ),
    LevelAmbiance(
      levelId: 30,
      name: 'Klimaks Nirwana',
      actIndex: 3,
      actNumeral: 'IV',
      actTitle: 'Taman Zen Agung',
      accentColor: Color(0xFFFFE082), // Grand Radiant Gold
      glowColor: Color(0xFFB45309),
      moteColor: Color(0xFFFFFFFF),
      zenReflection: 'Equilibrium mutlak tercapai. Seluruh 30 taman beresonansi dalam harmoni abadi.',
    ),
  ];

  /// Resolves the atmospheric ambiance for a given [levelId] (1..30).
  ///
  /// If a [config] is provided and contains colored target cups, the accent color
  /// dynamically harmonizes with the dominant cup's chromatic identity while
  /// preserving the level's distinct act mood and poetic reflection.
  static LevelAmbiance forLevel(int levelId, [LevelConfig? config]) {
    final int index = (levelId - 1).clamp(0, _ambiances.length - 1);
    final base = _ambiances[index];

    // If level has non-white cups, adapt accent color to reflect cup requirement
    if (config != null && config.cups.isNotEmpty) {
      final coloredCups = config.cups.where((c) => c.color.toARGB32() != const Color(0xFFFFFFFF).toARGB32()).toList();
      if (coloredCups.isNotEmpty) {
        final cupColor = coloredCups.first.color;
        return LevelAmbiance(
          levelId: base.levelId,
          name: base.name,
          actIndex: base.actIndex,
          actNumeral: base.actNumeral,
          actTitle: base.actTitle,
          accentColor: cupColor,
          glowColor: base.glowColor,
          moteColor: cupColor.withValues(alpha: 0.9),
          zenReflection: base.zenReflection,
        );
      }
    }

    return base;
  }
}
