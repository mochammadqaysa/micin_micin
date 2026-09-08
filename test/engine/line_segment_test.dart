import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/engine/collision/line_segment.dart';
import 'package:micin_micin/engine/drawing/drawn_line.dart';
import 'package:micin_micin/models/sugar_particle.dart';

void main() {
  group('LineSegment', () {
    test('computes accurate perpendicular distance to point', () {
      const segment = LineSegment(
        start: Offset(0, 50),
        end: Offset(100, 50),
        thickness: 6.0,
      );

      // Point directly above segment center
      expect(segment.distanceTo(const Offset(50, 40)), closeTo(10.0, 0.001));

      // Point directly on segment
      expect(segment.distanceTo(const Offset(50, 50)), closeTo(0.0, 0.001));

      // Point beyond end point
      expect(segment.distanceTo(const Offset(110, 50)), closeTo(10.0, 0.001));
    });

    test('computes identical perpendicular distance using scalar distanceToPoint', () {
      const segment = LineSegment(
        start: Offset(10, 20),
        end: Offset(90, 80),
        thickness: 4.0,
      );

      final points = [
        const Offset(10, 20),
        const Offset(50, 50),
        const Offset(0, 0),
        const Offset(100, 100),
        const Offset(25, 75),
      ];

      for (final p in points) {
        expect(
          segment.distanceToPoint(p.dx, p.dy),
          equals(segment.distanceTo(p)),
        );
      }
    });

    test('calculates perpendicular normal vector', () {
      // Horizontal line from (0,0) to (10,0)
      const segment = LineSegment(start: Offset(0, 0), end: Offset(10, 0));
      final normal = segment.normal;

      expect(normal.dx, closeTo(0.0, 0.001));
      expect(normal.dy, closeTo(1.0, 0.001));
    });

    test('resolveCollision returns true and alters velocity when particle hits barrier', () {
      // Horizontal floor barrier at y = 50
      const segment = LineSegment(
        start: Offset(0, 50),
        end: Offset(100, 50),
        thickness: 6.0,
      );

      // Particle moving downwards toward the segment (radius = 2.0, thickness/2 = 3.0 => threshold = 5.0)
      final particle = SugarParticle(
        x: 50.0,
        y: 48.0, // distance is 2.0, within 5.0 threshold
        vx: 2.0,
        vy: 4.0,
      );

      final didCollide = segment.resolveCollision(particle, radius: 2.0);

      expect(didCollide, isTrue);
      // vy should have been reflected upwards with restitution 0.3
      expect(particle.vy, closeTo(-1.2, 0.001));
      // vx should have been reduced by friction (0.92)
      expect(particle.vx, closeTo(2.0 * 0.92, 0.001));
      // Positional separation should push particle back to threshold distance
      expect(particle.y, closeTo(45.0, 0.001));
      expect(segment.distanceTo(Offset(particle.x, particle.y)), closeTo(5.0, 0.001));
    });

    test('resolveCollision handles bidirectional drawing orientation consistently', () {
      // Drawn left-to-right
      const segmentLtoR = LineSegment(
        start: Offset(0, 50),
        end: Offset(100, 50),
        thickness: 6.0,
      );
      // Drawn right-to-left
      const segmentRtoL = LineSegment(
        start: Offset(100, 50),
        end: Offset(0, 50),
        thickness: 6.0,
      );

      final p1 = SugarParticle(x: 50.0, y: 48.0, vx: 0.0, vy: 5.0);
      final p2 = SugarParticle(x: 50.0, y: 48.0, vx: 0.0, vy: 5.0);

      expect(segmentLtoR.resolveCollision(p1, radius: 2.0), isTrue);
      expect(segmentRtoL.resolveCollision(p2, radius: 2.0), isTrue);

      // Both should reflect upward identically with negative vy
      expect(p1.vy, closeTo(-1.5, 0.001));
      expect(p2.vy, closeTo(-1.5, 0.001));
      expect(p1.y, closeTo(p2.y, 0.001));
    });

    test('resolveCollision returns false when particle is beyond collision threshold', () {
      const segment = LineSegment(
        start: Offset(0, 50),
        end: Offset(100, 50),
        thickness: 6.0,
      );

      final particle = SugarParticle(
        x: 50.0,
        y: 20.0, // distance is 30.0, way beyond 5.0 threshold
        vx: 0.0,
        vy: 2.0,
      );

      final didCollide = segment.resolveCollision(particle, radius: 2.0);

      expect(didCollide, isFalse);
      expect(particle.vx, equals(0.0));
      expect(particle.vy, equals(2.0));
    });
  });

  group('DrawnLine', () {
    test('converts point stroke into linear segments, filtering zero-length segments', () {
      final line = DrawnLine(
        points: const [
          Offset(0, 0),
          Offset(10, 10),
          Offset(10, 10), // Degenerate duplicate point
          Offset(20, 20),
        ],
        thickness: 6.0,
      );

      final segments = line.toSegments();

      expect(segments.length, equals(2));
      expect(segments[0].start, equals(const Offset(0, 0)));
      expect(segments[0].end, equals(const Offset(10, 10)));
      expect(segments[1].start, equals(const Offset(10, 10)));
      expect(segments[1].end, equals(const Offset(20, 20)));
    });

    test('returns empty segment list when fewer than 2 points exist', () {
      const line = DrawnLine(points: [Offset(10, 10)]);
      expect(line.toSegments(), isEmpty);
    });
  });
}
