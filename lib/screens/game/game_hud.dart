import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pixel_ui/pixel_ui.dart';
import 'package:micin_micin/core/pixel_terrain_tokens.dart';

/// Pixel-art in-game HUD for Micin Micin.
///
/// Adopts retro pixel-art aesthetic from `pixel_ui`:
/// - Top-left: Washi/sand [PixelBox] level badge with [PixelText.mulmaru].
/// - Top-right: Tactile [PixelButton] cluster (audio, reset, pause) with
///   stepped [PixelCorners] and crisp drop shadows.
/// - Bottom-center: Deep violet & cyan [PixelButton] gravity switch,
///   only visible when level has gravity toggle mechanic.
class GameHud extends StatelessWidget {
  final int levelId;
  final int capturedCount;
  final int totalSugar;
  final bool hasGravityToggle;
  final bool isMusicEnabled;
  final VoidCallback onPause;
  final VoidCallback onReset;
  final VoidCallback? onToggleMusic;
  final VoidCallback? onToggleGravity;

  const GameHud({
    super.key,
    required this.levelId,
    this.capturedCount = 0,
    this.totalSugar = 0,
    this.hasGravityToggle = false,
    this.isMusicEnabled = true,
    required this.onPause,
    required this.onReset,
    this.onToggleMusic,
    this.onToggleGravity,
  });

  @override
  Widget build(BuildContext context) {
    final formattedLevel = levelId.toString().padLeft(2, '0');

    return SafeArea(
      child: Stack(
        children: [
          // 1. Top-Left: PixelBox level badge with Mulmaru pixel text
          Positioned(
            top: 10,
            left: 14,
            child: _LevelPixelBadge(levelText: formattedLevel),
          ),

          // 2. Top-Right: Tactile PixelButton cluster
          Positioned(
            top: 8,
            right: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onToggleMusic != null) ...[
                  PixelButton(
                    key: const Key('hud_audio'),
                    logicalWidth: 11,
                    logicalHeight: 11,
                    width: 44,
                    height: 44,
                    normalStyle: isMusicEnabled
                        ? PixelTerrainTokens.audioButtonNormal
                        : PixelTerrainTokens.pauseButtonNormal,
                    pressedStyle: PixelTerrainTokens.audioButtonPressed,
                    pressChildOffset: const Offset(0, 1),
                    onPressed: onToggleMusic,
                    child: Icon(
                      isMusicEnabled
                          ? Icons.graphic_eq_rounded
                          : Icons.volume_off_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                PixelButton(
                  key: const Key('hud_reset'),
                  logicalWidth: 11,
                  logicalHeight: 11,
                  width: 44,
                  height: 44,
                  normalStyle: PixelTerrainTokens.resetButtonNormal,
                  pressedStyle: PixelTerrainTokens.resetButtonPressed,
                  pressChildOffset: const Offset(0, 1),
                  onPressed: onReset,
                  child: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                PixelButton(
                  key: const Key('hud_pause'),
                  logicalWidth: 11,
                  logicalHeight: 11,
                  width: 44,
                  height: 44,
                  normalStyle: PixelTerrainTokens.pauseButtonNormal,
                  pressedStyle: PixelTerrainTokens.pauseButtonPressed,
                  pressChildOffset: const Offset(0, 1),
                  onPressed: onPause,
                  child: const Icon(
                    Icons.pause_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // 3. Bottom-Center: Tactile PixelButton Gravity Switch
          if (hasGravityToggle)
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Center(
                child: PixelButton(
                  key: const Key('hud_gravity'),
                  logicalWidth: 32,
                  logicalHeight: 11,
                  width: 136,
                  height: 44,
                  normalStyle: PixelTerrainTokens.gravityButtonNormal,
                  pressedStyle: PixelTerrainTokens.gravityButtonPressed,
                  pressChildOffset: const Offset(0, 1),
                  onPressed: onToggleGravity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/gates/gravity_pixel.png',
                        width: 18,
                        height: 18,
                        filterQuality: FilterQuality.none,
                        errorBuilder: (_, __, ___) => Transform.rotate(
                          angle: math.pi / 2,
                          child: const Icon(
                            Icons.swap_horiz_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'GRAVITY',
                        style: PixelText.mulmaru(
                          fontSize: 14,
                          color: Colors.white,
                          shadowColor: PixelTerrainTokens.slateBedrock,
                          shadowOffset: const Offset(1, 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Level Pixel Badge (PixelBox + PixelText.mulmaru)
// ─────────────────────────────────────────────────────────────────────────────

class _LevelPixelBadge extends StatelessWidget {
  final String levelText;
  const _LevelPixelBadge({required this.levelText});

  @override
  Widget build(BuildContext context) {
    return PixelBox(
      logicalWidth: 14,
      logicalHeight: 11,
      width: 56,
      height: 44,
      style: PixelTerrainTokens.badgeStyle,
      child: Center(
        child: Text(
          levelText,
          style: PixelText.mulmaru(
            fontSize: 16,
            color: PixelTerrainTokens.slate,
            shadowColor: PixelTerrainTokens.sandDark,
            shadowOffset: const Offset(1, 1),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Legacy ZenGlyphButton kept for backward compatibility (used by tests/overlays)
// ─────────────────────────────────────────────────────────────────────────────

class ZenGlyphButton extends StatefulWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool isCircularBasalt;
  final LinearGradient? borderGradient;
  final List<BoxShadow>? boxShadow;

  const ZenGlyphButton({
    super.key,
    required this.icon,
    this.size = 44,
    this.iconSize = 22,
    this.backgroundColor = const Color(0xFF1E293B),
    this.iconColor = Colors.white,
    this.onPressed,
    this.tooltip,
    this.isCircularBasalt = false,
    this.borderGradient,
    this.boxShadow,
  });

  @override
  State<ZenGlyphButton> createState() => _ZenGlyphButtonState();
}

class _ZenGlyphButtonState extends State<ZenGlyphButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 60),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            shape: BoxShape.circle,
            boxShadow: widget.boxShadow,
          ),
          child: Icon(widget.icon, color: widget.iconColor, size: widget.iconSize),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }
}

// ignore_for_file: non_constant_identifier_names
