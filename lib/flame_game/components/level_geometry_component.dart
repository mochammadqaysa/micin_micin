import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show
        Alignment,
        Canvas,
        Color,
        Colors,
        LinearGradient,
        MaskFilter,
        BlurStyle,
        Offset,
        Paint,
        PaintingStyle,
        Path,
        RadialGradient,
        Radius,
        Rect,
        RRect,
        StrokeCap,
        StrokeJoin,
        TextDirection,
        TextPainter,
        TextSpan,
        TextStyle,
        FontWeight;
import '../../engine/collision/cup_hitbox.dart';
import '../../models/level_config.dart';

/// Renders static level objectives: target cups, particle emitters, and
/// color filter gate zones.
///
/// Direct port of [LevelPainter] as a Flame [Component] at priority 10.
class LevelGeometryFlameComponent extends Component {
  final LevelConfig levelConfig;
  final List<CupHitbox> Function() liveCupsGetter;

  LevelGeometryFlameComponent({
    required this.levelConfig,
    required this.liveCupsGetter,
  });

  @override
  int get priority => 10;

  @override
  void render(Canvas canvas) {
    final liveCups = liveCupsGetter();
    _renderColorFilters(canvas, liveCups);
    _renderCups(canvas, liveCups);
    _renderEmitters(canvas);
  }

  // ── Color filter zones ────────────────────────────────────────────────────

  void _renderColorFilters(Canvas canvas, List<CupHitbox> liveCups) {
    for (final filter in levelConfig.filters) {
      final rect = Rect.fromLTWH(filter.x, filter.y, filter.width, filter.height);

      // Translucent glassmorphic body
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6.0)),
        Paint()
          ..color = filter.targetColor.withValues(alpha: 0.18)
          ..style = PaintingStyle.fill,
      );

      // Specular gradient border
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6.0)),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              filter.targetColor.withValues(alpha: 0.85),
              Colors.white.withValues(alpha: 0.40),
              filter.targetColor.withValues(alpha: 0.25),
            ],
          ).createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );

      // Resonance halo ring
      canvas.drawCircle(
        rect.center,
        5.0,
        Paint()
          ..color = filter.targetColor.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );

      // Jewel center pip
      canvas.drawCircle(
        rect.center,
        2.5,
        Paint()
          ..color = filter.targetColor
          ..style = PaintingStyle.fill,
      );
    }
  }

  // ── Target cups ───────────────────────────────────────────────────────────

  void _renderCups(Canvas canvas, List<CupHitbox> liveCups) {
    for (int i = 0; i < levelConfig.cups.length; i++) {
      final cup = levelConfig.cups[i];
      final currentCaptured =
          (i < liveCups.length) ? liveCups[i].capturedCount : 0;

      final rect = Rect.fromLTWH(cup.x, cup.y, cup.width, cup.height);

      // 1. Ground contact shadow
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(rect.center.dx, rect.bottom + 2.0),
          width: rect.width * 1.08,
          height: 8.0,
        ),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0),
      );

      // 2. Isometric vessel body
      final bodyPath = Path()
        ..moveTo(rect.left, rect.top + 3.0)
        ..lineTo(rect.left + 2.0, rect.bottom - 6.0)
        ..quadraticBezierTo(
            rect.left + 3.0, rect.bottom, rect.left + 8.0, rect.bottom)
        ..lineTo(rect.right - 8.0, rect.bottom)
        ..quadraticBezierTo(
            rect.right - 3.0, rect.bottom, rect.right - 2.0, rect.bottom - 6.0)
        ..lineTo(rect.right, rect.top + 3.0)
        ..close();

      canvas.drawPath(
        bodyPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cup.color.withValues(alpha: 0.22),
              const Color(0xFF0F172A).withValues(alpha: 0.78),
              const Color(0xFF0A0D14).withValues(alpha: 0.88),
            ],
            stops: const [0.0, 0.45, 1.0],
          ).createShader(rect)
          ..style = PaintingStyle.fill,
      );

      canvas.drawPath(
        bodyPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.70),
              cup.color.withValues(alpha: 0.85),
              cup.color.withValues(alpha: 0.30),
            ],
          ).createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      // 3. Isometric elliptical rim
      final rimHeight = (rect.width * 0.28).clamp(8.0, 16.0);
      final rimRect = Rect.fromCenter(
        center: Offset(rect.center.dx, rect.top + 2.0),
        width: rect.width,
        height: rimHeight,
      );

      canvas.drawOval(
        rimRect,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(0.0, -0.2),
            radius: 0.9,
            colors: [
              const Color(0xFF05070B).withValues(alpha: 0.95),
              cup.color.withValues(alpha: 0.30),
            ],
          ).createShader(rimRect)
          ..style = PaintingStyle.fill,
      );

      canvas.drawOval(
        rimRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.90),
              cup.color.withValues(alpha: 0.95),
              cup.color.withValues(alpha: 0.45),
            ],
          ).createShader(rimRect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );

      // 4. Countdown number with 80ms capture pulse
      final remaining =
          (cup.targetAmount - currentCaptured).clamp(0, cup.targetAmount);
      final cacheKey = '$i:$remaining:${cup.color.toARGB32()}';
      var tp = _textPainterCache[cacheKey];
      if (tp == null) {
        tp = TextPainter(
          text: TextSpan(
            text: '$remaining',
            style: TextStyle(
              color: remaining == 0 ? const Color(0xFFFFD54F) : cup.color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'Outfit',
              letterSpacing: 0.6,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        _textPainterCache[cacheKey] = tp;
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsed = now - ((i < liveCups.length) ? liveCups[i].lastCaptureMs : 0);
      final double scale;
      if (elapsed >= 0 && elapsed < 80) {
        scale = 1.0 + 0.06 * math.sin((elapsed / 80.0) * math.pi);
      } else {
        scale = 1.0;
      }

      final center = Offset(rect.center.dx, rect.top + rect.height * 0.55);
      if (scale != 1.0) {
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.scale(scale);
        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
        canvas.restore();
      } else {
        tp.paint(
          canvas,
          Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
        );
      }
    }
  }

  // ── Particle emitters ─────────────────────────────────────────────────────

  void _renderEmitters(Canvas canvas) {
    for (final emitter in levelConfig.emitters) {
      final center = Offset(emitter.x, emitter.y);
      const funnelW = 18.0;
      const funnelH = 14.0;
      const mouthW = 10.0;
      const mouthH = 5.0;

      // Top mounting collar
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(center.dx, center.dy - funnelH * 0.5),
            width: funnelW + 4.0,
            height: 3.5,
          ),
          const Radius.circular(1.5),
        ),
        Paint()
          ..color = emitter.color.withValues(alpha: 0.40)
          ..style = PaintingStyle.fill,
      );

      // Funnel body
      final funnelPath = Path()
        ..moveTo(center.dx - funnelW * 0.5, center.dy - funnelH * 0.5)
        ..lineTo(center.dx - mouthW * 0.5, center.dy + funnelH * 0.5)
        ..lineTo(center.dx + mouthW * 0.5, center.dy + funnelH * 0.5)
        ..lineTo(center.dx + funnelW * 0.5, center.dy - funnelH * 0.5)
        ..close();

      final funnelRect =
          Rect.fromCenter(center: center, width: funnelW, height: funnelH);
      canvas.drawPath(
        funnelPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.35),
              emitter.color.withValues(alpha: 0.70),
              const Color(0xFF0F172A).withValues(alpha: 0.90),
            ],
          ).createShader(funnelRect)
          ..style = PaintingStyle.fill,
      );

      canvas.drawPath(
        funnelPath,
        Paint()
          ..color = emitter.color.withValues(alpha: 0.60)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );

      // Spout mouth ellipse
      final mouthRect = Rect.fromCenter(
        center: Offset(center.dx, center.dy + funnelH * 0.5),
        width: mouthW,
        height: mouthH,
      );
      canvas.drawOval(mouthRect,
          Paint()
            ..color = const Color(0xFF05070B)
            ..style = PaintingStyle.fill);
      canvas.drawOval(mouthRect,
          Paint()
            ..color = emitter.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4);
    }
  }

  static final Map<String, TextPainter> _textPainterCache = {};
  static void clearCache() => _textPainterCache.clear();
}
