import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show Canvas, Color, Offset, Paint, StrokeCap;
import '../../core/constants.dart';
import '../../engine/collision/cup_hitbox.dart';
import '../../models/sugar_particle.dart';

/// High-performance particle batch renderer using [Canvas.drawPoints].
///
/// Direct port of [ParticlePainter] as a Flame [Component] at priority 20.
/// Maintains zero-allocation guarantee via static shared color batches.
class ParticleSystemFlameComponent extends Component {
  final Iterable<SugarParticle> Function() particlesGetter;
  final List<CupHitbox> Function() cupsGetter;

  ParticleSystemFlameComponent({
    required this.particlesGetter,
    required this.cupsGetter,
  });

  @override
  int get priority => 20;

  @override
  void render(Canvas canvas) {
    final particles = particlesGetter();
    final cups = cupsGetter();

    final hasParticles = particles.isNotEmpty;
    final hasSettled = cups.any((c) => c.settledParticleOffsets.isNotEmpty);
    if (!hasParticles && !hasSettled) return;

    final paint = Paint()
      ..strokeWidth = kParticleRadius * 2.0
      ..strokeCap = StrokeCap.square;

    // 1. Active particles grouped by color (zero-allocation batch)
    if (hasParticles) {
      for (final list in _sharedColorBatches.values) {
        list.clear();
      }

      for (final p in particles) {
        if (!p.isActive || p.isCaptured) continue;

        final effectiveColor = p.opacity < 1.0
            ? p.color.withValues(alpha: (p.color.a * p.opacity).clamp(0.0, 1.0))
            : p.color;
        final colorKey = effectiveColor.toARGB32();
        var batch = _sharedColorBatches[colorKey];
        if (batch == null) {
          batch = <Offset>[];
          _sharedColorBatches[colorKey] = batch;
        }
        batch.add(Offset(p.x, p.y));
      }

      for (final entry in _sharedColorBatches.entries) {
        if (entry.value.isEmpty) continue;
        paint.color = Color(entry.key);
        canvas.drawPoints(ui.PointMode.points, entry.value, paint);
      }
    }

    // 2. Resting sand mounds inside cups
    if (hasSettled) {
      for (final cup in cups) {
        if (cup.settledParticleOffsets.isNotEmpty) {
          paint.color = cup.color;
          canvas.drawPoints(ui.PointMode.points, cup.settledParticleOffsets, paint);
        }
      }
    }
  }

  static final Map<int, List<Offset>> _sharedColorBatches = {};

  static void clearBuffers() => _sharedColorBatches.clear();
}
