import 'dart:math' as math;
import 'package:flutter/material.dart';

/// In-game Heads-Up Display (HUD) adhering to Zen and meditative puzzle aesthetics:
/// - Strictly DIEGETIC: No status bar or fraction counter. Objectives are etched on vessels.
/// - Bespoke vector line glyphs: Stroke width 2.0, resting opacity 0.35 -> 0.90 on touch.
/// - SafeArea corner anchoring: Subtle level numeral at Top-Left, glyph cluster at Top-Right,
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
          // 1. Top-Left: Subtle, quiet level indicator
          Positioned(
            top: 14,
            left: 20,
            child: Opacity(
              opacity: 0.40,
              child: Text(
                formattedLevel,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFFE2E8F0),
                  letterSpacing: 3.0,
                ),
              ),
            ),
          ),

          // 2. Top-Right: Ambient glyph cluster for Reset and Pause
          Positioned(
            top: 8,
            right: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onToggleMusic != null) ...[
                  ZenGlyphButton(
                    key: const Key('hud_audio'),
                    tooltip: isMusicEnabled ? 'Bisu Musik' : 'Bunyikan Musik',
                    painter: AudioGlyphPainter(isMuted: !isMusicEnabled),
                    onPressed: onToggleMusic,
                  ),
                  const SizedBox(width: 4),
                ],
                ZenGlyphButton(
                  key: const Key('hud_reset'),
                  tooltip: 'Reset Level',
                  painter: const ResetGlyphPainter(),
                  onPressed: onReset,
                ),
                const SizedBox(width: 4),
                ZenGlyphButton(
                  key: const Key('hud_pause'),
                  tooltip: 'Pause Game',
                  painter: const PauseGlyphPainter(),
                  onPressed: onPause,
                ),
              ],
            ),
          ),

          // 3. Bottom-Center: Ethereal pulsing gravity inversion glyph
          if (hasGravityToggle)
            Positioned(
              bottom: 12,
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

/// Interactive button hosting bespoke vector line glyphs with smooth 0.35 -> 0.90 opacity.
class ZenGlyphButton extends StatefulWidget {
  final CustomPainter painter;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;
  final Color? activeColor;

  const ZenGlyphButton({
    super.key,
    required this.painter,
    required this.onPressed,
    required this.tooltip,
    this.size = 44,
    this.activeColor,
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
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            opacity: _isInteracting ? 0.90 : 0.35,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Center(
                child: CustomPaint(
                  size: const Size(22, 22),
                  painter: widget.painter,
                ),
              ),
            ),
          ),
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
        // Breathing opacity oscillation between 0.35 and 0.85
        final double pulseOpacity = 0.35 + (_controller.value * 0.50);

        return Tooltip(
          message: 'Toggle Gravity',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onPressed,
            child: Opacity(
              opacity: pulseOpacity,
              child: Container(
                key: const Key('hud_gravity'),
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFD54F).withValues(alpha: 0.06 * _controller.value),
                ),
                child: const CustomPaint(
                  size: Size(22, 22),
                  painter: GravityGlyphPainter(color: Color(0xFFFFD54F)),
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

/// Bespoke minimalist Reset glyph: 270-degree arc with elegant rounded arrow.
class ResetGlyphPainter extends CustomPainter {
  final Color color;

  const ResetGlyphPainter({this.color = const Color(0xFFE2E8F0)});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width / 2.0, size.height / 2.0);
    final radius = size.width * 0.38;

    // 270 degree circular arc sweep
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      math.pi * 1.45,
      false,
      strokePaint,
    );

    // Arrowhead tip at top-right
    final arrowTip = Offset(center.dx + radius * 0.72, center.dy - radius * 0.72);
    final arrowPath = Path()
      ..moveTo(arrowTip.dx - 4.5, arrowTip.dy)
      ..lineTo(arrowTip.dx, arrowTip.dy)
      ..lineTo(arrowTip.dx, arrowTip.dy + 4.5);

    canvas.drawPath(arrowPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant ResetGlyphPainter oldDelegate) =>
      oldDelegate.color != color;
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

/// Minimalist Stages / 2x2 grid vector glyph.
class StagesGlyphPainter extends CustomPainter {
  final Color color;

  const StagesGlyphPainter({this.color = const Color(0xFFE2E8F0)});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final dotRadius = 1.8;

    final x1 = w * 0.34;
    final x2 = w * 0.66;
    final y1 = h * 0.34;
    final y2 = h * 0.66;

    canvas.drawCircle(Offset(x1, y1), dotRadius, fillPaint);
    canvas.drawCircle(Offset(x2, y1), dotRadius, fillPaint);
    canvas.drawCircle(Offset(x1, y2), dotRadius, fillPaint);
    canvas.drawCircle(Offset(x2, y2), dotRadius, fillPaint);
  }

  @override
  bool shouldRepaint(covariant StagesGlyphPainter oldDelegate) =>
      oldDelegate.color != color;
}

