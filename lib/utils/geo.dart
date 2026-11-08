import 'dart:math' as math;
import 'dart:ui';

/// Builds an L-shaped route that follows the road grid.
List<Offset> manhattanRoute(Offset a, Offset b, {bool horizontalFirst = true}) {
  if (a.dx == b.dx || a.dy == b.dy) return [a, b];
  final corner = horizontalFirst ? Offset(b.dx, a.dy) : Offset(a.dx, b.dy);
  return [a, corner, b];
}

/// Manhattan distance between two grid points, in grid units.
double manhattan(Offset a, Offset b) => (a.dx - b.dx).abs() + (a.dy - b.dy).abs();

double polylineLength(List<Offset> pts) {
  var total = 0.0;
  for (var i = 0; i < pts.length - 1; i++) {
    total += (pts[i + 1] - pts[i]).distance;
  }
  return total;
}

class PathSample {
  final Offset point;

  /// Heading in radians (0 = pointing right / +x, pi/2 = pointing down / +y).
  final double angle;

  const PathSample(this.point, this.angle);
}

/// Returns the position and heading at fraction [t] (0..1) along [pts].
PathSample sampleAlong(List<Offset> pts, double t) {
  if (pts.isEmpty) return const PathSample(Offset.zero, 0);
  if (pts.length == 1) return PathSample(pts.first, 0);

  final clamped = t.clamp(0.0, 1.0).toDouble();
  final target = polylineLength(pts) * clamped;
  var walked = 0.0;

  for (var i = 0; i < pts.length - 1; i++) {
    final seg = pts[i + 1] - pts[i];
    final len = seg.distance;
    if (len == 0) continue;
    if (walked + len >= target || i == pts.length - 2) {
      final local = ((target - walked) / len).clamp(0.0, 1.0).toDouble();
      return PathSample(
        pts[i] + seg * local,
        math.atan2(seg.dy, seg.dx),
      );
    }
    walked += len;
  }
  final last = pts.last - pts[pts.length - 2];
  return PathSample(pts.last, math.atan2(last.dy, last.dx));
}

/// Returns the part of [pts] that has been travelled at fraction [t].
List<Offset> partialPath(List<Offset> pts, double t) {
  if (pts.length < 2) return pts;
  final clamped = t.clamp(0.0, 1.0).toDouble();
  if (clamped <= 0) return [pts.first];
  final target = polylineLength(pts) * clamped;
  var walked = 0.0;
  final out = <Offset>[pts.first];

  for (var i = 0; i < pts.length - 1; i++) {
    final seg = pts[i + 1] - pts[i];
    final len = seg.distance;
    if (walked + len >= target) {
      final local = len == 0 ? 0.0 : (target - walked) / len;
      out.add(pts[i] + seg * local);
      return out;
    }
    out.add(pts[i + 1]);
    walked += len;
  }
  return out;
}

/// Bounding box of a set of grid points.
Rect boundsOf(List<Offset> pts) {
  var minX = pts.first.dx, maxX = pts.first.dx;
  var minY = pts.first.dy, maxY = pts.first.dy;
  for (final p in pts) {
    minX = math.min(minX, p.dx);
    maxX = math.max(maxX, p.dx);
    minY = math.min(minY, p.dy);
    maxY = math.max(maxY, p.dy);
  }
  return Rect.fromLTRB(minX, minY, maxX, maxY);
}
