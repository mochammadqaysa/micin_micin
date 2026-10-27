import 'dart:math' as math;
import 'dart:ui' show PointMode;
import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show
        Alignment,
        BlendMode,
        Canvas,
        Color,
        Colors,
        FilterQuality,
        HSLColor,
        Offset,
        Paint,
        PaintingStyle,
        Path,
        RadialGradient,
        Rect,
        StrokeCap,
        TextDirection,
        TextPainter,
        TextSpan;
import 'package:pixel_ui/pixel_ui.dart';
import '../../core/constants.dart';
import 'package:micin_micin/core/pixel_sprites.dart';
import 'package:micin_micin/core/pixel_terrain_tokens.dart';

/// Pixel-art terrain background with tiered topographic contour shelves
/// and fine mineral stippling texture.
///
/// Features:
/// - Quantized elevation contour shelves forming authentic 16-bit pixelated terrain steps.
/// - Fine stippling texture points (sand sediment, moss flecks, slate minerals, caustic glimmers).
/// - Dynamic multi-plane parallax response.
/// - Diegetic canvas typography using [PixelText.mulmaru].
/// - Zero-allocation hot path via cached path and point buffers.
class BackgroundFlameComponent extends Component {
  Color backgroundColor;
  String? canvasLabel;
  Color canvasLabelColor;
  double canvasLabelOpacity;
  Offset canvasLabelPositionVirtual;

  double _parallaxX = 0.0;
  double _parallaxY = 0.0;

  // Cached geometry and points for zero-allocation rendering
  double _cachedW = 0.0;
  double _cachedH = 0.0;
  Color? _cachedBgColor;

  final List<Path> _shelfFillPaths = [];
  final List<Path> _shelfEdgePaths = [];
  final List<Paint> _shelfFillPaints = [];
  final List<Paint> _shelfEdgePaints = [];
  final List<double> _shelfParallaxFactors = [0.12, 0.22, 0.35, 0.50];

  final List<Offset> _stippleMineral = [];
  final List<Offset> _stippleMoss = [];
  final List<Offset> _stippleSlate = [];
  final List<Offset> _stippleCaustic = [];

  late final Paint _mineralPaint = Paint()
    ..color = PixelTerrainTokens.sand.withValues(alpha: 0.09)
    ..strokeWidth = 2.0
    ..strokeCap = StrokeCap.square;

  late final Paint _mossPaint = Paint()
    ..color = PixelTerrainTokens.mossLight.withValues(alpha: 0.07)
    ..strokeWidth = 2.0
    ..strokeCap = StrokeCap.square;

  late final Paint _slatePaint = Paint()
    ..color = PixelTerrainTokens.slateDark.withValues(alpha: 0.15)
    ..strokeWidth = 2.0
    ..strokeCap = StrokeCap.square;

  late final Paint _causticPaint = Paint()
    ..color = PixelTerrainTokens.tealCaustic.withValues(alpha: 0.10)
    ..strokeWidth = 2.0
    ..strokeCap = StrokeCap.square;

  late final Paint _terrainPaint = Paint()
    ..filterQuality = FilterQuality.none
    ..color = Colors.white.withValues(alpha: 0.22)
    ..blendMode = BlendMode.softLight;

  BackgroundFlameComponent({
    required this.backgroundColor,
    this.canvasLabel,
    required this.canvasLabelColor,
    this.canvasLabelOpacity = 0.22,
    this.canvasLabelPositionVirtual = const Offset(280.0, 640.0),
  });

  void setParallax(double x, double y) {
    _parallaxX = x;
    _parallaxY = y;
  }

  @override
  int get priority => -10;

  @override
  void render(Canvas canvas) {
    const w = kVirtualWidth;
    const h = kVirtualHeight;

    if (_cachedW != w || _cachedH != h || _cachedBgColor != backgroundColor) {
      _rebuildCache(w, h);
    }

    final rect = Rect.fromLTWH(0, 0, w, h);

    // 1. Base gradient foundation
    _renderBaseBackground(canvas, rect, w, h);

    // 1b. Blended pixel terrain texture overlay (if loaded)
    final terrainImage = PixelSprites.terrain;
    if (terrainImage != null) {
      final src = Rect.fromLTWH(
        0,
        0,
        terrainImage.width.toDouble(),
        terrainImage.height.toDouble(),
      );
      canvas.drawImageRect(
        terrainImage,
        src,
        rect,
        _terrainPaint,
      );
    }

    // 2. Stepped topographic contour shelves
    _renderContourShelves(canvas);

    // 3. Fine mineral stippling texture
    _renderStippling(canvas);

    // 4. Diegetic typography
    _renderLabel(canvas);
  }

  void _rebuildCache(double w, double h) {
    _cachedW = w;
    _cachedH = h;
    _cachedBgColor = backgroundColor;

    _shelfFillPaths.clear();
    _shelfEdgePaths.clear();
    _shelfFillPaints.clear();
    _shelfEdgePaints.clear();

    _stippleMineral.clear();
    _stippleMoss.clear();
    _stippleSlate.clear();
    _stippleCaustic.clear();

    // ── Configure 4 Topographic Contour Shelves ──────────────────────────────
    const shelfConfigs = [
      (
        baseRatio: 0.26,
        amplitude: 24.0,
        freq1: 0.007,
        freq2: 0.015,
        phase: 0.4,
        stepX: 12.0,
        stepY: 8.0,
        fillColor: Color(0x3852B79A), // Semi-translucent Teal shelf
        edgeColor: Color(0x608CE3D0), // Caustic shelf edge
      ),
      (
        baseRatio: 0.46,
        amplitude: 28.0,
        freq1: 0.009,
        freq2: 0.018,
        phase: 1.8,
        stepX: 12.0,
        stepY: 8.0,
        fillColor: Color(0x40376332), // Moss shelf
        edgeColor: Color(0x665A9451), // Moss edge
      ),
      (
        baseRatio: 0.68,
        amplitude: 32.0,
        freq1: 0.008,
        freq2: 0.014,
        phase: 3.2,
        stepX: 12.0,
        stepY: 8.0,
        fillColor: Color(0x4C1E3F3B), // Deep sediment shelf
        edgeColor: Color(0x55E8DFCC), // Sand edge
      ),
      (
        baseRatio: 0.86,
        amplitude: 36.0,
        freq1: 0.010,
        freq2: 0.020,
        phase: 4.6,
        stepX: 12.0,
        stepY: 8.0,
        fillColor: Color(0x700F141C), // Slate bedrock outcrop
        edgeColor: Color(0x6637474F), // Slate highlight
      ),
    ];

    for (final cfg in shelfConfigs) {
      final (fillPath, edgePath) = _createSteppedContourPaths(
        w: w,
        h: h,
        baseRatio: cfg.baseRatio,
        amplitude: cfg.amplitude,
        freq1: cfg.freq1,
        freq2: cfg.freq2,
        phase: cfg.phase,
        stepX: cfg.stepX,
        stepY: cfg.stepY,
      );

      _shelfFillPaths.add(fillPath);
      _shelfEdgePaths.add(edgePath);

      _shelfFillPaints.add(Paint()
        ..color = cfg.fillColor
        ..style = PaintingStyle.fill);

      _shelfEdgePaints.add(Paint()
        ..color = cfg.edgeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.square);
    }

    // ── Generate Discrete Stippling Points (Fine Pixel Texture) ──────────────
    final random = math.Random(108);
    final totalStippleCount = ((w * h) / 950).toInt().clamp(80, 240);

    for (int i = 0; i < totalStippleCount; i++) {
      // Snap to 2px grid for crisp retro pixel-art rendering
      final rx = ((random.nextDouble() * w) / 2.0).round() * 2.0;
      final ry = ((random.nextDouble() * h) / 2.0).round() * 2.0;
      final offset = Offset(rx, ry);

      final dice = random.nextDouble();
      if (dice < 0.35) {
        _stippleMineral.add(offset);
      } else if (dice < 0.65) {
        _stippleMoss.add(offset);
      } else if (dice < 0.85) {
        _stippleSlate.add(offset);
      } else {
        _stippleCaustic.add(offset);
      }
    }
  }

  (Path, Path) _createSteppedContourPaths({
    required double w,
    required double h,
    required double baseRatio,
    required double amplitude,
    required double freq1,
    required double freq2,
    required double phase,
    required double stepX,
    required double stepY,
  }) {
    final fillPath = Path();
    final edgePath = Path();

    const startX = -24.0;
    final endX = w + 24.0;

    double rawY(double x) {
      return h * baseRatio +
          amplitude * math.sin(x * freq1 + phase) +
          (amplitude * 0.45) * math.cos(x * freq2 + phase * 0.8);
    }

    double quantize(double y) => (y / stepY).round() * stepY;

    var currentX = startX;
    var currentY = quantize(rawY(currentX));

    fillPath.moveTo(currentX, currentY);
    edgePath.moveTo(currentX, currentY);

    while (currentX < endX) {
      final nextX = currentX + stepX;
      final nextY = quantize(rawY(nextX));

      // Horizontal step along current quantized elevation
      fillPath.lineTo(nextX, currentY);
      edgePath.lineTo(nextX, currentY);

      // Vertical step to next elevation shelf
      if (nextY != currentY) {
        fillPath.lineTo(nextX, nextY);
        edgePath.lineTo(nextX, nextY);
      }

      currentX = nextX;
      currentY = nextY;
    }

    // Close fillPath down to the bottom border
    fillPath.lineTo(endX, h + 48.0);
    fillPath.lineTo(startX, h + 48.0);
    fillPath.close();

    return (fillPath, edgePath);
  }

  void _renderBaseBackground(Canvas canvas, Rect rect, double w, double h) {
    final hsl = HSLColor.fromColor(backgroundColor);
    final centerColor =
        hsl.withLightness((hsl.lightness + 0.04).clamp(0.0, 1.0)).toColor();
    final edgeColor =
        hsl.withLightness((hsl.lightness * 0.65).clamp(0.0, 1.0)).toColor();

    final px = w > 0 ? (_parallaxX / w).clamp(-0.3, 0.3) : 0.0;
    final py = h > 0 ? (_parallaxY / h).clamp(-0.3, 0.3) : 0.0;

    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(px, py),
        radius: 0.95,
        colors: [centerColor, backgroundColor, edgeColor],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, bgPaint);
  }

  void _renderContourShelves(Canvas canvas) {
    for (int i = 0; i < _shelfFillPaths.length; i++) {
      final factor = _shelfParallaxFactors[i];
      final dx = _parallaxX * factor;
      final dy = _parallaxY * factor;

      canvas.save();
      canvas.translate(dx, dy);

      // Draw shelf fill
      canvas.drawPath(_shelfFillPaths[i], _shelfFillPaints[i]);

      // Draw stepped pixelated edge highlight
      canvas.drawPath(_shelfEdgePaths[i], _shelfEdgePaints[i]);

      canvas.restore();
    }
  }

  void _renderStippling(Canvas canvas) {
    if (_stippleMineral.isEmpty) return;

    canvas.save();
    canvas.translate(_parallaxX * 0.20, _parallaxY * 0.20);

    canvas.drawPoints(PointMode.points, _stippleMineral, _mineralPaint);
    canvas.drawPoints(PointMode.points, _stippleMoss, _mossPaint);
    canvas.drawPoints(PointMode.points, _stippleSlate, _slatePaint);
    canvas.drawPoints(PointMode.points, _stippleCaustic, _causticPaint);

    canvas.restore();
  }

  void _renderLabel(Canvas canvas) {
    if (canvasLabel == null || canvasLabel!.isEmpty) return;

    final tp = TextPainter(
      text: TextSpan(
        text: canvasLabel,
        style: PixelText.mulmaru(
          fontSize: 28.0,
          color: canvasLabelColor.withValues(
            alpha: canvasLabelOpacity.clamp(0.0, 1.0),
          ),
          shadowColor: PixelTerrainTokens.slateBedrock,
          shadowOffset: const Offset(1, 1),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(
      canvas,
      Offset(canvasLabelPositionVirtual.dx, canvasLabelPositionVirtual.dy),
    );
  }
}

