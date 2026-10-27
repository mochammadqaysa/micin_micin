import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_ui/pixel_ui.dart';
import '../../core/constants.dart';
import '../../core/pixel_terrain_tokens.dart';
import '../../models/player_progress.dart';
import '../../audio/audio_manager.dart';
import '../../providers/audio_provider.dart';
import '../../providers/player_progress_provider.dart';
import '../game/painters/background_painter.dart';
import 'level_button.dart';

class _ActInfo {
  final int actNumber;
  final String romanNumeral;
  final String title;
  final String subtitle;
  final Color accentColor;
  final Color shadowColor;
  final int startLevel;
  final int endLevel;
  const _ActInfo({
    required this.actNumber,
    required this.romanNumeral,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.shadowColor,
    required this.startLevel,
    required this.endLevel,
  });
  int get totalLevels => (endLevel - startLevel) + 1;
}

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
  final List<GlobalKey> _actKeys = List.generate(4, (_) => GlobalKey());

  static const List<_ActInfo> _acts = [
    _ActInfo(
      actNumber: 1,
      romanNumeral: 'I',
      title: 'Dasar',
      subtitle: 'Level 1 - 7',
      accentColor: PixelTerrainTokens.sage,
      shadowColor: PixelTerrainTokens.slate,
      startLevel: 1,
      endLevel: 7,
    ),
    _ActInfo(
      actNumber: 2,
      romanNumeral: 'II',
      title: 'Filter Warna',
      subtitle: 'Level 8 - 15',
      accentColor: PixelTerrainTokens.teal,
      shadowColor: PixelTerrainTokens.slate,
      startLevel: 8,
      endLevel: 15,
    ),
    _ActInfo(
      actNumber: 3,
      romanNumeral: 'III',
      title: 'Inversi Gravitasi',
      subtitle: 'Level 16 - 22',
      accentColor: PixelTerrainTokens.moss,
      shadowColor: PixelTerrainTokens.slate,
      startLevel: 16,
      endLevel: 22,
    ),
    _ActInfo(
      actNumber: 4,
      romanNumeral: 'IV',
      title: 'Tantangan Akhir',
      subtitle: 'Level 23 - 30',
      accentColor: PixelTerrainTokens.sand,
      shadowColor: PixelTerrainTokens.slate,
      startLevel: 23,
      endLevel: 30,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _entranceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 550));
    WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _entranceController.forward(); });
  }

  void _onScroll() { if (!mounted) return; setState(() { _scrollOffset = _scrollController.offset; }); }

  void _scrollToAct(int actIndex) {
    setState(() { _selectedActIndex = actIndex; });
    ref.read(audioManagerProvider).playSfx(SoundType.buttonClick);
    final actContext = _actKeys[actIndex].currentContext;
    if (actContext != null) { Scrollable.ensureVisible(actContext, duration: const Duration(milliseconds: 550), curve: Curves.easeOutCubic); }
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
    final playerProgress = progressAsync.asData?.value ?? PlayerProgress.initial();
    int nextPlayableLevelId = 1;
    for (int i = 1; i <= kTotalLevels; i++) {
      if (playerProgress.isUnlocked(i) && !playerProgress.isCompleted(i)) { nextPlayableLevelId = i; break; }
    }
    return Scaffold(
      backgroundColor: PixelTerrainTokens.slate,
      body: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: BackgroundPainter(backgroundColor: PixelTerrainTokens.slate, parallaxOffset: Offset(0, -_scrollOffset * 0.14)))),
        SafeArea(child: Column(children: [
          _buildHeader(context, playerProgress),
          _buildActNavigator(),
          const SizedBox(height: 8),
          Expanded(child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 18.0, right: 18.0, bottom: 40.0),
            child: LayoutBuilder(builder: (context, constraints) {
              return Column(children: [
                for (int i = 0; i < _acts.length; i++)
                  _buildActSection(act: _acts[i], actKey: _actKeys[i], playerProgress: playerProgress, nextPlayableId: nextPlayableLevelId, parentWidth: constraints.maxWidth),
              ]);
            }),
          )),
        ])),
      ]),
    );
  }

  Widget _buildHeader(BuildContext context, PlayerProgress progress) {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        final val = CurvedAnimation(parent: _entranceController, curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic)).value;
        return Opacity(opacity: val.clamp(0.0, 1.0), child: Transform.translate(offset: Offset(0, -10.0 * (1.0 - val)), child: child));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(children: [
          PixelButton(
            logicalWidth: 11,
            logicalHeight: 11,
            width: 44,
            height: 44,
            normalStyle: PixelTerrainTokens.pauseButtonNormal,
            pressedStyle: PixelTerrainTokens.pauseButtonPressed,
            pressChildOffset: const Offset(0, 1),
            onPressed: () {
              ref.read(audioManagerProvider).playSfx(SoundType.buttonClick);
              if (context.canPop()) { context.pop(); } else { context.go('/menu'); }
            },
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
          ),
          const Spacer(),
          Text(
            'Pilih Level',
            style: PixelText.mulmaru(
              fontSize: 20,
              color: PixelTerrainTokens.sand,
              letterSpacing: 2.0,
            ),
          ),
          const Spacer(),
          _ProgressBadge(progress: progress),
        ]),
      ),
    );
  }

  Widget _buildActNavigator() {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        final val = CurvedAnimation(parent: _entranceController, curve: const Interval(0.06, 0.50, curve: Curves.easeOutCubic)).value;
        return Opacity(opacity: val.clamp(0.0, 1.0), child: Transform.scale(scale: 0.96 + 0.04 * val, child: child));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6.0),
        padding: const EdgeInsets.all(4.0),
        child: Row(children: [
          for (int i = 0; i < _acts.length; i++)
            Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: GestureDetector(
                onTap: () => _scrollToAct(i),
                behavior: HitTestBehavior.opaque,
                child: _ActTab(act: _acts[i], isSelected: _selectedActIndex == i),
              ),
            )),
        ]),
      ),
    );
  }

  Widget _buildActSection({required _ActInfo act, required GlobalKey actKey, required PlayerProgress playerProgress, required int nextPlayableId, required double parentWidth}) {
    int completedInAct = 0;
    for (int lvl = act.startLevel; lvl <= act.endLevel; lvl++) { if (playerProgress.isCompleted(lvl)) completedInAct++; }
    final double completionRatio = completedInAct / act.totalLevels;
    const double spacing = 10.0;
    final double colWidth = ((parentWidth - (spacing * 3)) / 4.0).floorToDouble();
    final int actIdx = act.actNumber - 1;
    final double start = (actIdx * 0.12).clamp(0.0, 0.6);
    final double end = (start + 0.45).clamp(0.0, 1.0);
    final anim = CurvedAnimation(parent: _entranceController, curve: Interval(start, end, curve: Curves.easeOutCubic));
    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        final val = anim.value;
        return Opacity(opacity: val.clamp(0.0, 1.0), child: Transform.scale(scale: 0.94 + 0.06 * val, alignment: Alignment.topCenter, child: child));
      },
      child: Padding(key: actKey, padding: const EdgeInsets.only(top: 24.0, bottom: 8.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildActHeroCard(act, completedInAct, completionRatio),
        const SizedBox(height: 14),
        _buildActGrid(act: act, playerProgress: playerProgress, nextPlayableId: nextPlayableId, colWidth: colWidth, spacing: spacing),
      ])),
    );
  }

  Widget _buildActHeroCard(_ActInfo act, int completedCount, double completionRatio) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: PixelTerrainTokens.tealSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: act.accentColor, width: 2),
        boxShadow: const [
          BoxShadow(
            color: PixelTerrainTokens.slateBedrock,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PixelBox(
                logicalWidth: 20,
                logicalHeight: 7,
                style: PixelTerrainTokens.mossBoxStyle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  child: Text(
                    'BABAK ${act.romanNumeral}',
                    style: PixelText.mulmaru(
                      fontSize: 11,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                act.subtitle,
                style: PixelText.mulmaru(
                  fontSize: 10,
                  color: PixelTerrainTokens.sage.withValues(alpha: 0.8),
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                '$completedCount/${act.totalLevels}',
                style: PixelText.mulmaru(
                  fontSize: 11,
                  color: act.accentColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.star_rounded, color: act.accentColor, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            act.title,
            style: PixelText.mulmaru(
              fontSize: 18,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          PixelBox(
            logicalWidth: 60,
            logicalHeight: 2,
            style: PixelTerrainTokens.slateBoxStyle,
            child: SizedBox(
              height: 8,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: completionRatio.clamp(0.0, 1.0),
                  child: Container(color: act.accentColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActGrid({required _ActInfo act, required PlayerProgress playerProgress, required int nextPlayableId, required double colWidth, required double spacing}) {
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
        rowChildren.add(SizedBox(width: colWidth, height: colWidth, child: LevelButton(
          levelId: levelId, isUnlocked: isUnlocked, isCompleted: isCompleted,
          accentColor: act.accentColor, isNextPlayable: isNext,
          onTap: () { ref.read(audioManagerProvider).playSfx(SoundType.buttonClick); if (isUnlocked) context.push('/game/$levelId'); },
        )));
        if (j < rowEnd - 1) rowChildren.add(SizedBox(width: spacing));
      }
      rows.add(Row(mainAxisAlignment: MainAxisAlignment.start, children: rowChildren));
      if (i + 4 < count) rows.add(SizedBox(height: spacing));
    }
    return Column(children: rows);
  }
}

class _ProgressBadge extends StatelessWidget {
  final PlayerProgress progress;
  const _ProgressBadge({required this.progress});
  @override
  Widget build(BuildContext context) {
    return PixelBox(
      logicalWidth: 24,
      logicalHeight: 11,
      style: PixelTerrainTokens.mossBoxStyle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, color: PixelTerrainTokens.sand, size: 16),
            const SizedBox(width: 5),
            Text(
              '${progress.completedCount}/$kTotalLevels',
              style: PixelText.mulmaru(
                fontSize: 11,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActTab extends StatelessWidget {
  final _ActInfo act;
  final bool isSelected;
  const _ActTab({required this.act, required this.isSelected});
  @override
  Widget build(BuildContext context) {
    return PixelBox(
      logicalWidth: 18,
      logicalHeight: 9,
      style: isSelected ? PixelTerrainTokens.mossBoxStyle : PixelTerrainTokens.slateBoxStyle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Center(
          child: Text(
            act.romanNumeral,
            style: PixelText.mulmaru(
              fontSize: 11,
              color: isSelected ? Colors.white : PixelTerrainTokens.sage,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}

