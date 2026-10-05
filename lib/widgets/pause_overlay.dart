import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../screens/game/game_hud.dart';
import 'glass_container.dart';

/// Full-bleed Modern Minimalist & Glassmorphism Pause Overlay:
/// - Gaussian blur (sigma=24.0) with obsidian void radial vignette.
/// - Top-Left: Whispered chamber indicator ("• CHAMBER XX") with Neon Cyan pulse.
/// - Centerpiece: Spaced "PAUSED" typography and 3 floating action buttons with staggered breathing offsets:
///   Resume (▶) as hero central glyph with Neon Cyan aura, Replay (↺), and Stages (⠿).
/// - Bottom-Left: Audio soundscape capsule toggle ("CHIMES ON / MUTED").
/// - Zero ink meter / zero unwanted debug metrics.
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
        filter: ImageFilter.blur(
          sigmaX: GlassTokens.blurOverlay,
          sigmaY: GlassTokens.blurOverlay,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                GlassTokens.surfaceLight.withValues(alpha: 0.70),
                GlassTokens.obsidianVoid.withValues(alpha: 0.88),
                GlassTokens.obsidianVoid.withValues(alpha: 0.96),
              ],
              stops: const [0.0, 0.65, 1.0],
            ),
          ),
          child: SafeArea(
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                final double t = _floatController.value * 2 * math.pi;
                // Staggered sinusoidal vertical parallax drift
                final double replayDy = math.sin(t) * 3.5;
                final double resumeDy = math.sin(t + 1.2) * 4.5;
                final double stagesDy = math.sin(t + 2.4) * 3.5;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 1. Top Header: Whispered metadata
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 14.0,
                      ),
                      child: Row(
                        children: [
                          // Glowing Neon Cyan dot indicator
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: GlassTokens.neonCyan.withValues(
                                alpha: 0.60 + 0.35 * _floatController.value,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: GlassTokens.neonCyan.withValues(alpha: 0.40),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'CHAMBER $formattedChamber',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: GlassTokens.textMuted,
                              letterSpacing: 2.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. Centerpiece: State title, floating glyph cluster, and subtitle
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ambient Wide-Spaced State Typography
                        Text(
                          'PAUSED',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 8.0,
                            color: GlassTokens.textSpecular.withValues(alpha: 0.40),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 24,
                          height: 1,
                          color: GlassTokens.borderHighlight,
                        ),
                        const SizedBox(height: 36),

                        // Action Nodes Cluster with Trigonometric Floating Micro-Parallax
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Secondary Action Left: Ulangi Chamber ('↺')
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
                                    icon: Icons.refresh_rounded,
                                    iconSize: 26,
                                    iconColor: GlassTokens.textSpecular,
                                    onPressed: widget.onReplay ?? widget.onResume,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'ULANGI',
                                    style: GoogleFonts.outfit(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 1.8,
                                      color: GlassTokens.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 28),

                            // Primary Action Center (Hero): Lanjutkan ('▶') with Neon Cyan Aura
                            Transform.translate(
                              offset: Offset(0, resumeDy),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Soft pulsing halo aura
                                      Container(
                                        width: 86,
                                        height: 86,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: GlassTokens.neonCyan.withValues(
                                            alpha: 0.10 + 0.08 * math.sin(t).abs(),
                                          ),
                                        ),
                                      ),
                                      ZenGlyphButton(
                                        key: const Key('pause_resume'),
                                        tooltip: 'Lanjutkan',
                                        size: 70,
                                        isCircularBasalt: true,
                                        backgroundColor: GlassTokens.surfaceElevated,
                                        activeColor: GlassTokens.neonCyan,
                                        border: Border.all(
                                          color: GlassTokens.neonCyan.withValues(alpha: 0.70),
                                          width: 1.4,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: GlassTokens.neonCyan.withValues(alpha: 0.35),
                                            blurRadius: 20,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                        icon: Icons.play_arrow_rounded,
                                        iconSize: 40,
                                        iconColor: GlassTokens.neonCyan,
                                        onPressed: widget.onResume,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'LANJUT',
                                    style: GoogleFonts.outfit(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1.8,
                                      color: GlassTokens.neonCyan.withValues(alpha: 0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 28),

                            // Secondary Action Right: Kembali ke Level ('←')
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
                                    icon: Icons.arrow_back_rounded,
                                    iconSize: 24,
                                    iconColor: GlassTokens.textSpecular,
                                    onPressed: widget.onMenu,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'KEMBALI',
                                    style: GoogleFonts.outfit(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 1.8,
                                      color: GlassTokens.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Subtle instruction hint
                        Text(
                          'SENTUH DI MANA SAJA UNTUK LANJUT',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 2.2,
                            color: GlassTokens.textDim,
                          ),
                        ),
                      ],
                    ),

                    // 3. Bottom Footer: Ambient Soundscape Toggle
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 14.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Audio Soundscape Toggle Capsule
                          if (widget.onToggleMusic != null)
                            GestureDetector(
                              key: const Key('pause_audio'),
                              onTap: widget.onToggleMusic,
                              child: GlassContainer(
                                enableLiveBlur: false,
                                borderRadius: GlassTokens.radiusPill,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                backgroundColor: GlassTokens.surfaceSubtle.withValues(alpha: 0.50),
                                borderGradient: LinearGradient(
                                  colors: [
                                    widget.isMusicEnabled
                                        ? GlassTokens.neonCyan.withValues(alpha: 0.40)
                                        : GlassTokens.borderHighlight,
                                    GlassTokens.borderShadow,
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.graphic_eq_rounded,
                                      size: 16,
                                      color: widget.isMusicEnabled
                                          ? GlassTokens.neonCyan
                                          : GlassTokens.textDim,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.isMusicEnabled ? 'CHIMES ON' : 'CHIMES MUTED',
                                      style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 1.6,
                                        color: widget.isMusicEnabled
                                            ? GlassTokens.textSpecular
                                            : GlassTokens.textDim,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            const SizedBox.shrink(),

                          // Intentionally blank right side (zero ink meter / zero counters)
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

