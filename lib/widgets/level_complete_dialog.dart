import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pixel_ui/pixel_ui.dart';
import '../core/constants.dart';
import '../core/pixel_terrain_tokens.dart';
import '../core/theme.dart';
import '../models/level_ambiance.dart';
import '../models/level_config.dart';


/// Full-bleed Chunky Arcade victory overlay:
/// - Celebratory pop-scale star ratings and level score badge.
/// - 3D extruded CartoonButton progression actions (Next, Replay, Menu).
/// - Modern typography in Google Fonts Outfit.
class LevelCompleteDialog extends StatefulWidget {
  final int levelId;
  final LevelConfig? levelConfig;
  final VoidCallback? onNextLevel;
  final VoidCallback onReplay;
  final VoidCallback onMenu;

  const LevelCompleteDialog({
    super.key,
    required this.levelId,
    this.levelConfig,
    this.onNextLevel,
    required this.onReplay,
    required this.onMenu,
  });

  @override
  State<LevelCompleteDialog> createState() => _LevelCompleteDialogState();
}

class _LevelCompleteDialogState extends State<LevelCompleteDialog>
    with TickerProviderStateMixin {
  late final AnimationController _bloomController;
  late final AnimationController _pulseController;
  late final AnimationController _motesController;
  late final LevelAmbiance _ambiance;
  late final List<_VictoryMote> _motes;

  @override
  void initState() {
    super.initState();
    _ambiance = LevelAmbiance.forLevel(widget.levelId, widget.levelConfig);

    _bloomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // 24 ambient floating victory motes
    final rng = math.Random(widget.levelId * 31);
    _motes = List.generate(24, (_) {
      return _VictoryMote(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        radius: 0.8 + rng.nextDouble() * 1.8,
        speedY: -0.0008 - rng.nextDouble() * 0.0016,
        alpha: 0.15 + rng.nextDouble() * 0.45,
      );
    });

    _motesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..addListener(() {
        for (final m in _motes) {
          m.y += m.speedY;
          if (m.y < 0.0) {
            m.y = 1.0;
            m.x = rng.nextDouble();
          }
        }
        setState(() {});
      })
     ..repeat();
  }

  @override
  void dispose() {
    _bloomController.dispose();
    _pulseController.dispose();
    _motesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFinalLevel = widget.levelId >= kTotalLevels;

    return SizedBox.expand(
      child: AnimatedBuilder(
        animation: Listenable.merge([_bloomController, _pulseController]),
        builder: (context, child) {
          final double t = _bloomController.value;
          final double pulse = _pulseController.value;

          return BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: GlassTokens.blurOverlay * t,
              sigmaY: GlassTokens.blurOverlay * t,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    GlassTokens.radiantGold.withValues(alpha: (0.16 + pulse * 0.08) * t),
                    _ambiance.accentColor.withValues(alpha: 0.10 * t),
                    GlassTokens.obsidianVoid.withValues(alpha: 0.88 * t),
                    GlassTokens.obsidianVoid.withValues(alpha: 0.96 * t),
                  ],
                  stops: const [0.0, 0.35, 0.70, 1.0],
                ),
              ),
              child: Stack(
                children: [
                  // Floating ambient victory motes
                  CustomPaint(
                    painter: _VictoryMotesPainter(_motes, _ambiance.moteColor, t),
                    size: Size.infinite,
                  ),

                  // Top Navigation & Diegetic Stage Header
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'CHAMBER',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.40),
                                  letterSpacing: 2.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.levelId} / $kTotalLevels',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: _ambiance.accentColor,
                                  letterSpacing: 1.8,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF181C21).withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF262A30),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              'ACT ${_ambiance.actNumeral}',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: _ambiance.accentColor.withValues(alpha: 0.9),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Central Content
                  SafeArea(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: PixelBox(
                          logicalWidth: 84,
                          logicalHeight: 116,
                          style: PixelTerrainTokens.tealBoxStyle,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 1. Pixel Zen Victory Badge
                                PixelBox(
                                  logicalWidth: 16,
                                  logicalHeight: 14,
                                  style: PixelTerrainTokens.mossBoxStyle,
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Icon(
                                      Icons.emoji_events_rounded,
                                      size: 36,
                                      color: PixelTerrainTokens.sand,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // 2. Three Pixel Star Podiums
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    PixelBox(
                                      logicalWidth: 8,
                                      logicalHeight: 8,
                                      width: 30,
                                      height: 30,
                                      style: PixelTerrainTokens.sandBoxStyle,
                                      child: const Center(
                                        child: Icon(Icons.star_rounded, size: 18, color: PixelTerrainTokens.slate),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    PixelBox(
                                      logicalWidth: 10,
                                      logicalHeight: 10,
                                      width: 40,
                                      height: 40,
                                      style: PixelTerrainTokens.sandBoxStyle,
                                      child: const Center(
                                        child: Icon(Icons.star_rounded, size: 26, color: PixelTerrainTokens.slate),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    PixelBox(
                                      logicalWidth: 8,
                                      logicalHeight: 8,
                                      width: 30,
                                      height: 30,
                                      style: PixelTerrainTokens.sandBoxStyle,
                                      child: const Center(
                                        child: Icon(Icons.star_rounded, size: 18, color: PixelTerrainTokens.slate),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // 3. Victory Title
                                Text(
                                  isFinalLevel ? 'Selamat!' : 'Level ${widget.levelId} Selesai!',
                                  style: PixelText.mulmaru(
                                    fontSize: 18,
                                    color: PixelTerrainTokens.sand,
                                    letterSpacing: 1.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),

                                // 4. Subtitle
                                Text(
                                  isFinalLevel
                                      ? 'Semua 30 level telah berhasil Anda selesaikan!'
                                      : 'Target butiran berhasil dipenuhi.',
                                  style: PixelText.mulmaru(
                                    fontSize: 11,
                                    color: PixelTerrainTokens.sage.withValues(alpha: 0.9),
                                    letterSpacing: 0.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 10),

                                // 5. Accuracy Chip
                                PixelBox(
                                  logicalWidth: 42,
                                  logicalHeight: 9,
                                  width: 168,
                                  height: 36,
                                  style: PixelTerrainTokens.slateBoxStyle,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          size: 14,
                                          color: PixelTerrainTokens.sage,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Akurasi 100%',
                                          style: PixelText.mulmaru(
                                            fontSize: 10,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // 6. Primary Action Button
                                if (!isFinalLevel && widget.onNextLevel != null) ...[
                                  PixelButton(
                                    key: const Key('dialog_next_level'),
                                    logicalWidth: 68,
                                    logicalHeight: 12,
                                    width: 272,
                                    height: 46,
                                    normalStyle: PixelTerrainTokens.playButtonNormal,
                                    pressedStyle: PixelTerrainTokens.playButtonPressed,
                                    pressChildOffset: const Offset(0, 1),
                                    onPressed: widget.onNextLevel!,
                                    child: Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Level Berikutnya',
                                            style: PixelText.mulmaru(
                                              fontSize: 13,
                                              color: Colors.white,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],

                                if (isFinalLevel) ...[
                                  PixelButton(
                                    key: const Key('dialog_menu'),
                                    logicalWidth: 68,
                                    logicalHeight: 12,
                                    width: 272,
                                    height: 46,
                                    normalStyle: PixelTerrainTokens.playButtonNormal,
                                    pressedStyle: PixelTerrainTokens.playButtonPressed,
                                    pressChildOffset: const Offset(0, 1),
                                    onPressed: widget.onMenu,
                                    child: Center(
                                      child: Text(
                                        'Kembali ke Menu',
                                        style: PixelText.mulmaru(
                                          fontSize: 13,
                                          color: Colors.white,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],

                                // 7. Secondary Controls: Replay & Level Select
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    PixelButton(
                                      key: const Key('dialog_replay'),
                                      logicalWidth: 32,
                                      logicalHeight: 10,
                                      width: 128,
                                      height: 38,
                                      normalStyle: PixelTerrainTokens.resetButtonNormal,
                                      pressedStyle: PixelTerrainTokens.resetButtonPressed,
                                      pressChildOffset: const Offset(0, 1),
                                      onPressed: widget.onReplay,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.refresh_rounded,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Ulangi',
                                            style: PixelText.mulmaru(
                                              fontSize: 11,
                                              color: Colors.white,
                                              letterSpacing: 0.6,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!isFinalLevel) ...[
                                      const SizedBox(width: 12),
                                      PixelButton(
                                        key: const Key('dialog_menu_level'),
                                        logicalWidth: 32,
                                        logicalHeight: 10,
                                        width: 128,
                                        height: 38,
                                        normalStyle: PixelTerrainTokens.actionButtonNormal,
                                        pressedStyle: PixelTerrainTokens.actionButtonPressed,
                                        pressChildOffset: const Offset(0, 1),
                                        onPressed: widget.onMenu,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.arrow_back_rounded,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Level',
                                              style: PixelText.mulmaru(
                                                fontSize: 11,
                                                color: Colors.white,
                                                letterSpacing: 0.6,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
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
        },
      ),
    );
  }
}

class _VictoryMote {
  double x;
  double y;
  final double radius;
  final double speedY;
  final double alpha;

  _VictoryMote({
    required this.x,
    required this.y,
    required this.radius,
    required this.speedY,
    required this.alpha,
  });
}

class _VictoryMotesPainter extends CustomPainter {
  final List<_VictoryMote> motes;
  final Color moteColor;
  final double progress;

  _VictoryMotesPainter(this.motes, this.moteColor, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final m in motes) {
      final paint = Paint()
        ..color = moteColor.withValues(alpha: m.alpha * progress)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(m.x * size.width, m.y * size.height),
        m.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VictoryMotesPainter oldDelegate) => true;
}

