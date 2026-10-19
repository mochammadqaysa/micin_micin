import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../screens/game/game_hud.dart';
import 'cartoon_panel.dart';

/// Arcade-style Pause Overlay for Micin Micin.
///
/// Full-bleed blurred backdrop, chunky cartoon panel center-piece.
/// Three floating action buttons: RESUME (green hero), REPLAY (amber), BACK (slate).
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
        filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.1,
              colors: [
                const Color(0xFF1E1645).withValues(alpha: 0.85),
                const Color(0xFF0F0A26).withValues(alpha: 0.94),
                Colors.black.withValues(alpha: 0.98),
              ],
              stops: const [0.0, 0.65, 1.0],
            ),
          ),
          child: SafeArea(
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                final double t = _floatController.value * 2 * math.pi;
                final double replayDy = math.sin(t) * 3.5;
                final double resumeDy = math.sin(t + 1.2) * 4.5;
                final double stagesDy = math.sin(t + 2.4) * 3.5;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Header: Level badge
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 14.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1A3A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF4B3F8C).withValues(alpha: 0.7),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: Color(0xFFFFB300), size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  '• CHAMBER $formattedChamber',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Center panel
                    CartoonPanel(
                      borderRadius: 20,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // PAUSED title
                          Text(
                            'PAUSED',
                            style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 3.0,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 2,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          const SizedBox(height: 28),

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
                                    ZenGlyphButton(
                                      key: const Key('pause_replay'),
                                      tooltip: 'Ulangi Level',
                                      size: 56,
                                      isCircularBasalt: true,
                                      backgroundColor: CartoonTokens.amberTop,
                                      boxShadow: const [
                                        BoxShadow(
                                          color: CartoonTokens.amberShadow,
                                          offset: Offset(0, 4),
                                          blurRadius: 0,
                                        ),
                                      ],
                                      icon: Icons.refresh_rounded,
                                      iconSize: 28,
                                      iconColor: Colors.white,
                                      onPressed:
                                          widget.onReplay ?? widget.onResume,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'ULANGI',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                        color: CartoonTokens.amberTop,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),

                              // RESUME (hero — larger)
                              Transform.translate(
                                offset: Offset(0, resumeDy),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ZenGlyphButton(
                                      key: const Key('pause_resume'),
                                      tooltip: 'Lanjutkan',
                                      size: 72,
                                      isCircularBasalt: true,
                                      backgroundColor: CartoonTokens.greenTop,
                                      boxShadow: const [
                                        BoxShadow(
                                          color: CartoonTokens.greenShadow,
                                          offset: Offset(0, 5),
                                          blurRadius: 0,
                                        ),
                                      ],
                                      icon: Icons.play_arrow_rounded,
                                      iconSize: 44,
                                      iconColor: Colors.white,
                                      onPressed: widget.onResume,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'LANJUT',
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.4,
                                        color: CartoonTokens.greenTop,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),

                              // BACK
                              Transform.translate(
                                offset: Offset(0, stagesDy),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ZenGlyphButton(
                                      key: const Key('pause_stages'),
                                      tooltip: 'Kembali ke Level',
                                      size: 56,
                                      isCircularBasalt: true,
                                      backgroundColor: CartoonTokens.cyanTop,
                                      boxShadow: const [
                                        BoxShadow(
                                          color: CartoonTokens.cyanShadow,
                                          offset: Offset(0, 4),
                                          blurRadius: 0,
                                        ),
                                      ],
                                      icon: Icons.arrow_back_rounded,
                                      iconSize: 26,
                                      iconColor: Colors.white,
                                      onPressed: widget.onMenu,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'KEMBALI',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                        color: CartoonTokens.cyanTop,
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

                    // Bottom: audio toggle
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (widget.onToggleMusic != null)
                            GestureDetector(
                              onTap: widget.onToggleMusic,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: widget.isMusicEnabled
                                      ? const Color(0xFF1A2E44)
                                      : const Color(0xFF1C1C1C),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: widget.isMusicEnabled
                                        ? const Color(0xFF2E5080)
                                            .withValues(alpha: 0.8)
                                        : Colors.white.withValues(alpha: 0.08),
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      widget.isMusicEnabled
                                          ? Icons.graphic_eq_rounded
                                          : Icons.volume_off_rounded,
                                      color: widget.isMusicEnabled
                                          ? const Color(0xFF64B5F6)
                                          : Colors.white.withValues(alpha: 0.30),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      widget.isMusicEnabled
                                          ? 'MUSIC ON'
                                          : 'MUTED',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.5,
                                        color: widget.isMusicEnabled
                                            ? const Color(0xFF64B5F6)
                                            : Colors.white.withValues(alpha: 0.25),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
