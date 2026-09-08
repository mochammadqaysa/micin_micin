import '../../core/constants.dart';
import '../../models/sugar_particle.dart';

/// Pre-allocated object pool for [SugarParticle] instances.
///
/// Eliminates garbage collector overhead by pre-allocating particles
/// and recycling them through in-place resets.
class ParticlePool {
  final List<SugarParticle> _pool;

  ParticlePool({int capacity = kPoolCapacity})
      : _pool = List.generate(
          capacity,
          (_) => SugarParticle(x: 0.0, y: 0.0),
        );

  /// Scans pool for the first inactive particle, marks it active, and returns it.
  ///
  /// Returns `null` if all particles in the pool are currently active.
  SugarParticle? acquire() {
    for (final particle in _pool) {
      if (!particle.isActive) {
        particle.isActive = true;
        return particle;
      }
    }
    return null;
  }

  /// Releases an individual particle back to the pool by resetting its state.
  void release(SugarParticle particle) {
    particle.reset();
  }

  /// Releases all active particles back into the pool.
  ///
  /// Required by [ParticleController.resetAll] for total board reset (REQ-012).
  void releaseAll() {
    for (final particle in _pool) {
      if (particle.isActive) {
        particle.reset();
      }
    }
  }

  /// Returns an [Iterable] of active, uncaptured particles currently simulating in the world.
  ///
  /// Eliminates per-frame heap array allocations on 60/120 FPS loops (PRN-001).
  Iterable<SugarParticle> get activeParticles =>
      _pool.where((p) => p.isActive && !p.isCaptured);

  /// Iterates over active, uncaptured particles in-place with zero allocations.
  void forEachActive(void Function(SugarParticle p) action) {
    for (int i = 0; i < _pool.length; i++) {
      final p = _pool[i];
      if (p.isActive && !p.isCaptured) {
        action(p);
      }
    }
  }

  /// Total pre-allocated capacity of this pool.
  int get capacity => _pool.length;

  /// Count of currently active particles in the pool.
  int get activeCount => _pool.where((p) => p.isActive).length;
}
