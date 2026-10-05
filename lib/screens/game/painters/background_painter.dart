import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme.dart';

/// Renders a minimalist dark obsidian void background with multi-plane starlight sand dust.
class BackgroundPainter extends CustomPainter {
  final Offset parallaxOffset;

  const BackgroundPainter({this.parallaxOffset = Offset.zero});

  @override
  void paint(Canvas canvas, Size size) {
    // Fill base deep obsidian void (#0A0D14) with subtle radial vignette
    final rect = Offset.zero & size;
    final centerAlignment = Alignment(
      (parallaxOffset.dx / size.width).clamp(-0.3, 0.3),
      (parallaxOffset.dy / size.height).clamp(-0.3, 0.3),
    );

    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: centerAlignment,
        radius: 0.9,
        colors: const [
          Color(0xFF141A29), // Center ambient glass elevation
          GlassTokens.obsidianVoid, // Base obsidian void floor (#0A0D14)
          Color(0xFF06080D), // Edge dark void
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // Multi-plane parallax grain & ambient dust particles
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
      oldDelegate.parallaxOffset != parallaxOffset;
}
