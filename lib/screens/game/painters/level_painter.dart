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

      // Option A Pure Vector Glass Body: Translucent obsidian-mineral wash
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            cup.color.withValues(alpha: 0.16),
            const Color(0xFF0A0D14).withValues(alpha: 0.72),
          ],
        ).createShader(rect)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          bottomLeft: const Radius.circular(8.0),
          bottomRight: const Radius.circular(8.0),
        ),
        fillPaint,
      );

      // Specular gradient rim & outer contour (1.6px crisp line)
      final rimPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.65),
            cup.color.withValues(alpha: 0.90),
            cup.color.withValues(alpha: 0.35),
          ],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path()
        ..moveTo(rect.left, rect.top)
        ..lineTo(rect.left, rect.bottom - 8.0)
        ..quadraticBezierTo(rect.left, rect.bottom, rect.left + 8.0, rect.bottom)
        ..lineTo(rect.right - 8.0, rect.bottom)
        ..quadraticBezierTo(rect.right, rect.bottom, rect.right, rect.bottom - 8.0)
        ..lineTo(rect.right, rect.top);

      canvas.drawPath(path, rimPaint);

      // Top aperture selective membrane halo & core line
      final haloPaint = Paint()
        ..color = cup.color.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;
      canvas.drawLine(
        Offset(rect.left + 4.0, rect.top),
        Offset(rect.right - 4.0, rect.top),
        haloPaint,
      );

      final membranePaint = Paint()
        ..color = cup.color.withValues(alpha: 0.80)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;
      canvas.drawLine(
        Offset(rect.left + 2.0, rect.top),
        Offset(rect.right - 2.0, rect.top),
        membranePaint,
      );

      // Target countdown text on cup face (REQ-005, AC-004, PRN-002)
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

      textPainter.paint(
        canvas,
        Offset(
          rect.center.dx - textPainter.width / 2,
          rect.center.dy - textPainter.height / 2,
        ),
      );
    }
  }

  void _renderEmitters(Canvas canvas, Size size) {
    for (final emitter in levelConfig.emitters) {
      final center = Offset(
        emitter.x,
        emitter.y,
      );

      // Outer atmospheric breathing halo
      final atmosphericHaloPaint = Paint()
        ..color = emitter.color.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(center, 9.5, atmosphericHaloPaint);

      // Concentric halo ring
      final concentricFillPaint = Paint()
        ..color = emitter.color.withValues(alpha: 0.10)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, 7.0, concentricFillPaint);

      final concentricStrokePaint = Paint()
        ..color = emitter.color.withValues(alpha: 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(center, 7.0, concentricStrokePaint);

      // Inner spout droplet nozzle
      final spoutPaint = Paint()
        ..color = emitter.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, 3.5, spoutPaint);
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
