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
import '../../widgets/neu_button.dart';
import '../../widgets/neu_container.dart';
import '../../widgets/neu_progress_bar.dart';
import '../game/painters/background_painter.dart';
import 'level_button.dart';

/// Metadata for each chapter in the stage progression.
class _ActInfo {
  final int actNumber;
  final String romanNumeral;
  final String title;
  final String subtitle;
  final Color accentColor;
  final int startLevel;
  final int endLevel;

  const _ActInfo({
    required this.actNumber,
    required this.romanNumeral,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.startLevel,
    required this.endLevel,
  });

  int get totalLevels => (endLevel - startLevel) + 1;
}

/// Pure Neumorphism stage selection screen with tactile Bento layout,
/// debossed chapter navigation, and extruded level buttons.
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

  static const List<_ActInfo> _acts = [
    _ActInfo(
      actNumber: 1,
      romanNumeral: 'I',
      title: 'Dasar',
      subtitle: 'Level 1 – 7',
      accentColor: NeuTokens.textPrimary,
      startLevel: 1,
      endLevel: 7,
    ),
    _ActInfo(
      actNumber: 2,
      romanNumeral: 'II',
      title: 'Filter Warna',
      subtitle: 'Level 8 – 15',
      accentColor: NeuTokens.accentCoral,
      startLevel: 8,
      endLevel: 15,
    ),
    _ActInfo(
      actNumber: 3,
      romanNumeral: 'III',
      title: 'Inversi Gravitasi',
      subtitle: 'Level 16 – 22',
      accentColor: NeuTokens.accentCyan,
      startLevel: 16,
      endLevel: 22,
    ),
    _ActInfo(
      actNumber: 4,
      romanNumeral: 'IV',
      title: 'Tantangan Akhir',
      subtitle: 'Level 23 – 30',
      accentColor: NeuTokens.accentAmber,
      startLevel: 23,
      endLevel: 30,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _entranceController.forward();
      }
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
      backgroundColor: NeuTokens.canvas,
      body: Stack(
        children: [
          // 1. Neumorphic Canvas Depth with scroll parallax drift
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPainter(
                backgroundColor: NeuTokens.canvas,
                parallaxOffset: Offset(0, -_scrollOffset * 0.14),
              ),
            ),
          ),

          // 2. Main Bento Content
          SafeArea(
            child: Column(
              children: [
                // Top Neumorphic Header
                _buildHeader(context, playerProgress),

                // Debossed Act Quick-Jump Navigator
                _buildActNavigator(),

                const SizedBox(height: 8),

                // Scrollable Sections
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
                              _buildActSection(
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
        ],
      ),
    );
  }

  /// Neumorphic Header with tactile circular back button, title, and progress badge.
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
            NeuIconButton(
              icon: Icons.arrow_back_rounded,
              size: 42,
              iconSize: 20,
              iconColor: NeuTokens.textSecondary,
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
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: NeuTokens.textPrimary,
                letterSpacing: 2.0,
              ),
            ),
            const Spacer(),

            // Progress Counter Pill in Sunken/Frosted Capsule
            GlassContainer(
              borderRadius: NeuTokens.radiusPill,
              enableLiveBlur: false,
              backgroundColor: NeuTokens.canvas,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: NeuTokens.accentAmber,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${progress.completedCount}/$kTotalLevels',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: NeuTokens.textPrimary,
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

  /// Sunken Debossed Act Navigator with Raised Extruded Active Pill.
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
      child: NeuContainer(
        margin: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6.0),
        padding: const EdgeInsets.all(5.0),
        borderRadius: 22,
        style: NeuStyle.inset,
        depth: 3.5,
        blur: 6.0,
        child: Row(
          children: [
            for (int i = 0; i < _acts.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => _scrollToAct(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      color: _selectedActIndex == i
                          ? NeuTokens.surfaceLight
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _selectedActIndex == i
                          ? [
                              const BoxShadow(
                                color: NeuTokens.shadowLight,
                                offset: Offset(-2, -2),
                                blurRadius: 4,
                              ),
                              const BoxShadow(
                                color: NeuTokens.shadowDark,
                                offset: Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        'Babak ${_acts[i].romanNumeral}',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          fontWeight: _selectedActIndex == i
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: _selectedActIndex == i
                              ? _acts[i].accentColor
                              : NeuTokens.textMuted,
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

  /// Builds an Act chapter section with Neumorphic card chassis and 4-column level grid.
  Widget _buildActSection({
    required _ActInfo act,
    required GlobalKey actKey,
    required PlayerProgress playerProgress,
    required int nextPlayableId,
    required double parentWidth,
  }) {
    int completedInAct = 0;
    for (int lvl = act.startLevel; lvl <= act.endLevel; lvl++) {
      if (playerProgress.isCompleted(lvl)) {
        completedInAct++;
      }
    }
    final double completionRatio = completedInAct / act.totalLevels;

    const double spacing = 10.0;
    final double colWidth = ((parentWidth - (spacing * 3)) / 4.0).floorToDouble();

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
            // 1. Extruded Neumorphic Act Hero Card
            _buildActHeroCard(act, completedInAct, completionRatio),

            const SizedBox(height: 14),

            // 2. Uniform 4-column grid of pure Neumorphic LevelButtons
            _buildActGrid(
              act: act,
              playerProgress: playerProgress,
              nextPlayableId: nextPlayableId,
              colWidth: colWidth,
              spacing: spacing,
            ),
          ],
        ),
      ),
    );
  }

  /// Extruded Neumorphic Act Card with chapter stats and sunken progress gauge.
  Widget _buildActHeroCard(
    _ActInfo act,
    int completedCount,
    double completionRatio,
  ) {
    return GlassContainer(
      width: double.infinity,
      borderRadius: 18,
      enableLiveBlur: false,
      backgroundColor: NeuTokens.canvas,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'BABAK ${act.romanNumeral}',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: act.accentColor,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '•  ${act.subtitle}',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: NeuTokens.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),

              // Act Progress Badge
              NeuContainer(
                borderRadius: 12,
                style: NeuStyle.inset,
                depth: 2.5,
                blur: 4.0,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(
                  '$completedCount/${act.totalLevels} Selesai',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: act.accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            act.title,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: NeuTokens.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Sunken Neumorphic Progress Bar
          NeuProgressBar(
            value: completionRatio,
            height: 8.0,
            fillColor: act.accentColor,
          ),
        ],
      ),
    );
  }

  /// Builds a clean, uniform 4-column grid of LevelButtons for the given Act.
  Widget _buildActGrid({
    required _ActInfo act,
    required PlayerProgress playerProgress,
    required int nextPlayableId,
    required double colWidth,
    required double spacing,
  }) {
    final List<Widget> rows = [];
    final int count = act.totalLevels;

    for (int i = 0; i < count; i += 4) {
      final int rowEnd = math.min(i + 4, count);
      final List<Widget> rowChildren = [];

      for (int j = i; j < rowEnd; j++) {
        final int levelId = act.startLevel + j;
        final isUnlocked = playerProgress.isUnlocked(levelId);
        final isCompleted = playerProgress.isCompleted(levelId);
        final isNext = (levelId == nextPlayableId) && isUnlocked && !isCompleted;

        rowChildren.add(
          SizedBox(
            width: colWidth,
            height: colWidth,
            child: LevelButton(
              levelId: levelId,
              isUnlocked: isUnlocked,
              isCompleted: isCompleted,
              accentColor: act.accentColor,
              isNextPlayable: isNext,
              onTap: () {
                ref.read(audioManagerProvider).playSfx(SoundType.buttonClick);
                if (isUnlocked) {
                  context.push('/game/$levelId');
                }
              },
            ),
          ),
        );

        if (j < rowEnd - 1) {
          rowChildren.add(SizedBox(width: spacing));
        }
      }

      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: rowChildren,
        ),
      );

      if (i + 4 < count) {
        rows.add(SizedBox(height: spacing));
      }
    }

    return Column(
      children: rows,
    );
  }
}
