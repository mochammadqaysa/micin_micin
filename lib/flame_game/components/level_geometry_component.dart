import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show
        Canvas,
        Color,
        Colors,
        FontWeight,
        Offset,
        Paint,
        PaintingStyle,
        Path,
        Radius,
        Rect,
        RRect,
        StrokeCap,
        StrokeJoin,
        TextDirection,
        TextPainter,
        TextSpan,
        TextStyle;
import '../../core/stage_visual_theme.dart';
import '../../engine/collision/cup_hitbox.dart';
import '../../models/level_config.dart';

/// Renders authentic flat vector level geometry: typographical comma spouts (`,`),
/// flat vector cups with centered dynamic countdown numbers, obstacle beams (`balk`),
/// and minimalist color filter gates (REQ-004, REQ-005, CON-001).
///
/// Overhauled from Pixel Koi Zen assets into authentic Bart Bonte flat vector primitives
/// with a 60/120 FPS zero-allocation hot path.
class LevelGeometryFlameComponent extends Component {
  final LevelConfig levelConfig;
  final List<CupHitbox> Function() liveCupsGetter;
  final Color? defaultObstacleColor;

  static const Color _goldColor = Color(0xFFFFD54F);

  // ── Pre-cached vector paths for Zero-Allocation Hot Path ───────────────────
  static final Path _commaPath = _buildAuthenticCommaPath();

  final List<Path> _cachedCupPaths = [];
  final List<Path> _cachedHandlePaths = [];
  final List<Offset> _cachedCupCenters = [];

  final List<RRect> _cachedFilterRRects = [];
  final List<Offset> _cachedFilterCenters = [];

  final List<RRect> _cachedObstacleRRects = [];
  final List<Offset> _cachedObstacleCenters = [];

  // ── Reusable Paint instances (zero heap allocation in render loop) ───────────
  late final Paint _commaFillPaint = Paint()..style = PaintingStyle.fill;

  late final Paint _cupStrokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  late final Paint _filterFillPaint = Paint()..style = PaintingStyle.fill;
  late final Paint _filterStrokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
  late final Paint _filterPipPaint = Paint()..style = PaintingStyle.fill;

  late final Paint _obstacleFillPaint = Paint()..style = PaintingStyle.fill;
  late final Paint _obstacleStrokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0
    ..color = Colors.black.withValues(alpha: 0.18);

  LevelGeometryFlameComponent({
    required this.levelConfig,
    required this.liveCupsGetter,
    this.defaultObstacleColor,
  }) {
    _precomputeGeometryCache();
  }

  void _precomputeGeometryCache() {
    // 1. Cups geometry
    _cachedCupPaths.clear();
    _cachedHandlePaths.clear();
    _cachedCupCenters.clear();

    for (final cup in levelConfig.cups) {
      final rect = Rect.fromLTWH(cup.x, cup.y, cup.width, cup.height);
      const corner = 6.0;

      // Open top U-shaped cup vessel
      final cupPath = Path()
        ..moveTo(rect.left, rect.top)
        ..lineTo(rect.left, rect.bottom - corner)
        ..quadraticBezierTo(
            rect.left, rect.bottom, rect.left + corner, rect.bottom)
        ..lineTo(rect.right - corner, rect.bottom)
        ..quadraticBezierTo(
            rect.right, rect.bottom, rect.right, rect.bottom - corner)
        ..lineTo(rect.right, rect.top);

      _cachedCupPaths.add(cupPath);

      // Handle on right side
      final hTop = rect.top + rect.height * 0.22;
      final hBottom = rect.top + rect.height * 0.78;
      final hReach = rect.right + 12.0;

      final handlePath = Path()
        ..moveTo(rect.right, hTop)
        ..cubicTo(
          hReach,
          hTop + 2.0,
          hReach,
          hBottom - 2.0,
          rect.right,
          hBottom,
        );

      _cachedHandlePaths.add(handlePath);
      _cachedCupCenters
          .add(Offset(rect.center.dx, rect.top + rect.height * 0.52));
    }

    // 2. Filter gates geometry
    _cachedFilterRRects.clear();
    _cachedFilterCenters.clear();

    for (final filter in levelConfig.filters) {
      final rect = Rect.fromLTWH(
        filter.x,
        filter.y,
        filter.width,
        filter.height,
      );
      _cachedFilterRRects.add(
        RRect.fromRectAndRadius(rect, const Radius.circular(3.0)),
      );
      _cachedFilterCenters.add(rect.center);
    }

    // 3. Obstacle beams geometry
    _cachedObstacleRRects.clear();
    _cachedObstacleCenters.clear();

    for (final obstacle in levelConfig.obstacles) {
      final rect = Rect.fromLTWH(
        obstacle.x,
        obstacle.y,
        obstacle.width,
        obstacle.height,
      );
      final corner = (obstacle.height / 2.0).clamp(2.0, 6.0);
      _cachedObstacleRRects.add(
        RRect.fromRectAndRadius(rect, Radius.circular(corner)),
      );
      _cachedObstacleCenters.add(rect.center);
    }
  }

  @override
  int get priority => 10;

  @override
  void render(Canvas canvas) {
    final liveCups = liveCupsGetter();
    _renderObstacles(canvas);
    _renderColorFilters(canvas);
    _renderCups(canvas, liveCups);
    _renderEmitters(canvas);
  }

  // ── Obstacle Beams (`balk`) ───────────────────────────────────────────────

  void _renderObstacles(Canvas canvas) {
    if (levelConfig.obstacles.isEmpty) return;

    final fallbackColor = defaultObstacleColor ??
        StageVisualTheme.forLevel(levelConfig.id).obstacleColor;

    for (int i = 0; i < levelConfig.obstacles.length; i++) {
      final obstacle = levelConfig.obstacles[i];
      final rrect = _cachedObstacleRRects[i];
      final center = _cachedObstacleCenters[i];

      _obstacleFillPaint.color = obstacle.color ?? fallbackColor;

      if (obstacle.rotation != 0.0) {
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(obstacle.rotation);
        canvas.translate(-center.dx, -center.dy);

        canvas.drawRRect(rrect, _obstacleFillPaint);
        canvas.drawRRect(rrect, _obstacleStrokePaint);

        canvas.restore();
      } else {
        canvas.drawRRect(rrect, _obstacleFillPaint);
        canvas.drawRRect(rrect, _obstacleStrokePaint);
      }
    }
  }

  // ── Minimalist Flat Color Filter Gates ─────────────────────────────────────

  void _renderColorFilters(Canvas canvas) {
    for (int i = 0; i < levelConfig.filters.length; i++) {
      final filter = levelConfig.filters[i];
      final rrect = _cachedFilterRRects[i];
      final center = _cachedFilterCenters[i];

      // Translucent filter chamber body
      _filterFillPaint.color = filter.targetColor.withValues(alpha: 0.35);
      canvas.drawRRect(rrect, _filterFillPaint);

      // Clean vector outline
      _filterStrokePaint.color = filter.targetColor;
      canvas.drawRRect(rrect, _filterStrokePaint);

      // Center jewel pip
      _filterPipPaint.color = filter.targetColor;
      canvas.drawCircle(center, 2.5, _filterPipPaint);
    }
  }

  // ── Flat Vector Outline Cups with Centered Countdown ──────────────────────

  void _renderCups(Canvas canvas, List<CupHitbox> liveCups) {
    for (int i = 0; i < levelConfig.cups.length; i++) {
      final cup = levelConfig.cups[i];
      final currentCaptured =
          (i < liveCups.length) ? liveCups[i].capturedCount : 0;

      final cupPath = _cachedCupPaths[i];
      final handlePath = _cachedHandlePaths[i];
      final center = _cachedCupCenters[i];

      // 1. Draw flat vector cup body & side handle
      _cupStrokePaint.color = cup.color;
      canvas.drawPath(cupPath, _cupStrokePaint);
      canvas.drawPath(handlePath, _cupStrokePaint);

      // 2. Dynamic centered countdown number (turns to Gold when 0)
      final remaining = (cup.targetAmount - currentCaptured).clamp(
        0,
        cup.targetAmount,
      );
      final isComplete = remaining == 0;
      final textColor = isComplete ? _goldColor : cup.color;
      final cacheKey = '$i:$remaining:${textColor.toARGB32()}';

      var tp = _textPainterCache[cacheKey];
      if (tp == null) {
        tp = TextPainter(
          text: TextSpan(
            text: '$remaining',
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
              letterSpacing: 0.5,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        _textPainterCache[cacheKey] = tp;
      }

      // 3. 80ms capture pulse
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsed =
          now - ((i < liveCups.length) ? liveCups[i].lastCaptureMs : 0);
      final double scale;
      if (elapsed >= 0 && elapsed < 80) {
        scale = 1.0 + 0.08 * math.sin((elapsed / 80.0) * math.pi);
      } else {
        scale = 1.0;
      }

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

  // ── Typographical Comma Spouts (`,`) ───────────────────────────────────────

  void _renderEmitters(Canvas canvas) {
    for (final emitter in levelConfig.emitters) {
      canvas.save();
      canvas.translate(emitter.x, emitter.y);

      _commaFillPaint.color = emitter.color;
      canvas.drawPath(_commaPath, _commaFillPaint);

      canvas.restore();
    }
  }

  /// Procedural Bézier path of the iconic typographical comma spout (`,`).
  ///
  /// Replicated 1:1 from the vector shape records of decompiled `SugarSugar.swf`
  /// shape ID 483 (`swc_komma`), normalized so the sugar emission tip terminates
  /// precisely at origin `(0.0, 0.0)`.
  static Path _buildAuthenticCommaPath({double scale = 1.8}) {
    const tipX = 1.9;
    const tipY = 15.95;
    double nx(double x) => (x - tipX) * scale;
    double ny(double y) => (y - tipY) * scale;

    final path = Path()
      ..moveTo(nx(7.0), ny(12.25))
      ..quadraticBezierTo(nx(5.5), ny(14.35), nx(1.9), ny(15.95))
      ..lineTo(nx(0.0), ny(12.45))
      ..quadraticBezierTo(nx(2.3), ny(11.4), nx(3.15), ny(10.4))
      ..quadraticBezierTo(nx(4.0), ny(9.35), nx(4.1), ny(7.9))
      ..lineTo(nx(0.0), ny(7.9))
      ..lineTo(nx(0.0), ny(0.0))
      ..lineTo(nx(8.5), ny(0.0))
      ..lineTo(nx(8.5), ny(6.55))
      ..quadraticBezierTo(nx(8.5), ny(10.15), nx(7.0), ny(12.25))
      ..close();
    return path;
  }

  static final Map<String, TextPainter> _textPainterCache = {};
  static void clearCache() => _textPainterCache.clear();
}
