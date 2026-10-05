import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../widgets/glass_container.dart';

/// In-game Heads-Up Display (HUD) adhering to Modern Minimalist & Glassmorphism:
/// - Strictly DIEGETIC: No status bar or fraction counter. Objectives are etched on vessels.
/// - Mode B Pre-composited frosted glass chips (zero live blur overhead on particle hot path).
/// - SafeArea corner anchoring: Subtle level numeral at Top-Left, glass chip cluster at Top-Right,
///   and ethereal pulsing gravity toggle at Bottom-Center.
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
    // Formatted level indicator: "0 1", "0 2", "3 0"
    final formattedLevel =
        levelId.toString().padLeft(2, '0').split('').join(' ');

    return SafeArea(
      child: Stack(
        children: [
          // 1. Top-Left: Subtle, quiet level indicator in Mode B glass chip
          Positioned(
            top: 12,
            left: 18,
            child: GlassContainer(
              enableLiveBlur: false,
              borderRadius: GlassTokens.radiusSmall,
              backgroundColor: GlassTokens.surfaceLight.withValues(alpha: 0.35),
              borderGradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [GlassTokens.borderHighlight, GlassTokens.borderShadow],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Text(
                formattedLevel,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: GlassTokens.textSpecular.withValues(alpha: 0.70),
                  letterSpacing: 3.0,
                ),
              ),
            ),
          ),

          // 2. Top-Right: Ambient Mode B glass chip cluster for Reset, Pause, Audio
          Positioned(
            top: 10,
            right: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onToggleMusic != null) ...[
                  ZenGlyphButton(
                    key: const Key('hud_audio'),
                    tooltip: isMusicEnabled ? 'Bisu Musik' : 'Bunyikan Musik',
                    icon: isMusicEnabled
                        ? Icons.graphic_eq_rounded
                        : Icons.volume_off_rounded,
                    iconSize: 18,
                    size: 38,
                    isCircularBasalt: true,
                    activeColor: isMusicEnabled ? GlassTokens.neonCyan : null,
                    onPressed: onToggleMusic,
                  ),
                  const SizedBox(width: 8),
                ],
                ZenGlyphButton(
                  key: const Key('hud_reset'),
                  tooltip: 'Reset Level',
                  icon: Icons.refresh_rounded,
                  iconSize: 20,
                  size: 38,
                  isCircularBasalt: true,
                  onPressed: onReset,
                ),
                const SizedBox(width: 8),
                ZenGlyphButton(
                  key: const Key('hud_pause'),
                  tooltip: 'Pause Game',
                  icon: Icons.pause_rounded,
                  iconSize: 20,
                  size: 38,
                  isCircularBasalt: true,
                  onPressed: onPause,
                ),
              ],
            ),
          ),

          // 3. Bottom-Center: Ethereal pulsing gravity inversion glyph
          if (hasGravityToggle)
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Center(
                child: _PulsingGravityGlyphButton(
                  onPressed: onToggleGravity,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Interactive button hosting bespoke vector line glyphs or Material icons
/// with smooth micro-scale and opacity animations, optionally in a tactile circular basalt pebble.
class ZenGlyphButton extends StatefulWidget {
  final CustomPainter? painter;
  final Widget? child;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;
  final Color? activeColor;
  final bool isCircularBasalt;
  final Color? backgroundColor;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final double restingOpacity;

  const ZenGlyphButton({
    super.key,
    this.painter,
    this.child,
    this.icon,
    this.iconColor,
    this.iconSize,
    required this.onPressed,
    required this.tooltip,
    this.size = 44,
    this.activeColor,
    this.isCircularBasalt = false,
    this.backgroundColor,
    this.border,
    this.boxShadow,
    this.restingOpacity = 0.45,
  });

  @override
  State<ZenGlyphButton> createState() => _ZenGlyphButtonState();
}

class _ZenGlyphButtonState extends State<ZenGlyphButton> {
  bool _isInteracting = false;

  void _setInteracting(bool value) {
    if (_isInteracting != value) {
      setState(() {
        _isInteracting = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.iconColor ??
        (widget.isCircularBasalt ? const Color(0xFFE2E8F0) : const Color(0xFFE2E8F0));
    final effectiveOpacity = widget.isCircularBasalt
        ? (_isInteracting ? 1.0 : 0.88)
        : (_isInteracting ? 0.95 : widget.restingOpacity);

    Widget content;
    if (widget.child != null) {
      content = widget.child!;
    } else if (widget.icon != null) {
      content = Icon(
        widget.icon,
        size: widget.iconSize ?? (widget.size * 0.48),
        color: effectiveColor,
      );
    } else if (widget.painter != null) {
      content = CustomPaint(
        size: Size(widget.iconSize ?? 22, widget.iconSize ?? 22),
        painter: widget.painter,
      );
    } else {
      content = const SizedBox.shrink();
    }

    final buttonBody = AnimatedOpacity(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      opacity: effectiveOpacity,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _isInteracting ? 0.92 : 1.0,
        curve: Curves.easeOutCubic,
        child: widget.isCircularBasalt
            ? GlassContainer(
                width: widget.size,
                height: widget.size,
                shape: BoxShape.circle,
                enableLiveBlur: false, // Mode B for Zero-GC HUD performance
                backgroundColor: widget.backgroundColor ??
                    GlassTokens.surfaceLight.withValues(alpha: 0.65),
                borderGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.activeColor != null
                        ? widget.activeColor!.withValues(alpha: 0.70)
                        : GlassTokens.borderHighlight,
                    GlassTokens.borderShadow,
                  ],
                ),
                borderWidth: 1.0,
                boxShadow: widget.boxShadow,
                child: Center(child: content),
              )
            : SizedBox(
                width: widget.size,
                height: widget.size,
                child: Center(child: content),
              ),
      ),
    );

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => _setInteracting(true),
        onExit: (_) => _setInteracting(false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _setInteracting(true),
          onTapUp: (_) => _setInteracting(false),
          onTapCancel: () => _setInteracting(false),
          onTap: widget.onPressed,
          child: buttonBody,
        ),
      ),
    );
  }
}

/// Gently breathing / pulsing gravity inversion button for inverted stages.
class _PulsingGravityGlyphButton extends StatefulWidget {
  final VoidCallback? onPressed;

  const _PulsingGravityGlyphButton({required this.onPressed});

  @override
  State<_PulsingGravityGlyphButton> createState() =>
      _PulsingGravityGlyphButtonState();
}

class _PulsingGravityGlyphButtonState extends State<_PulsingGravityGlyphButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double pulse = _controller.value;
        final double pulseOpacity = 0.55 + (pulse * 0.45);

        return Tooltip(
          message: 'Toggle Gravity',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onPressed,
            child: Opacity(
              opacity: pulseOpacity,
              child: GlassContainer(
                key: const Key('hud_gravity'),
                enableLiveBlur: false, // Mode B
                borderRadius: GlassTokens.radiusPill,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                backgroundColor: GlassTokens.surfaceElevated.withValues(alpha: 0.70),
                borderGradient: LinearGradient(
                  colors: [
                    GlassTokens.radiantGold.withValues(alpha: 0.40 + 0.45 * pulse),
                    GlassTokens.borderHighlight,
                    GlassTokens.radiantGold.withValues(alpha: 0.15 + 0.20 * pulse),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: GlassTokens.radiantGold.withValues(alpha: 0.20 * pulse),
                    blurRadius: 14 + 6 * pulse,
                  ),
                ],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomPaint(
                      size: const Size(18, 18),
                      painter: const GravityGlyphPainter(color: GlassTokens.radiantGold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'GRAVITY',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.2,
                        color: GlassTokens.radiantGold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Bespoke Vector Line Glyphs (Zero Allocation CustomPainters, Stroke Width 2.0)
// ---------------------------------------------------------------------------

/// Bespoke minimalist Reset glyph: 270-degree continuous circular arc with integrated arrow.
class ResetGlyphPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const ResetGlyphPainter({
    this.color = const Color(0xFFE2E8F0),
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width / 2.0, size.height / 2.0);
    final radius = size.width * 0.36;

    // Sweeps clockwise 280 degrees from -135 deg to +145 deg
    const startAngle = -math.pi * 0.75;
    const sweepAngle = math.pi * 1.55;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      strokePaint,
    );

    // End point of the circular arc
    final endAngle = startAngle + sweepAngle;
    final endPoint = Offset(
      center.dx + radius * math.cos(endAngle),
      center.dy + radius * math.sin(endAngle),
    );

    // Clockwise tangent vector at endPoint
    final tangent = Offset(-math.sin(endAngle), math.cos(endAngle));
    final normal = Offset(-tangent.dy, tangent.dx); // outward normal

    final arrowLen = size.width * 0.22;
    final arrowSpread = size.width * 0.18;

    final wing1 = endPoint - (tangent * arrowLen) + (normal * arrowSpread);
    final wing2 = endPoint - (tangent * arrowLen) - (normal * arrowSpread);

    final arrowPath = Path()
      ..moveTo(wing1.dx, wing1.dy)
      ..lineTo(endPoint.dx, endPoint.dy)
      ..lineTo(wing2.dx, wing2.dy);

    canvas.drawPath(arrowPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant ResetGlyphPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Bespoke minimalist Pause glyph: Twin rounded slender vertical capsules.
class PauseGlyphPainter extends CustomPainter {
  final Color color;

  const PauseGlyphPainter({this.color = const Color(0xFFE2E8F0)});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final leftX = size.width * 0.35;
    final rightX = size.width * 0.65;
    final topY = size.height * 0.22;
    final bottomY = size.height * 0.78;

    canvas.drawLine(Offset(leftX, topY), Offset(leftX, bottomY), strokePaint);
    canvas.drawLine(Offset(rightX, topY), Offset(rightX, bottomY), strokePaint);
  }

  @override
  bool shouldRepaint(covariant PauseGlyphPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Bespoke minimalist Gravity Inversion glyph: Dual opposing vertical arrows.
class GravityGlyphPainter extends CustomPainter {
  final Color color;

  const GravityGlyphPainter({this.color = const Color(0xFFFFD54F)});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Left arrow pointing down
    final leftX = w * 0.34;
    canvas.drawLine(Offset(leftX, h * 0.22), Offset(leftX, h * 0.78), strokePaint);
    final downPath = Path()
      ..moveTo(leftX - 3.5, h * 0.64)
      ..lineTo(leftX, h * 0.78)
      ..lineTo(leftX + 3.5, h * 0.64);
    canvas.drawPath(downPath, strokePaint);

    // Right arrow pointing up
    final rightX = w * 0.66;
    canvas.drawLine(Offset(rightX, h * 0.78), Offset(rightX, h * 0.22), strokePaint);
    final upPath = Path()
      ..moveTo(rightX - 3.5, h * 0.36)
      ..lineTo(rightX, h * 0.22)
      ..lineTo(rightX + 3.5, h * 0.36);
    canvas.drawPath(upPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant GravityGlyphPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Bespoke minimalist Audio glyph: Clean sound-wave speaker.
class AudioGlyphPainter extends CustomPainter {
  final Color color;
  final bool isMuted;

  const AudioGlyphPainter({
    this.color = const Color(0xFFE2E8F0),
    this.isMuted = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Speaker body
    final speakerPath = Path()
      ..moveTo(w * 0.22, h * 0.40)
      ..lineTo(w * 0.38, h * 0.40)
      ..lineTo(w * 0.55, h * 0.25)
      ..lineTo(w * 0.55, h * 0.75)
      ..lineTo(w * 0.38, h * 0.60)
      ..lineTo(w * 0.22, h * 0.60)
      ..close();

    canvas.drawPath(speakerPath, strokePaint);

    if (isMuted) {
      // Minimalist strike-through line
      canvas.drawLine(
        Offset(w * 0.20, h * 0.80),
        Offset(w * 0.80, h * 0.20),
        strokePaint,
      );
    } else {
      // Sound wave arc
      final waveRect = Rect.fromCenter(
        center: Offset(w * 0.55, h * 0.50),
        width: w * 0.45,
        height: h * 0.50,
      );
      canvas.drawArc(waveRect, -math.pi * 0.35, math.pi * 0.70, false, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant AudioGlyphPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isMuted != isMuted;
}

/// Minimalist Play / Resume vector glyph.
class PlayGlyphPainter extends CustomPainter {
  final Color color;

  const PlayGlyphPainter({this.color = const Color(0xFFE2E8F0)});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.36, h * 0.24)
      ..lineTo(w * 0.74, h * 0.50)
      ..lineTo(w * 0.36, h * 0.76)
      ..close();

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant PlayGlyphPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Minimalist Stages / 2x2 Bento Matrix vector glyph.
class StagesGlyphPainter extends CustomPainter {
  final Color color;

  const StagesGlyphPainter({this.color = const Color(0xFFE2E8F0)});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final nodeSize = w * 0.28;
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, nodeSize, nodeSize),
      Radius.circular(nodeSize * 0.32),
    );

    // Top-Left
    canvas.save();
    canvas.translate(w * 0.14, h * 0.14);
    canvas.drawRRect(r, strokePaint);
    canvas.restore();

    // Top-Right
    canvas.save();
    canvas.translate(w * 0.58, h * 0.14);
    canvas.drawRRect(r, strokePaint);
    canvas.restore();

    // Bottom-Left
    canvas.save();
    canvas.translate(w * 0.14, h * 0.58);
    canvas.drawRRect(r, strokePaint);
    canvas.restore();

    // Bottom-Right
    canvas.save();
    canvas.translate(w * 0.58, h * 0.58);
    canvas.drawRRect(r, fillPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant StagesGlyphPainter oldDelegate) =>
      oldDelegate.color != color;
}

