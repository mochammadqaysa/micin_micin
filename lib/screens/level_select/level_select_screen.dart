import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/player_progress.dart';
import '../../audio/audio_manager.dart';
import '../../providers/audio_provider.dart';
import '../../providers/player_progress_provider.dart';
import '../../widgets/cartoon_button.dart';
import '../../widgets/cartoon_icon_button.dart';
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
    _ActInfo(actNumber: 1, romanNumeral: 'I', title: 'Dasar', subtitle: 'Level 1 - 7', accentColor: CartoonTokens.greenTop, shadowColor: CartoonTokens.greenShadow, startLevel: 1, endLevel: 7),
    _ActInfo(actNumber: 2, romanNumeral: 'II', title: 'Filter Warna', subtitle: 'Level 8 - 15', accentColor: CartoonTokens.coralTop, shadowColor: CartoonTokens.coralShadow, startLevel: 8, endLevel: 15),
    _ActInfo(actNumber: 3, romanNumeral: 'III', title: 'Inversi Gravitasi', subtitle: 'Level 16 - 22', accentColor: CartoonTokens.cyanTop, shadowColor: CartoonTokens.cyanShadow, startLevel: 16, endLevel: 22),
    _ActInfo(actNumber: 4, romanNumeral: 'IV', title: 'Tantangan Akhir', subtitle: 'Level 23 - 30', accentColor: CartoonTokens.amberTop, shadowColor: CartoonTokens.amberShadow, startLevel: 23, endLevel: 30),
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
      backgroundColor: const Color(0xFF1E1645),
      body: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: BackgroundPainter(backgroundColor: const Color(0xFF1E1645), parallaxOffset: Offset(0, -_scrollOffset * 0.14)))),
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
          CartoonIconButton(
            icon: Icons.arrow_back_rounded, size: 42, iconSize: 22, variant: CartoonButtonVariant.amber,
            onPressed: () {
              ref.read(audioManagerProvider).playSfx(SoundType.buttonClick);
              if (context.canPop()) { context.pop(); } else { context.go('/menu'); }
            },
          ),
          const Spacer(),
          Text('Pilih Level', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2.0, shadows: const [Shadow(color: Color(0xFF000000), offset: Offset(0, 3), blurRadius: 0)])),
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
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: const Color(0xFF120E30),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF2A2060), width: 2.0),
          boxShadow: const [BoxShadow(color: Color(0xFF0A0820), offset: Offset(0, 4), blurRadius: 0)],
        ),
        child: Row(children: [
          for (int i = 0; i < _acts.length; i++)
            Expanded(child: GestureDetector(
              onTap: () => _scrollToAct(i),
              behavior: HitTestBehavior.opaque,
              child: _ActTab(act: _acts[i], isSelected: _selectedActIndex == i),
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
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1540),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: act.accentColor, width: 2.5),
        boxShadow: [BoxShadow(color: act.shadowColor, offset: const Offset(0, 5), blurRadius: 0)],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(13.5), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(height: 6, decoration: BoxDecoration(gradient: LinearGradient(colors: [act.accentColor, act.accentColor.withValues(alpha: 0.6)]))),
        Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: act.accentColor, borderRadius: BorderRadius.circular(6), boxShadow: [BoxShadow(color: act.shadowColor, offset: const Offset(0, 2), blurRadius: 0)]),
              child: Text('BABAK ${act.romanNumeral}', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5)),
            ),
            const SizedBox(width: 8),
            Text(act.subtitle, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF9186C0), letterSpacing: 0.4)),
            const Spacer(),
            Text('$completedCount/${act.totalLevels}', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w900, color: act.accentColor, letterSpacing: 0.5)),
            const SizedBox(width: 4),
            Icon(Icons.star_rounded, color: act.accentColor, size: 16),
          ]),
          const SizedBox(height: 8),
          Text(act.title, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.3, shadows: const [Shadow(color: Color(0x88000000), offset: Offset(0, 2), blurRadius: 0)])),
          const SizedBox(height: 10),
          Container(
            height: 10,
            decoration: BoxDecoration(color: const Color(0xFF0E0B28), borderRadius: BorderRadius.circular(5), border: Border.all(color: act.accentColor.withValues(alpha: 0.3), width: 1)),
            child: ClipRRect(borderRadius: BorderRadius.circular(4), child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: completionRatio.clamp(0.0, 1.0),
              child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [act.accentColor, act.accentColor.withValues(alpha: 0.75)]), boxShadow: [BoxShadow(color: act.accentColor.withValues(alpha: 0.6), blurRadius: 6)])),
            )),
          ),
        ])),
      ])),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: CartoonTokens.amberBottom,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
        boxShadow: const [BoxShadow(color: CartoonTokens.amberShadow, offset: Offset(0, 4), blurRadius: 0)],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.star_rounded, color: Colors.white, size: 17),
        const SizedBox(width: 5),
        Text('${progress.completedCount}/$kTotalLevels', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
      ]),
    );
  }
}

class _ActTab extends StatelessWidget {
  final _ActInfo act;
  final bool isSelected;
  const _ActTab({required this.act, required this.isSelected});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: isSelected ? act.accentColor : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isSelected ? [BoxShadow(color: act.shadowColor, offset: const Offset(0, 3), blurRadius: 0)] : null,
      ),
      child: Center(child: Text(act.romanNumeral, style: GoogleFonts.outfit(fontSize: 14, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600, color: isSelected ? Colors.white : const Color(0xFF6B5FA0), letterSpacing: 0.8))),
    );
  }
}
