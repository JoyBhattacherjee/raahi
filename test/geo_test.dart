import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:raahi/utils/format.dart';
import 'package:raahi/utils/geo.dart';

void main() {
  group('geo helpers', () {
    test('manhattanRoute makes an L-shaped path', () {
      final route = manhattanRoute(const Offset(1, 1), const Offset(4, 3));
      expect(route, const [Offset(1, 1), Offset(4, 1), Offset(4, 3)]);

      final vertical = manhattanRoute(
        const Offset(1, 1),
        const Offset(4, 3),
        horizontalFirst: false,
      );
      expect(vertical, const [Offset(1, 1), Offset(1, 3), Offset(4, 3)]);
    });

    test('straight routes have no corner', () {
      final route = manhattanRoute(const Offset(2, 2), const Offset(2, 6));
      expect(route.length, 2);
    });

    test('polylineLength sums the segments', () {
      expect(
        polylineLength(const [Offset(0, 0), Offset(3, 0), Offset(3, 4)]),
        7,
      );
    });

    test('sampleAlong returns start, middle and end', () {
      const pts = [Offset(0, 0), Offset(4, 0), Offset(4, 4)];
      expect(sampleAlong(pts, 0).point, const Offset(0, 0));
      expect(sampleAlong(pts, 0.5).point, const Offset(4, 0));
      expect(sampleAlong(pts, 1).point, const Offset(4, 4));
    });

    test('partialPath stops at the travelled fraction', () {
      const pts = [Offset(0, 0), Offset(4, 0), Offset(4, 4)];
      final half = partialPath(pts, 0.25);
      expect(half.first, const Offset(0, 0));
      expect(half.last, const Offset(2, 0));
    });

    test('boundsOf covers every point', () {
      final b = boundsOf(const [Offset(1, 5), Offset(4, 2), Offset(3, 9)]);
      expect(b.left, 1);
      expect(b.right, 4);
      expect(b.top, 2);
      expect(b.bottom, 9);
    });
  });

  group('formatting', () {
    test('money groups thousands', () {
      expect(money(118), '₹118');
      expect(money(1250), '₹1,250');
      expect(money(1234567), '₹1,234,567');
    });

    test('dateTime formats 12-hour time', () {
      expect(dateTime(DateTime(2026, 10, 12, 18, 45)), '12 Oct, 6:45 PM');
      expect(dateTime(DateTime(2026, 1, 3, 0, 5)), '3 Jan, 12:05 AM');
    });
  });
}
