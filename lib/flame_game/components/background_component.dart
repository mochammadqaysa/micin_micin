import 'dart:math' show Random;
import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show
        Alignment,
        Canvas,
        Color,
        HSLColor,
        Offset,
        Paint,
        RadialGradient,
        Rect,
        TextDirection,
        TextPainter,
        TextSpan,
        TextStyle,
        FontWeight;

/// Chromatic chalkboard background with multi-plane parallax grain dust
/// and diegetic canvas typography embedded behind gameplay.
///
/// Renders in world space — because [MicinGame] uses a [CameraComponent]
/// scaled to the virtual 400×700 canvas, this component must account for
/// camera bounds to cover the full screen.
///
/// Direct port of [BackgroundPainter] as a Flame [Component] at priority -10.
class BackgroundFlameComponent extends Component {
  Color backgroundColor;
  String? canvasLabel;
  Color canvasLabelColor;
  double canvasLabelOpacity;
  Offset canvasLabelPositionVirtual;

  double _parallaxX = 0.0;
  double _parallaxY = 0.0;

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
    final game = findGame()!;
    // Use the full canvas size to cover any letterbox margins
    final w = game.canvasSize.x;
    final h = game.canvasSize.y;
    final rect = Rect.fromLTWH(0, 0, w, h);

    _renderBackground(canvas, rect, w, h);
    _renderLabel(canvas);
    _renderGrain(canvas, w, h);
  }

  void _renderBackground(Canvas canvas, Rect rect, double w, double h) {
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
        radius: 0.9,
        colors: [centerColor, backgroundColor, edgeColor],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, bgPaint);
  }

  void _renderLabel(Canvas canvas) {
    if (canvasLabel == null || canvasLabel!.isEmpty) return;

    final tp = TextPainter(
      text: TextSpan(
        text: canvasLabel,
        style: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 32.0,
          fontWeight: FontWeight.bold,
          color: canvasLabelColor.withValues(
            alpha: canvasLabelOpacity.clamp(0.0, 1.0),
          ),
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(
      canvas,
      Offset(canvasLabelPositionVirtual.dx, canvasLabelPositionVirtual.dy),
    );
  }

  void _renderGrain(Canvas canvas, double w, double h) {
    final random = Random(42);
    final baseCount = ((w * h) / 1200).toInt().clamp(60, 300);

    final p1 = Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.015);
    final l1 = (baseCount * 0.6).round();
    for (int i = 0; i < l1; i++) {
      final bx = random.nextDouble() * w;
      final by = random.nextDouble() * h;
      canvas.drawCircle(
        Offset(
          (bx + _parallaxX * 0.12) % w,
          (by + _parallaxY * 0.12) % h,
        ),
        0.65,
        p1,
      );
    }

    final p2 = Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.028);
    final l2 = (baseCount * 0.3).round();
    for (int i = 0; i < l2; i++) {
      final bx = random.nextDouble() * w;
      final by = random.nextDouble() * h;
      canvas.drawCircle(
        Offset(
          (bx + _parallaxX * 0.25) % w,
          (by + _parallaxY * 0.25) % h,
        ),
        0.95,
        p2,
      );
    }

    final p3 = Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.045);
    final l3 = (baseCount * 0.1).round().clamp(6, 30);
    for (int i = 0; i < l3; i++) {
      final bx = random.nextDouble() * w;
      final by = random.nextDouble() * h;
      canvas.drawCircle(
        Offset(
          (bx + _parallaxX * 0.45) % w,
          (by + _parallaxY * 0.45) % h,
        ),
        1.35,
        p3,
      );
    }
  }
}
