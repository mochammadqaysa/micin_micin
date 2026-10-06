import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../engine/collision/cup_hitbox.dart';
import '../../../models/level_config.dart';

/// Renders static and objective level components: target cups, particle emitters,
/// and color filter gate zones.
class LevelPainter extends CustomPainter {
  final LevelConfig levelConfig;
  final List<CupHitbox>? liveCups;
  final List<int> _capturedSnapshot;

  LevelPainter({
    required this.levelConfig,
    this.liveCups,
  }) : _capturedSnapshot = liveCups == null
            ? const []
            : List<int>.generate(liveCups.length, (i) => liveCups[i].capturedCount);

  @override
  void paint(Canvas canvas, Size size) {
    _renderColorFilters(canvas, size);
    _renderCups(canvas, size);
    _renderEmitters(canvas, size);
  }

  void _renderColorFilters(Canvas canvas, Size size) {
    for (final filter in levelConfig.filters) {
      final rect = Rect.fromLTWH(
        filter.x,
        filter.y,
        filter.width,
        filter.height,
      );

      // Translucent glassmorphic body (opacity 0.18 per Art Direction)
      final fillPaint = Paint()
        ..color = filter.targetColor.withValues(alpha: 0.18)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6.0)),
        fillPaint,
      );

      // Specular gradient luminescent border outline (alpha: 0.85 -> 0.25)
      final borderPaint = Paint()
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
        ..strokeWidth = 1.2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6.0)),
        borderPaint,
      );

      // Center resonance core: outer halo ring
      final haloPaint = Paint()
        ..color = filter.targetColor.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      canvas.drawCircle(rect.center, 5.0, haloPaint);

      // Center resonance core: jewel pip
      final centerPipPaint = Paint()
        ..color = filter.targetColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(rect.center, 2.5, centerPipPaint);
    }
  }

  void _renderCups(Canvas canvas, Size size) {
    for (int i = 0; i < levelConfig.cups.length; i++) {
      final cup = levelConfig.cups[i];
      final currentCaptured =
          (liveCups != null && i < liveCups!.length) ? liveCups![i].capturedCount : 0;

      final rect = Rect.fromLTWH(
        cup.x,
        cup.y,
        cup.width,
        cup.height,
      );

      // 1. 2.5D Isometric Ground Contact Shadow (Soft Perspective Base Oval)
      final shadowRect = Rect.fromCenter(
        center: Offset(rect.center.dx, rect.bottom + 2.0),
        width: rect.width * 1.08,
        height: 8.0,
      );
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
      canvas.drawOval(shadowRect, shadowPaint);

      // 2. 2.5D Isometric Vessel Body (Tapered wall trapezoid with left/right lighting)
      final bodyPath = Path()
        ..moveTo(rect.left, rect.top + 3.0)
        ..lineTo(rect.left + 2.0, rect.bottom - 6.0)
        ..quadraticBezierTo(rect.left + 3.0, rect.bottom, rect.left + 8.0, rect.bottom)
        ..lineTo(rect.right - 8.0, rect.bottom)
        ..quadraticBezierTo(rect.right - 3.0, rect.bottom, rect.right - 2.0, rect.bottom - 6.0)
        ..lineTo(rect.right, rect.top + 3.0)
        ..close();

      final bodyFillPaint = Paint()
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
        ..style = PaintingStyle.fill;
      canvas.drawPath(bodyPath, bodyFillPaint);

      final bodyStrokePaint = Paint()
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
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(bodyPath, bodyStrokePaint);

      // 3. 2.5D Isometric Elliptical Rim Opening (Top Vessel Mouth)
      final rimHeight = (rect.width * 0.28).clamp(8.0, 16.0);
      final rimRect = Rect.fromCenter(
        center: Offset(rect.center.dx, rect.top + 2.0),
        width: rect.width,
        height: rimHeight,
      );

      final innerBasinPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.0, -0.2),
          radius: 0.9,
          colors: [
            const Color(0xFF05070B).withValues(alpha: 0.95),
            cup.color.withValues(alpha: 0.30),
          ],
        ).createShader(rimRect)
        ..style = PaintingStyle.fill;
      canvas.drawOval(rimRect, innerBasinPaint);

      final rimStrokePaint = Paint()
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
        ..strokeWidth = 1.8;
      canvas.drawOval(rimRect, rimStrokePaint);

      // 4. Target countdown text on cup face (REQ-005, AC-004, PRN-002)
      final remaining = (cup.targetAmount - currentCaptured).clamp(0, cup.targetAmount);
      final cacheKey = '$i:$remaining:${cup.color.toARGB32()}';
      var textPainter = _textPainterCache[cacheKey];
      if (textPainter == null) {
        final textSpan = TextSpan(
          text: '$remaining',
          style: TextStyle(
            color: remaining == 0 ? const Color(0xFFFFD54F) : cup.color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: 'Outfit',
            letterSpacing: 0.6,
          ),
        );
        textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();
        _textPainterCache[cacheKey] = textPainter;
      }

      // 80ms subtle scale-pulse (1.00 -> 1.06 -> 1.00) upon grain capture (REQ-007, AC-007)
      final now = DateTime.now().millisecondsSinceEpoch;
      final lastCapture = (liveCups != null && i < liveCups!.length)
          ? liveCups![i].lastCaptureMs
          : 0;
      final elapsed = now - lastCapture;
      final double scale;
      if (elapsed >= 0 && elapsed < 80) {
        final t = elapsed / 80.0;
        scale = 1.0 + 0.06 * math.sin(t * math.pi);
      } else {
        scale = 1.0;
      }

      final center = Offset(rect.center.dx, rect.top + (rect.height * 0.55));
      if (scale != 1.0) {
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.scale(scale);
        textPainter.paint(
          canvas,
          Offset(-textPainter.width / 2, -textPainter.height / 2),
        );
        canvas.restore();
      } else {
        textPainter.paint(
          canvas,
          Offset(
            center.dx - textPainter.width / 2,
            center.dy - textPainter.height / 2,
          ),
        );
      }
    }
  }

  void _renderEmitters(Canvas canvas, Size size) {
    for (final emitter in levelConfig.emitters) {
      final center = Offset(emitter.x, emitter.y);
      const funnelW = 18.0;
      const funnelH = 14.0;
      const mouthW = 10.0;
      const mouthH = 5.0;

      // 1. Top mounting collar / bracket
      final topCollarRect = Rect.fromCenter(
        center: Offset(center.dx, center.dy - funnelH * 0.5),
        width: funnelW + 4.0,
        height: 3.5,
      );
      final collarPaint = Paint()
        ..color = emitter.color.withValues(alpha: 0.40)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(topCollarRect, const Radius.circular(1.5)),
        collarPaint,
      );

      // 2. 2.5D Funnel Body Path (Tapered Nozzle Cone)
      final funnelPath = Path()
        ..moveTo(center.dx - funnelW * 0.5, center.dy - funnelH * 0.5)
        ..lineTo(center.dx - mouthW * 0.5, center.dy + funnelH * 0.5)
        ..lineTo(center.dx + mouthW * 0.5, center.dy + funnelH * 0.5)
        ..lineTo(center.dx + funnelW * 0.5, center.dy - funnelH * 0.5)
        ..close();

      final funnelRect = Rect.fromCenter(center: center, width: funnelW, height: funnelH);
      final funnelPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.35),
            emitter.color.withValues(alpha: 0.70),
            const Color(0xFF0F172A).withValues(alpha: 0.90),
          ],
        ).createShader(funnelRect)
        ..style = PaintingStyle.fill;
      canvas.drawPath(funnelPath, funnelPaint);

      final funnelStrokePaint = Paint()
        ..color = emitter.color.withValues(alpha: 0.60)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawPath(funnelPath, funnelStrokePaint);

      // 3. Isometric Spout Mouth (Downward elliptical opening aperture)
      final mouthRect = Rect.fromCenter(
        center: Offset(center.dx, center.dy + funnelH * 0.5),
        width: mouthW,
        height: mouthH,
      );
      final mouthVoidPaint = Paint()
        ..color = const Color(0xFF05070B)
        ..style = PaintingStyle.fill;
      canvas.drawOval(mouthRect, mouthVoidPaint);

      final mouthRimPaint = Paint()
        ..color = emitter.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;
      canvas.drawOval(mouthRect, mouthRimPaint);
    }
  }

  /// Cached [TextPainter]s keyed by cup index, remaining amount, and color to avoid layout overhead.
  static final Map<String, TextPainter> _textPainterCache = {};

  /// Clears text painter cache when navigating between screens or resetting.
  static void clearCache() => _textPainterCache.clear();

  @override
  bool shouldRepaint(covariant LevelPainter oldDelegate) {
    if (levelConfig != oldDelegate.levelConfig) return true;
    if (liveCups == null && oldDelegate.liveCups == null) return false;
    if (liveCups == null || oldDelegate.liveCups == null) return true;
    if (liveCups!.length != oldDelegate.liveCups!.length) return true;
    for (int i = 0; i < liveCups!.length; i++) {
      if (liveCups![i].capturedCount != oldDelegate._capturedSnapshot[i]) {
        return true;
      }
    }
    return false;
  }
}
