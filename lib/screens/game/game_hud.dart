import 'package:flutter/material.dart';

/// Minimalist vector in-game HUD for Micin Micin (Sugar, Sugar homage).
///
/// Adopts Bart Bonte's authentic minimalist vector aesthetic:
/// - Top-Right: Clean circular vector glyph buttons (Audio/Mute, Reset, Pause).
/// - Bottom-Left: Diegetic minimalist level indicator chip displaying formatted level (e.g., "01").
/// - Bottom-Center: Sleek minimalist rounded pill for Gravity switch (when enabled).
///
/// Preserves 100% of semantic keys:
/// - `Key('hud_reset')`
/// - `Key('hud_pause')`
/// - `Key('hud_audio')` & `Key('hud_sound')`
/// - `Key('hud_gravity')`
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
          // 1. Bottom-Left: Diegetic minimalist level indicator
          Positioned(
            bottom: 16,
            left: 18,
            child: _DiegeticLevelIndicator(levelText: formattedLevel),
          ),

          // 2. Top-Right: Bart Bonte circular action button cluster
          Positioned(
            top: 12,
            right: 14,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onToggleMusic != null) ...[
                  KeyedSubtree(
                    key: const Key('hud_sound'),
                    child: _MinimalCircularButton(
                      key: const Key('hud_audio'),
                      onPressed: onToggleMusic,
                      tooltip: isMusicEnabled ? 'Mute' : 'Unmute',
                      child: Icon(
                        isMusicEnabled
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                _MinimalCircularButton(
                  key: const Key('hud_reset'),
                  onPressed: onReset,
                  tooltip: 'Restart Level',
                  child: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                _MinimalCircularButton(
                  key: const Key('hud_pause'),
                  onPressed: onPause,
                  tooltip: 'Pause',
                  child: const Icon(
                    Icons.pause_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // 3. Bottom-Center: Minimalist rounded pill Gravity Switch
          if (hasGravityToggle)
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Center(
                child: _MinimalGravityButton(
                  key: const Key('hud_gravity'),
                  onPressed: onToggleGravity,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Minimal Circular Button (Bart Bonte style)
// ─────────────────────────────────────────────────────────────────────────────

class _MinimalCircularButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? tooltip;
  static const double size = 44.0;

  const _MinimalCircularButton({
    super.key,
    required this.child,
    this.onPressed,
    this.tooltip,
  });

  @override
  State<_MinimalCircularButton> createState() => _MinimalCircularButtonState();
}

class _MinimalCircularButtonState extends State<_MinimalCircularButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final button = Semantics(
      button: true,
      label: widget.tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onPressed?.call();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.90 : 1.0,
          duration: const Duration(milliseconds: 70),
          curve: Curves.easeOutCubic,
          child: Container(
            width: _MinimalCircularButton.size,
            height: _MinimalCircularButton.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.32),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(child: widget.child),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Minimal Gravity Button Pill
// ─────────────────────────────────────────────────────────────────────────────

class _MinimalGravityButton extends StatefulWidget {
  final VoidCallback? onPressed;

  const _MinimalGravityButton({
    super.key,
    this.onPressed,
  });

  @override
  State<_MinimalGravityButton> createState() => _MinimalGravityButtonState();
}

class _MinimalGravityButtonState extends State<_MinimalGravityButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 70),
        curve: Curves.easeOutCubic,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.swap_vert_rounded,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'GRAVITY',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Diegetic Level Indicator
// ─────────────────────────────────────────────────────────────────────────────

class _DiegeticLevelIndicator extends StatelessWidget {
  final String levelText;
  const _DiegeticLevelIndicator({required this.levelText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: 1.2,
        ),
      ),
      child: Text(
        levelText,
        style: const TextStyle(
          fontFamily: 'Outfit',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: Colors.white,
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
