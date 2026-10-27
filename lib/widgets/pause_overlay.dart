import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pixel_ui/pixel_ui.dart';
import '../core/pixel_terrain_tokens.dart';

/// Pixel Zen Pause Overlay for Micin Micin.
///
/// Full-bleed backdrop, tactile PixelBox center panel,
/// and PixelButton trio for ULANGI, LANJUT, and KEMBALI.
class PauseOverlay extends StatefulWidget {
  final int levelId;
  final bool isMusicEnabled;
  final VoidCallback onResume;
  final VoidCallback onMenu;
  final VoidCallback? onReplay;
  final VoidCallback? onToggleMusic;

  const PauseOverlay({
    super.key,
    this.levelId = 1,
    this.isMusicEnabled = true,
    required this.onResume,
    required this.onMenu,
    this.onReplay,
    this.onToggleMusic,
  });

  @override
  State<PauseOverlay> createState() => _PauseOverlayState();
}

class _PauseOverlayState extends State<PauseOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedChamber = widget.levelId.toString().padLeft(2, '0');

    return SizedBox.expand(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          color: PixelTerrainTokens.slate.withValues(alpha: 0.88),
          child: SafeArea(
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                final double t = _floatController.value * 2 * math.pi;
                final double replayDy = math.sin(t) * 3.0;
                final double resumeDy = math.sin(t + 1.2) * 4.0;
                final double stagesDy = math.sin(t + 2.4) * 3.0;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Header: Level badge
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 14.0),
                      child: Row(
                        children: [
                          PixelBox(
                            logicalWidth: 54,
                            logicalHeight: 10,
                            width: 216,
                            height: 40,
                            style: PixelTerrainTokens.tealBoxStyle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.grain_rounded,
                                    color: PixelTerrainTokens.sand,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '• CHAMBER $formattedChamber',
                                    style: PixelText.mulmaru(
                                      fontSize: 12,
                                      color: Colors.white,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Center panel
                    PixelBox(
                      logicalWidth: 78,
                      logicalHeight: 60,
                      width: 312,
                      height: 240,
                      style: PixelTerrainTokens.tealBoxStyle,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'PAUSED',
                              style: PixelText.mulmaru(
                                fontSize: 26,
                                color: PixelTerrainTokens.sand,
                                letterSpacing: 2.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 2,
                              width: 80,
                              color: PixelTerrainTokens.sage.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 24),

                            // Action button trio
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // REPLAY
                                Transform.translate(
                                  offset: Offset(0, replayDy),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      PixelButton(
                                        key: const Key('pause_replay'),
                                        logicalWidth: 14,
                                        logicalHeight: 14,
                                        width: 54,
                                        height: 54,
                                        normalStyle: PixelTerrainTokens.resetButtonNormal,
                                        pressedStyle: PixelTerrainTokens.resetButtonPressed,
                                        pressChildOffset: const Offset(0, 1),
                                        onPressed:
                                            widget.onReplay ?? widget.onResume,
                                        child: const Icon(
                                          Icons.refresh_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'ULANGI',
                                        style: PixelText.mulmaru(
                                          fontSize: 10,
                                          color: PixelTerrainTokens.sand,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),

                                // RESUME (hero — larger)
                                Transform.translate(
                                  offset: Offset(0, resumeDy),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      PixelButton(
                                        key: const Key('pause_resume'),
                                        logicalWidth: 17,
                                        logicalHeight: 17,
                                        width: 68,
                                        height: 68,
                                        normalStyle: PixelTerrainTokens.playButtonNormal,
                                        pressedStyle: PixelTerrainTokens.playButtonPressed,
                                        pressChildOffset: const Offset(0, 2),
                                        onPressed: widget.onResume,
                                        child: const Icon(
                                          Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: 36,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'LANJUT',
                                        style: PixelText.mulmaru(
                                          fontSize: 11,
                                          color: Colors.white,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),

                                // BACK
                                Transform.translate(
                                  offset: Offset(0, stagesDy),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      PixelButton(
                                        key: const Key('pause_stages'),
                                        logicalWidth: 14,
                                        logicalHeight: 14,
                                        width: 54,
                                        height: 54,
                                        normalStyle: PixelTerrainTokens.pauseButtonNormal,
                                        pressedStyle: PixelTerrainTokens.pauseButtonPressed,
                                        pressChildOffset: const Offset(0, 1),
                                        onPressed: widget.onMenu,
                                        child: const Icon(
                                          Icons.arrow_back_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'KEMBALI',
                                        style: PixelText.mulmaru(
                                          fontSize: 10,
                                          color: PixelTerrainTokens.sage,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom: audio toggle
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (widget.onToggleMusic != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PixelButton(
                                  logicalWidth: 11,
                                  logicalHeight: 11,
                                  width: 44,
                                  height: 44,
                                  normalStyle: widget.isMusicEnabled
                                      ? PixelTerrainTokens.audioButtonNormal
                                      : PixelTerrainTokens.pauseButtonNormal,
                                  pressedStyle: PixelTerrainTokens.audioButtonPressed,
                                  pressChildOffset: const Offset(0, 1),
                                  onPressed: widget.onToggleMusic,
                                  child: Icon(
                                    widget.isMusicEnabled
                                        ? Icons.graphic_eq_rounded
                                        : Icons.volume_off_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.isMusicEnabled ? 'MUSIC ON' : 'MUTED',
                                  style: PixelText.mulmaru(
                                    fontSize: 10,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            )
                          else
                            const SizedBox.shrink(),
                          const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
