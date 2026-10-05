import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../models/level_ambiance.dart';
import '../models/level_config.dart';
import 'glass_container.dart';
import 'glass_pill_button.dart';

/// Full-bleed Modern Minimalist & Glassmorphism victory overlay:
/// - Radiant gold bloom wash and floating ambient victory motes.
/// - Diegetic stage header: Chamber number and Act identifier.
/// - Harmonized equilibrium state focal glass chip.
/// - Tactile GlassPillButton for progression and secondary controls.
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
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 1. Equilibrium glass chip
                            GlassContainer(
                              enableLiveBlur: false,
                              borderRadius: GlassTokens.radiusPill,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              backgroundColor: GlassTokens.surfaceLight.withValues(alpha: 0.70),
                              borderGradient: LinearGradient(
                                colors: [
                                  _ambiance.accentColor.withValues(alpha: 0.40 + pulse * 0.30),
                                  GlassTokens.borderHighlight,
                                  _ambiance.accentColor.withValues(alpha: 0.15),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _ambiance.accentColor.withValues(alpha: 0.15 + pulse * 0.15),
                                  blurRadius: 14,
                                ),
                              ],
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _ambiance.accentColor,
                                      boxShadow: [
                                        BoxShadow(
                                          color: _ambiance.accentColor.withValues(alpha: 0.8),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'EQUILIBRIUM • ${_ambiance.name.toUpperCase()}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: _ambiance.accentColor,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 2. Tranquil Title
                            Text(
                              isFinalLevel ? 'Selamat!' : 'Level ${widget.levelId} Selesai!',
                              style: GoogleFonts.outfit(
                                fontSize: 26,
                                fontWeight: FontWeight.w400,
                                color: GlassTokens.textSpecular,
                                letterSpacing: 2.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),

                            // 3. Whisper Subtitle
                            Text(
                              isFinalLevel
                                  ? 'Semua 30 level telah berhasil Anda selesaikan!'
                                  : _ambiance.zenReflection,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w300,
                                color: GlassTokens.textMuted,
                                letterSpacing: 0.6,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 40),

                            // 4. Primary Glass Action (Proceed / Return to Menu)
                            if (!isFinalLevel && widget.onNextLevel != null) ...[
                              GlassPillButton(
                                key: const Key('dialog_next_level'),
                                label: 'Level Berikutnya',
                                icon: Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                  color: _ambiance.accentColor,
                                ),
                                isPrimary: true,
                                accentGlow: _ambiance.accentColor,
                                textStyle: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: _ambiance.accentColor,
                                  letterSpacing: 1.0,
                                ),
                                onTap: widget.onNextLevel!,
                              ),
                              const SizedBox(height: 18),
                            ],

                            if (isFinalLevel) ...[
                              GlassPillButton(
                                key: const Key('dialog_menu'),
                                label: 'Kembali ke Menu',
                                icon: Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 18,
                                  color: _ambiance.accentColor,
                                ),
                                isPrimary: true,
                                accentGlow: _ambiance.accentColor,
                                textStyle: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: _ambiance.accentColor,
                                  letterSpacing: 1.0,
                                ),
                                onTap: widget.onMenu,
                              ),
                              const SizedBox(height: 18),
                            ],

                            // 5. Secondary Glass Controls: Replay (↺) & Stages (←)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GlassPillButton(
                                  key: const Key('dialog_replay'),
                                  label: 'Ulangi',
                                  icon: const Icon(
                                    Icons.refresh_rounded,
                                    size: 16,
                                    color: GlassTokens.textMuted,
                                  ),
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  textStyle: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: GlassTokens.textMuted,
                                    letterSpacing: 0.8,
                                  ),
                                  onTap: widget.onReplay,
                                ),
                                if (!isFinalLevel) ...[
                                  const SizedBox(width: 14),
                                  GlassPillButton(
                                    key: const Key('dialog_menu_level'),
                                    label: 'Level',
                                    icon: const Icon(
                                      Icons.arrow_back_rounded,
                                      size: 16,
                                      color: GlassTokens.textMuted,
                                    ),
                                    height: 40,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    textStyle: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: GlassTokens.textMuted,
                                      letterSpacing: 0.8,
                                    ),
                                    onTap: widget.onMenu,
                                  ),
                                ],
                              ],
                            ),
                          ],
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

