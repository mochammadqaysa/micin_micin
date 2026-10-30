import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../engine/collision/cup_hitbox.dart';
import '../../../models/sugar_particle.dart';

/// High-performance particle batch renderer.
///
/// Groups particles by color and renders them using [Canvas.drawPoints] (REQ-003)
/// instead of invoking individual [Canvas.drawCircle] calls per particle.
/// Also batch-renders resting sand mounds accumulated inside target cups (REQ-006).
class ParticlePainter extends CustomPainter {
  final Iterable<SugarParticle> particles;
  final List<CupHitbox>? cups;

  ParticlePainter(this.particles, {this.cups});

  static final Paint _sharedPaint = Paint()
    ..strokeWidth = kParticleRadius * 2.0
    ..strokeCap = StrokeCap.square;

  @override
  void paint(Canvas canvas, Size size) {
    final hasParticles = particles.isNotEmpty;
    final hasSettled = cups != null && cups!.any((c) => c.settledParticleOffsets.isNotEmpty);
    if (!hasParticles && !hasSettled) return;

    final paint = _sharedPaint;

    // 1. Batch group active particle offsets by color and crystalline opacity (PRN-001)
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

    // 2. Batch render resting sand mounds inside target cups (REQ-006)
    if (hasSettled) {
      for (final cup in cups!) {
        if (cup.settledParticleOffsets.isNotEmpty) {
          paint.color = cup.color;
          canvas.drawPoints(ui.PointMode.points, cup.settledParticleOffsets, paint);
        }
      }
    }
  }

  /// Static reusable point batches keyed by color ARGB32 to eliminate per-frame allocations (PRN-001).
  static final Map<int, List<Offset>> _sharedColorBatches = {};

  /// Clears reusable point buffers between sessions or on demand.
  static void clearBuffers() {
    _sharedColorBatches.clear();
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
