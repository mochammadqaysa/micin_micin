import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/player_progress.dart';
import '../../audio/audio_manager.dart';
import '../../providers/audio_provider.dart';
import '../../providers/player_progress_provider.dart';
import '../../widgets/glass_container.dart';
import '../game/painters/background_painter.dart';
import 'level_button.dart';

/// Metadata for each of The 4 Zen Movements in the stage curriculum.
class _ActInfo {
  final int actNumber;
  final String romanNumeral;
  final String title;
  final String subtitle;
  final String mechanicsDescription;
  final Color accentColor;
  final int startLevel;
  final int endLevel;
  final int milestoneLevel;
  final String milestoneLabel;

  const _ActInfo({
    required this.actNumber,
    required this.romanNumeral,
    required this.title,
    required this.subtitle,
    required this.mechanicsDescription,
    required this.accentColor,
    required this.startLevel,
    required this.endLevel,
    required this.milestoneLevel,
    required this.milestoneLabel,
  });

  int get totalLevels => (endLevel - startLevel) + 1;
}

/// Zen stage selection screen with Bento Grid architecture, Act progression,
/// floating quick-jump navigator, and multi-plane optical parallax drift.
class LevelSelectScreen extends ConsumerStatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  ConsumerState<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends ConsumerState<LevelSelectScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _entranceController;
  double _scrollOffset = 0.0;
  int _selectedActIndex = 0;

  // GlobalKeys to enable precise smooth-scrolling to each Act
  final List<GlobalKey> _actKeys = List.generate(4, (_) => GlobalKey());

  // Deterministic floating foreground motes for near-plane optical parallax
  late final List<_ZenMote> _foregroundMotes;

  static const List<_ActInfo> _acts = [
    _ActInfo(
      actNumber: 1,
      romanNumeral: 'I',
      title: 'Aliran Lembut & Curam',
      subtitle: 'Level 1 – 7',
      mechanicsDescription: 'Gravitasi Alami & Sudut Luncuran Murni',
      accentColor: GlassTokens.textSpecular,
      startLevel: 1,
      endLevel: 7,
      milestoneLevel: 5,
      milestoneLabel: 'Taman Bebas I',
    ),
    _ActInfo(
      actNumber: 2,
      romanNumeral: 'II',
      title: 'Prisma Kromatik',
      subtitle: 'Level 8 – 15',
      mechanicsDescription: 'Filter Warna & Persilangan Jalur',
      accentColor: GlassTokens.neonRose,
      startLevel: 8,
      endLevel: 15,
      milestoneLevel: 10,
      milestoneLabel: 'Prisma Harmoni',
    ),
    _ActInfo(
      actNumber: 3,
      romanNumeral: 'III',
      title: 'Inversi Gravitasi',
      subtitle: 'Level 16 – 22',
      mechanicsDescription: 'Pembalikan Arah & Cawan Langit',
      accentColor: GlassTokens.mintFlora,
      startLevel: 16,
      endLevel: 22,
      milestoneLevel: 18,
      milestoneLabel: 'Air Mancur Zen',
    ),
    _ActInfo(
      actNumber: 4,
      romanNumeral: 'IV',
      title: 'Taman Zen Agung',
      subtitle: 'Level 23 – 30',
      mechanicsDescription: 'Harmoni Puncak & Aliran Multi-Cawan',
      accentColor: GlassTokens.radiantGold,
      startLevel: 23,
      endLevel: 30,
      milestoneLevel: 30,
      milestoneLabel: 'Klimaks Agung',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Rule δ: Harmonic Cascade Ripple entrance animation (550ms easeOutCubic)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _entranceController.forward();
      }
    });

    // Initialize 24 deterministic floating foreground motes
    final rng = math.Random(42);
    _foregroundMotes = List.generate(24, (_) {
      return _ZenMote(
        baseX: rng.nextDouble(),
        baseY: rng.nextDouble(),
        radius: 0.8 + rng.nextDouble() * 1.6,
        alpha: 0.12 + rng.nextDouble() * 0.28,
        phase: rng.nextDouble() * math.pi * 2,
        color: rng.nextBool()
            ? GlassTokens.radiantGold
            : GlassTokens.neonCyan,
      );
    });
  }

  void _onScroll() {
    if (!mounted) return;
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  void _scrollToAct(int actIndex) {
    setState(() {
      _selectedActIndex = actIndex;
    });
    ref.read(audioManagerProvider).playSfx(SoundType.buttonClick);

    final actContext = _actKeys[actIndex].currentContext;
    if (actContext != null) {
      Scrollable.ensureVisible(
        actContext,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(playerProgressProvider);
    final playerProgress =
        progressAsync.asData?.value ?? PlayerProgress.initial();

    // Determine the next playable stage (lowest unlocked & not completed)
    int nextPlayableLevelId = 1;
    for (int i = 1; i <= kTotalLevels; i++) {
      if (playerProgress.isUnlocked(i) && !playerProgress.isCompleted(i)) {
        nextPlayableLevelId = i;
        break;
      }
    }

    return Scaffold(
      backgroundColor: GlassTokens.obsidianVoid,
      body: Stack(
        children: [
          // 1. Plane 1 (Far Depth): Background Chalk Slate with scroll parallax drift
          CustomPaint(
            painter: BackgroundPainter(
              parallaxOffset: Offset(0, -_scrollOffset * 0.14),
            ),
            size: Size.infinite,
          ),

          // 2. Main Bento Content
          SafeArea(
            child: Column(
              children: [
                // Quiet Borderless Zen Header (Pinned)
                _buildHeader(context, playerProgress),

                // Floating Act Quick-Jump Capsule Navigator
                _buildActNavigator(),

                const SizedBox(height: 8),

                // Scrollable Bento Sections for The 4 Zen Movements
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(
                      left: 18.0,
                      right: 18.0,
                      bottom: 40.0,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          children: [
                            for (int i = 0; i < _acts.length; i++)
                              _buildActBentoSection(
                                act: _acts[i],
                                actKey: _actKeys[i],
                                playerProgress: playerProgress,
                                nextPlayableId: nextPlayableLevelId,
                                parentWidth: constraints.maxWidth,
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Plane 4 (Near Depth): Translucent Specular Sugar Motes drifting in foreground
          IgnorePointer(
            child: CustomPaint(
              painter: _ForegroundMotesPainter(
                scrollOffset: _scrollOffset,
                motes: _foregroundMotes,
              ),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }

  /// Quiet top bar with back navigation, 'Pilih Level' title, and total progress pill.
  Widget _buildHeader(BuildContext context, PlayerProgress progress) {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        final val = CurvedAnimation(
          parent: _entranceController,
          curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
        ).value;
        return Opacity(
          opacity: val.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, -10.0 * (1.0 - val)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: GlassTokens.textMuted,
                size: 22,
              ),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: () {
                ref.read(audioManagerProvider).playSfx(SoundType.buttonClick);
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/menu');
                }
              },
            ),
            const Spacer(),

            // Centered Title matching strict test finders
            const Text(
              'Pilih Level',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: GlassTokens.textSpecular,
                letterSpacing: 2.2,
              ),
            ),
            const Spacer(),

            // Progress Counter Pill in Frosted Glass Capsule
            GlassContainer(
              borderRadius: GlassTokens.radiusMedium,
              enableLiveBlur: false,
              backgroundColor: GlassTokens.surfaceLight,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: GlassTokens.radiantGold,
                      boxShadow: [
                        BoxShadow(
                          color: GlassTokens.radiantGoldGlow,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${progress.completedCount}/$kTotalLevels',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: GlassTokens.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Floating horizontal pill bar allowing rapid jump to any of The 4 Acts.
  Widget _buildActNavigator() {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        final val = CurvedAnimation(
          parent: _entranceController,
          curve: const Interval(0.06, 0.50, curve: Curves.easeOutCubic),
        ).value;
        return Opacity(
          opacity: val.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.96 + 0.04 * val,
            child: child,
          ),
        );
      },
      child: GlassContainer(
        margin: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6.0),
        padding: const EdgeInsets.all(4.0),
        borderRadius: 20,
        enableLiveBlur: false,
        backgroundColor: GlassTokens.surfaceLight,
        child: Row(
          children: [
            for (int i = 0; i < _acts.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => _scrollToAct(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(vertical: 7.0),
                    decoration: BoxDecoration(
                      color: _selectedActIndex == i
                          ? _acts[i].accentColor.withValues(alpha: 0.16)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _selectedActIndex == i
                            ? _acts[i].accentColor.withValues(alpha: 0.50)
                            : Colors.transparent,
                        width: 1.0,
                      ),
                      boxShadow: [
                        if (_selectedActIndex == i)
                          BoxShadow(
                            color: _acts[i].accentColor.withValues(alpha: 0.20),
                            blurRadius: 10,
                            spreadRadius: 0,
                          ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Babak ${_acts[i].romanNumeral}',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          fontWeight: _selectedActIndex == i
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: _selectedActIndex == i
                              ? _acts[i].accentColor
                              : GlassTokens.textDim,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds a complete Bento Chapter representing one Act.
  Widget _buildActBentoSection({
    required _ActInfo act,
    required GlobalKey actKey,
    required PlayerProgress playerProgress,
    required int nextPlayableId,
    required double parentWidth,
  }) {
    // Calculate Act completion stats
    int completedInAct = 0;
    for (int lvl = act.startLevel; lvl <= act.endLevel; lvl++) {
      if (playerProgress.isCompleted(lvl)) {
        completedInAct++;
      }
    }
    final double completionRatio = completedInAct / act.totalLevels;

    // Grid sizing: 4 columns
    const double spacing = 10.0;
    final double colWidth = (parentWidth - (spacing * 3)) / 4.0;
    final double milestoneWidth = (colWidth * 2) + spacing;

    final int actIdx = act.actNumber - 1;
    final double start = (actIdx * 0.12).clamp(0.0, 0.6);
    final double end = (start + 0.45).clamp(0.0, 1.0);
    final anim = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        final val = anim.value;
        return Opacity(
          opacity: val.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.94 + 0.06 * val,
            alignment: Alignment.topCenter,
            child: child,
          ),
        );
      },
      child: Padding(
        key: actKey,
        padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Act Bento Hero Card with parallax watermark
            _buildActHeroCard(act, completedInAct, completionRatio),

            const SizedBox(height: 14),

            // 2. Asymmetric Bento Grid of Stage Nodes
            _buildActBentoGrid(
              act: act,
              playerProgress: playerProgress,
              nextPlayableId: nextPlayableId,
              colWidth: colWidth,
              milestoneWidth: milestoneWidth,
              spacing: spacing,
            ),
          ],
        ),
      ),
    );
  }

  /// Glassmorphic Act Hero Card featuring poetic title and progress bar.
  Widget _buildActHeroCard(
    _ActInfo act,
    int completedCount,
    double completionRatio,
  ) {
    return GlassContainer(
      width: double.infinity,
      borderRadius: 20,
      enableLiveBlur: false,
      backgroundColor: GlassTokens.surfaceSubtle,
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          act.accentColor.withValues(alpha: 0.35),
          GlassTokens.borderShadow,
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: act.accentColor.withValues(alpha: 0.05),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ],
      child: Stack(
        children: [
          // Plane 2: Watermark Roman numeral with subtle differential scroll parallax
          Positioned(
            right: -10,
            bottom: -22,
            child: Transform.translate(
              offset: Offset(0, -(_scrollOffset * 0.04) % 15),
              child: Text(
                act.romanNumeral,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 90,
                  fontWeight: FontWeight.w800,
                  color: act.accentColor.withValues(alpha: 0.04),
                  letterSpacing: -4,
                ),
              ),
            ),
          ),

          // Inner subtle radial highlight
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: RadialGradient(
                  center: const Alignment(-0.8, -0.6),
                  radius: 1.2,
                  colors: [
                    act.accentColor.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Card content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'BABAK ${act.romanNumeral}',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: act.accentColor.withValues(alpha: 0.90),
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•  ${act.subtitle}',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: GlassTokens.textDim,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),

                    // Act Progress Pill in subtle glass
                    GlassContainer(
                      borderRadius: 10,
                      enableLiveBlur: false,
                      backgroundColor: act.accentColor.withValues(alpha: 0.10),
                      borderWidth: 0.8,
                      borderGradient: LinearGradient(
                        colors: [
                          act.accentColor.withValues(alpha: 0.40),
                          act.accentColor.withValues(alpha: 0.15),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      child: Text(
                        '$completedCount/${act.totalLevels} Selesai',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: act.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                Text(
                  act.title,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: GlassTokens.textSpecular,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),

                Text(
                  act.mechanicsDescription,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: GlassTokens.textMuted,
                  ),
                ),
                const SizedBox(height: 12),

                // Minimalist Frosted Progress Track
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Container(
                    height: 3.5,
                    width: double.infinity,
                    color: GlassTokens.obsidianVoid.withValues(alpha: 0.70),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: completionRatio.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              act.accentColor.withValues(alpha: 0.6),
                              act.accentColor,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: act.accentColor.withValues(alpha: 0.35),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the asymmetric Bento Grid tiles for the given Act.
  Widget _buildActBentoGrid({
    required _ActInfo act,
    required PlayerProgress playerProgress,
    required int nextPlayableId,
    required double colWidth,
    required double milestoneWidth,
    required double spacing,
  }) {
    Widget makeButton(int levelId, {bool isMilestone = false}) {
      final isUnlocked = playerProgress.isUnlocked(levelId);
      final isCompleted = playerProgress.isCompleted(levelId);
      final isNext = (levelId == nextPlayableId) && isUnlocked && !isCompleted;

      return LevelButton(
        levelId: levelId,
        isUnlocked: isUnlocked,
        isCompleted: isCompleted,
        accentColor: act.accentColor,
        isNextPlayable: isNext,
        isMilestone: isMilestone,
        milestoneLabel: isMilestone ? act.milestoneLabel : null,
        onTap: () {
          ref.read(audioManagerProvider).playSfx(SoundType.buttonClick);
          if (isUnlocked) {
            context.push('/game/$levelId');
          }
        },
      );
    }

    // Compose layout depending on the act's stage count
    if (act.actNumber == 1) {
      // Act I (7 levels: 1..7, Milestone: 5)
      // Row 1: 1, 2, 3, 4 (4 regular tiles)
      // Row 2: 5 (Milestone: 2 cols), 6, 7 (2 cols) -> total 4 cols
      return Column(
        children: [
          Row(
            children: [
              for (int i = 1; i <= 4; i++) ...[
                SizedBox(
                  width: colWidth,
                  height: colWidth,
                  child: makeButton(i),
                ),
                if (i < 4) SizedBox(width: spacing),
              ],
            ],
          ),
          SizedBox(height: spacing),
          Row(
            children: [
              SizedBox(
                width: milestoneWidth,
                height: colWidth,
                child: makeButton(5, isMilestone: true),
              ),
              SizedBox(width: spacing),
              SizedBox(
                width: colWidth,
                height: colWidth,
                child: makeButton(6),
              ),
              SizedBox(width: spacing),
              SizedBox(
                width: colWidth,
                height: colWidth,
                child: makeButton(7),
              ),
            ],
          ),
        ],
      );
    } else if (act.actNumber == 2) {
      // Act II (8 levels: 8..15, Milestone: 10)
      // Row 1: 8, 9 (2 cols), 10 (Milestone: 2 cols) -> total 4 cols
      // Row 2: 11, 12, 13, 14 (4 cols)
      // Row 3: 15 (1 col) + peaceful decorative flow badge (3 cols)
      return Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: colWidth,
                height: colWidth,
                child: makeButton(8),
              ),
              SizedBox(width: spacing),
              SizedBox(
                width: colWidth,
                height: colWidth,
                child: makeButton(9),
              ),
              SizedBox(width: spacing),
              SizedBox(
                width: milestoneWidth,
                height: colWidth,
                child: makeButton(10, isMilestone: true),
              ),
            ],
          ),
          SizedBox(height: spacing),
          Row(
            children: [
              for (int i = 11; i <= 14; i++) ...[
                SizedBox(
                  width: colWidth,
                  height: colWidth,
                  child: makeButton(i),
                ),
                if (i < 14) SizedBox(width: spacing),
              ],
            ],
          ),
          SizedBox(height: spacing),
          Row(
            children: [
              SizedBox(
                width: colWidth,
                height: colWidth,
                child: makeButton(15),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: _buildDecorativeZenBadge(
                  label: 'Prisma Rose & Aqua Mengalir Murni',
                  accentColor: act.accentColor,
                  height: colWidth,
                ),
              ),
            ],
          ),
        ],
      );
    } else if (act.actNumber == 3) {
      // Act III (7 levels: 16..22, Milestone: 18)
      // Row 1: 16, 17 (2 cols), 18 (Milestone: 2 cols)
      // Row 2: 19, 20, 21, 22 (4 cols)
      return Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: colWidth,
                height: colWidth,
                child: makeButton(16),
              ),
              SizedBox(width: spacing),
              SizedBox(
                width: colWidth,
                height: colWidth,
                child: makeButton(17),
              ),
              SizedBox(width: spacing),
              SizedBox(
                width: milestoneWidth,
                height: colWidth,
                child: makeButton(18, isMilestone: true),
              ),
            ],
          ),
          SizedBox(height: spacing),
          Row(
            children: [
              for (int i = 19; i <= 22; i++) ...[
                SizedBox(
                  width: colWidth,
                  height: colWidth,
                  child: makeButton(i),
                ),
                if (i < 22) SizedBox(width: spacing),
              ],
            ],
          ),
        ],
      );
    } else {
      // Act IV (8 levels: 23..30, Milestones: 25 & 30)
      // Row 1: 23, 24 (2 cols), 25 (Milestone: 2 cols)
      // Row 2: 26, 27, 28, 29 (4 cols)
      // Row 3: 30 (Milestone: 2 cols) + Zen Grand Garden emblem badge (2 cols)
      return Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: colWidth,
                height: colWidth,
                child: makeButton(23),
              ),
              SizedBox(width: spacing),
              SizedBox(
                width: colWidth,
                height: colWidth,
                child: makeButton(24),
              ),
              SizedBox(width: spacing),
              SizedBox(
                width: milestoneWidth,
                height: colWidth,
                child: makeButton(25, isMilestone: true),
              ),
            ],
          ),
          SizedBox(height: spacing),
          Row(
            children: [
              for (int i = 26; i <= 29; i++) ...[
                SizedBox(
                  width: colWidth,
                  height: colWidth,
                  child: makeButton(i),
                ),
                if (i < 29) SizedBox(width: spacing),
              ],
            ],
          ),
          SizedBox(height: spacing),
          Row(
            children: [
              SizedBox(
                width: milestoneWidth,
                height: colWidth,
                child: makeButton(30, isMilestone: true),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: _buildDecorativeZenBadge(
                  label: 'Keseimbangan Abadi 30 Taman',
                  accentColor: act.accentColor,
                  height: colWidth,
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  /// Subtle zen quote / aesthetic pill card to fill remaining Bento width elegantly.
  Widget _buildDecorativeZenBadge({
    required String label,
    required Color accentColor,
    required double height,
  }) {
    return GlassContainer(
      height: height,
      borderRadius: 18,
      enableLiveBlur: false,
      backgroundColor: GlassTokens.surfaceSubtle,
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: accentColor.withValues(alpha: 0.60),
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}

/// A deterministic floating light mote for foreground depth parallax.
class _ZenMote {
  final double baseX;
  final double baseY;
  final double radius;
  final double alpha;
  final double phase;
  final Color color;

  _ZenMote({
    required this.baseX,
    required this.baseY,
    required this.radius,
    required this.alpha,
    required this.phase,
    required this.color,
  });
}

/// Pure canvas painter rendering subtle translucent foreground motes
/// that shift with differential optical parallax velocity.
class _ForegroundMotesPainter extends CustomPainter {
  final double scrollOffset;
  final List<_ZenMote> motes;

  _ForegroundMotesPainter({
    required this.scrollOffset,
    required this.motes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final mote in motes) {
      final double dy =
          (mote.baseY * size.height - scrollOffset * 0.22) % size.height;
      final double actualY = dy < 0 ? dy + size.height : dy;
      final double actualX = mote.baseX * size.width +
          math.sin(mote.phase + scrollOffset * 0.004) * 8.0;

      final paint = Paint()
        ..color = mote.color.withValues(alpha: mote.alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(actualX, actualY), mote.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ForegroundMotesPainter oldDelegate) =>
      oldDelegate.scrollOffset != scrollOffset;
}
