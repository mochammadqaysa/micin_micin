import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../screens/game/game_hud.dart';

/// Full-bleed Zen Pause Overlay:
/// - Gaussian blur with darkened radial vignette.
/// - Borderless, floating glyphs with staggered breathing parallax:
///   Resume (▶), Replay (↺), and Stages (⠿).
/// - Zero card boxes, zero borders, zero standard system buttons.
class PauseOverlay extends StatefulWidget {
  final VoidCallback onResume;
  final VoidCallback onMenu;
  final VoidCallback? onReplay;

  const PauseOverlay({
    super.key,
    required this.onResume,
    required this.onMenu,
    this.onReplay,
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
    return SizedBox.expand(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14.0, sigmaY: 14.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                const Color(0xFF181E24).withValues(alpha: 0.70),
                const Color(0xFF13171C).withValues(alpha: 0.85),
                const Color(0xFF101418).withValues(alpha: 0.92),
              ],
              stops: const [0.0, 0.65, 1.0],
            ),
          ),
          child: AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              final double t = _floatController.value * 2 * math.pi;
              // Staggered sinusoidal vertical parallax drift
              final double replayDy = math.sin(t) * 3.5;
              final double resumeDy = math.sin(t + 1.2) * 4.5;
              final double stagesDy = math.sin(t + 2.4) * 3.5;

              return Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 1. Replay (↺)
                    Transform.translate(
                      offset: Offset(0, replayDy),
                      child: ZenGlyphButton(
                        key: const Key('pause_replay'),
                        tooltip: 'Ulangi',
                        size: 54,
                        painter: const ResetGlyphPainter(
                          color: Color(0xFFE2E8F0),
                        ),
                        onPressed: widget.onReplay ?? widget.onResume,
                      ),
                    ),
                    const SizedBox(width: 36),

                    // 2. Resume (▶) - Hero central glyph
                    Transform.translate(
                      offset: Offset(0, resumeDy),
                      child: ZenGlyphButton(
                        key: const Key('pause_resume'),
                        tooltip: 'Lanjutkan',
                        size: 68,
                        painter: const PlayGlyphPainter(
                          color: Color(0xFFFFD54F),
                        ),
                        onPressed: widget.onResume,
                      ),
                    ),
                    const SizedBox(width: 36),

                    // 3. Stages (⠿)
                    Transform.translate(
                      offset: Offset(0, stagesDy),
                      child: ZenGlyphButton(
                        key: const Key('pause_stages'),
                        tooltip: 'Level',
                        size: 54,
                        painter: const StagesGlyphPainter(
                          color: Color(0xFFE2E8F0),
                        ),
                        onPressed: widget.onMenu,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

