import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/engine/particle/particle_pool.dart';
import 'package:micin_micin/models/sugar_particle.dart';

void main() {
  group('ParticlePool', () {
    test('initializes with specified capacity', () {
      final pool = ParticlePool(capacity: 10);
      expect(pool.capacity, equals(10));
      expect(pool.activeCount, equals(0));
      expect(pool.activeParticles, isEmpty);
    });

    test('acquires particles sequentially until capacity is reached', () {
      final pool = ParticlePool(capacity: 3);

      final p1 = pool.acquire();
      final p2 = pool.acquire();
      final p3 = pool.acquire();
      final p4 = pool.acquire();

      expect(p1, isNotNull);
      expect(p2, isNotNull);
      expect(p3, isNotNull);
      expect(p4, isNull); // Capacity exhausted
      expect(pool.activeCount, equals(3));
      expect(pool.activeParticles.length, equals(3));
    });

    test('releasing a particle resets it and allows reacquisition', () {
      final pool = ParticlePool(capacity: 1);

      final p1 = pool.acquire()!;
      p1.vx = 5.0;
      p1.vy = 6.0;

      expect(pool.acquire(), isNull);

      pool.release(p1);

      expect(p1.isActive, isFalse);
      expect(p1.vx, equals(0.0));
      expect(p1.vy, equals(0.0));
      expect(pool.activeCount, equals(0));

      final pReacquired = pool.acquire();
      expect(pReacquired, isNotNull);
      expect(identical(p1, pReacquired), isTrue);
    });

    test('releaseAll() resets all active particles at once', () {
      final pool = ParticlePool(capacity: 5);

      final p1 = pool.acquire()!;
      final p2 = pool.acquire()!;
      final p3 = pool.acquire()!;

      expect(pool.activeCount, equals(3));

      pool.releaseAll();

      expect(pool.activeCount, equals(0));
      expect(pool.activeParticles, isEmpty);
      expect(p1.isActive, isFalse);
      expect(p2.isActive, isFalse);
      expect(p3.isActive, isFalse);
    });

    test('captured particles are excluded from activeParticles getter', () {
      final pool = ParticlePool(capacity: 2);
      final p1 = pool.acquire()!;
      final p2 = pool.acquire()!;

      p1.isCaptured = true;

      expect(pool.activeParticles.length, equals(1));
      expect(pool.activeParticles.first, equals(p2));
    });

    test('forEachActive executes callback only for active and uncaptured particles', () {
      final pool = ParticlePool(capacity: 3);
      final p1 = pool.acquire()!;
      final p2 = pool.acquire()!;
      pool.acquire()!; // p3 is active

      p1.isCaptured = true; // captured

      final visited = <SugarParticle>[];
      pool.forEachActive((p) => visited.add(p));

      expect(visited.length, equals(2));
      expect(visited.contains(p1), isFalse);
      expect(visited.contains(p2), isTrue);
    });
  });
}
