import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Arcade-style in-game HUD for Micin Micin.
///
/// Design language matches the new arcade menu:
/// - Top-left: amber coin badge with level number.
/// - Top-right: three chunky circular icon buttons (audio, reset, pause)
///   with hard solid drop-shadow — no blur, no glassmorphism.
/// - Bottom-center: GRAVITY pill with cosmic purple + cyan glow halo,
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
          // 1. Top-Left: Amber coin badge with level number
          Positioned(
            top: 10,
            left: 14,
            child: _LevelCoinBadge(levelText: formattedLevel),
          ),

          // 2. Top-Right: Icon button cluster
          Positioned(
            top: 8,
            right: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onToggleMusic != null) ...[
                  _HudIconButton(
                    key: const Key('hud_audio'),
                    icon: isMusicEnabled
                        ? Icons.graphic_eq_rounded
                        : Icons.volume_off_rounded,
                    faceColor: isMusicEnabled
                        ? const Color(0xFF1E5080)
                        : const Color(0xFF2C2C2C),
                    shadowColor: isMusicEnabled
                        ? const Color(0xFF0A2540)
                        : const Color(0xFF111111),
                    onTap: onToggleMusic!,
                  ),
                  const SizedBox(width: 8),
                ],
                _HudIconButton(
                  key: const Key('hud_reset'),
                  icon: Icons.refresh_rounded,
                  faceColor: const Color(0xFFB45309),
                  shadowColor: const Color(0xFF5C2800),
                  onTap: onReset,
                ),
                const SizedBox(width: 8),
                _HudIconButton(
                  key: const Key('hud_pause'),
                  icon: Icons.pause_rounded,
                  faceColor: const Color(0xFF1E293B),
                  shadowColor: const Color(0xFF060A12),
                  onTap: onPause,
                ),
              ],
            ),
          ),

          // 3. Bottom-Center: GRAVITY pulsing pill
          if (hasGravityToggle)
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Center(
                child: _GravityPill(
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
// Level Coin Badge
// ─────────────────────────────────────────────────────────────────────────────

class _LevelCoinBadge extends StatelessWidget {
  final String levelText;
  const _LevelCoinBadge({required this.levelText});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CoinPainter(),
      child: SizedBox(
        width: 52,
        height: 52,
        child: Center(
          child: Text(
            levelText,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF7A3F00),
              letterSpacing: 0,
              shadows: [
                Shadow(
                  color: Colors.white.withValues(alpha: 0.35),
                  offset: const Offset(0, 1),
                  blurRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CoinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Shadow disc
    canvas.drawCircle(
      Offset(cx, cy + 4),
      r,
      Paint()..color = const Color(0xFF7A3F00),
    );

    // Main gold face
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.4),
          radius: 0.9,
          colors: [Color(0xFFFFD54F), Color(0xFFFFB300), Color(0xFFE65100)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
    );

    // Rim highlight
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_CoinPainter _) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// HUD Icon Button (circular, hard drop-shadow)
// ─────────────────────────────────────────────────────────────────────────────

class _HudIconButton extends StatefulWidget {
  final IconData icon;
  final Color faceColor;
  final Color shadowColor;
  final VoidCallback onTap;

  const _HudIconButton({
    super.key,
    required this.icon,
    required this.faceColor,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  State<_HudIconButton> createState() => _HudIconButtonState();
}

class _HudIconButtonState extends State<_HudIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const size = 42.0;
    const depth = 4.0;
    final depressed = _pressed ? depth : 0.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 55),
        margin: EdgeInsets.only(top: depressed, bottom: depth - depressed),
        child: CustomPaint(
          painter: _CircleButtonPainter(
            faceColor: widget.faceColor,
            shadowColor: widget.shadowColor,
            depressed: _pressed,
          ),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              widget.icon,
              color: Colors.white,
              size: 20,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleButtonPainter extends CustomPainter {
  final Color faceColor;
  final Color shadowColor;
  final bool depressed;

  const _CircleButtonPainter({
    required this.faceColor,
    required this.shadowColor,
    required this.depressed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    const depth = 4.0;

    if (!depressed) {
      // Hard shadow disc below
      canvas.drawCircle(
        Offset(cx, cy + depth),
        r,
        Paint()..color = shadowColor,
      );
    }

    // Face gradient
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(faceColor, Colors.white, 0.20)!,
            faceColor,
            Color.lerp(faceColor, Colors.black, 0.25)!,
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
    );

    // Rim
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(_CircleButtonPainter old) =>
      old.faceColor != faceColor ||
      old.shadowColor != shadowColor ||
      old.depressed != depressed;
}

// ─────────────────────────────────────────────────────────────────────────────
// Gravity Pill Button (pulsing glow)
// ─────────────────────────────────────────────────────────────────────────────

class _GravityPill extends StatefulWidget {
  final VoidCallback? onPressed;
  const _GravityPill({super.key, this.onPressed});

  @override
  State<_GravityPill> createState() => _GravityPillState();
}

class _GravityPillState extends State<_GravityPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _glow;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _glow = Tween<double>(begin: 8.0, end: 18.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const depth = 3.0;
    final depressed = _pressed ? depth : 0.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedBuilder(
        animation: _glow,
        builder: (context, _) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 55),
            margin:
                EdgeInsets.only(top: depressed, bottom: depth - depressed),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
                ),
                boxShadow: [
                  // Hard arcade drop shadow
                  BoxShadow(
                    color: const Color(0xFF2D0A6E),
                    offset: Offset(0, depth - depressed),
                    blurRadius: 0,
                  ),
                  // Pulsing cyan glow halo
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.55),
                    blurRadius: _glow.value,
                    spreadRadius: 1.0,
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.70),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.rotate(
                    angle: math.pi / 2,
                    child: const Icon(
                      Icons.swap_horiz_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'GRAVITY',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 2.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
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
