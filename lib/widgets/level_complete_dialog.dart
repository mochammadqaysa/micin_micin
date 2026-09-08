import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../screens/game/game_hud.dart';

/// Full-bleed Zen victory overlay:
/// - Eliminates intrusive rectangular popups, thick borders, emojis, and standard buttons.
/// - Ambient bloom with tranquil darkened vignette.
/// - Whisper-light typography in Google Font Outfit and floating borderless glyphs.
class LevelCompleteDialog extends StatefulWidget {
  final int levelId;
  final VoidCallback? onNextLevel;
  final VoidCallback onReplay;
  final VoidCallback onMenu;

  const LevelCompleteDialog({
    super.key,
    required this.levelId,
    this.onNextLevel,
    required this.onReplay,
    required this.onMenu,
  });

  @override
  State<LevelCompleteDialog> createState() => _LevelCompleteDialogState();
}

class _LevelCompleteDialogState extends State<LevelCompleteDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bloomController;

  @override
  void initState() {
    super.initState();
    _bloomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _bloomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFinalLevel = widget.levelId >= kTotalLevels;

    return SizedBox.expand(
      child: AnimatedBuilder(
        animation: _bloomController,
        builder: (context, child) {
          final double t = _bloomController.value;

          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0 * t, sigmaY: 10.0 * t),
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.1,
                  colors: [
                    const Color(0xFFFFD54F).withValues(alpha: 0.10 * t),
                    const Color(0xFF181E24).withValues(alpha: 0.75 * t),
                    const Color(0xFF13171C).withValues(alpha: 0.88 * t),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. Subtle stage numeral or zen completion glyph
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFD54F).withValues(alpha: 0.12 * t),
                          ),
                          child: Center(
                            child: CustomPaint(
                              size: const Size(26, 26),
                              painter: isFinalLevel
                                  ? const StagesGlyphPainter(color: Color(0xFFFFD54F))
                                  : const PlayGlyphPainter(color: Color(0xFFFFD54F)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 2. Tranquil Title
                        Text(
                          isFinalLevel ? 'Selamat!' : 'Level ${widget.levelId} Selesai!',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFF1F5F9),
                            letterSpacing: 2.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),

                        // 3. Whisper Subtitle
                        Text(
                          isFinalLevel
                              ? 'Semua 30 level telah berhasil Anda selesaikan!'
                              : 'Target cangkir berhasil dipenuhi.',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            color: const Color(0xFF94A3B8).withValues(alpha: 0.80),
                            letterSpacing: 0.8,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 48),

                        // 4. Primary Zen Action (Next Level / Return to Menu)
                        if (!isFinalLevel && widget.onNextLevel != null) ...[
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: widget.onNextLevel,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 12.0,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    'Level Berikutnya',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFFFD54F),
                                      letterSpacing: 1.8,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 20,
                                    color: Color(0xFFFFD54F),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        if (isFinalLevel) ...[
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: widget.onMenu,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 12.0,
                              ),
                              child: Text(
                                'Kembali ke Menu',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFFD54F),
                                  letterSpacing: 1.8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // 5. Secondary Floating Controls: Replay (↺) & Stages (⠿)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              onPressed: widget.onReplay,
                              icon: const CustomPaint(
                                size: Size(18, 18),
                                painter: ResetGlyphPainter(
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              label: const Text(
                                'Ulangi',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF94A3B8),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            if (!isFinalLevel) ...[
                              const SizedBox(width: 16),
                              TextButton.icon(
                                onPressed: widget.onMenu,
                                icon: const CustomPaint(
                                  size: Size(18, 18),
                                  painter: StagesGlyphPainter(
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                                label: const Text(
                                  'Level',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF94A3B8),
                                    letterSpacing: 0.8,
                                  ),
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
          );
        },
      ),
    );
  }
}

