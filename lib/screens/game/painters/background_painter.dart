import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme.dart';

/// Renders a chromatic chalkboard background with multi-plane starlight sand dust
/// and diegetic canvas typography (REQ-003, REQ-004, AC-003, AC-004).
class BackgroundPainter extends CustomPainter {
  final Offset parallaxOffset;
  final Color backgroundColor;
  final String? canvasLabel;
  final Color canvasLabelColor;
  final double canvasLabelOpacity;
  final Offset canvasLabelPosition;
  final Offset virtualOffset;
  final double virtualScale;

  const BackgroundPainter({
    this.parallaxOffset = Offset.zero,
    this.backgroundColor = GlassTokens.obsidianVoid,
    this.canvasLabel,
    this.canvasLabelColor = const Color(0xFFFFFFFF),
    this.canvasLabelOpacity = 0.22,
    this.canvasLabelPosition = const Offset(280.0, 640.0),
    this.virtualOffset = Offset.zero,
    this.virtualScale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final centerAlignment = Alignment(
      (parallaxOffset.dx / size.width).clamp(-0.3, 0.3),
      (parallaxOffset.dy / size.height).clamp(-0.3, 0.3),
    );

    // 1. Chromatic chalkboard base fill with subtle radial vignette
    final hsl = HSLColor.fromColor(backgroundColor);
    final centerColor = hsl.withLightness((hsl.lightness + 0.04).clamp(0.0, 1.0)).toColor();
    final edgeColor = hsl.withLightness((hsl.lightness * 0.65).clamp(0.0, 1.0)).toColor();

    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: centerAlignment,
        radius: 0.9,
        colors: [
          centerColor,
          backgroundColor,
          edgeColor,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // 2. Diegetic Canvas Typography embedded directly onto the canvas floor (REQ-004, AC-004)
    if (canvasLabel != null && canvasLabel!.isNotEmpty) {
      final effectiveScale = virtualScale > 0 ? virtualScale : 1.0;
      final renderPos = virtualOffset + (canvasLabelPosition * effectiveScale);

      final textSpan = TextSpan(
        text: canvasLabel,
        style: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 32.0 * effectiveScale,
          fontWeight: FontWeight.bold,
          color: canvasLabelColor.withValues(
            alpha: canvasLabelOpacity.clamp(0.0, 1.0),
          ),
          letterSpacing: 1.5,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas, renderPos);
    }

    // 3. Multi-plane parallax grain & ambient dust particles
    final random = Random(42); // Deterministic seed
    final int baseCount = ((size.width * size.height) / 1200).toInt().clamp(60, 300);

    // Layer 1: Distant fine sand dust (slow drift, subtle)
    final layer1Paint = Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.015);
    final int l1Count = (baseCount * 0.6).round();
    for (int i = 0; i < l1Count; i++) {
      final bx = random.nextDouble() * size.width;
      final by = random.nextDouble() * size.height;
      final dx = (bx + parallaxOffset.dx * 0.12) % size.width;
      final dy = (by + parallaxOffset.dy * 0.12) % size.height;
      canvas.drawCircle(Offset(dx, dy), 0.65, layer1Paint);
    }

    // Layer 2: Mid-plane granular chalkboard texture
    final layer2Paint = Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.028);
    final int l2Count = (baseCount * 0.3).round();
    for (int i = 0; i < l2Count; i++) {
      final bx = random.nextDouble() * size.width;
      final by = random.nextDouble() * size.height;
      final dx = (bx + parallaxOffset.dx * 0.25) % size.width;
      final dy = (by + parallaxOffset.dy * 0.25) % size.height;
      canvas.drawCircle(Offset(dx, dy), 0.95, layer2Paint);
    }

    // Layer 3: Near ambient floating specular dust (highest parallax drift)
    final layer3Paint = Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.045);
    final int l3Count = (baseCount * 0.1).round().clamp(6, 30);
    for (int i = 0; i < l3Count; i++) {
      final bx = random.nextDouble() * size.width;
      final by = random.nextDouble() * size.height;
      final dx = (bx + parallaxOffset.dx * 0.45) % size.width;
      final dy = (by + parallaxOffset.dy * 0.45) % size.height;
      canvas.drawCircle(Offset(dx, dy), 1.35, layer3Paint);
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) =>
      oldDelegate.parallaxOffset != parallaxOffset ||
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.canvasLabel != canvasLabel ||
      oldDelegate.canvasLabelColor != canvasLabelColor ||
      oldDelegate.canvasLabelOpacity != canvasLabelOpacity ||
      oldDelegate.canvasLabelPosition != canvasLabelPosition ||
      oldDelegate.virtualOffset != virtualOffset ||
      oldDelegate.virtualScale != virtualScale;
}
