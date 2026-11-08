import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../utils/geo.dart';

/// Camera over the city grid.
class Cam {
  const Cam(this.center, this.scale, this.anchor);

  /// Grid coordinate shown at [anchor].
  final Offset center;

  /// Pixels per grid unit.
  final double scale;

  /// Screen position (px) where [center] is drawn.
  final Offset anchor;

  static Cam lerp(Cam a, Cam b, double t) => Cam(
        Offset.lerp(a.center, b.center, t)!,
        lerpDouble(a.scale, b.scale, t)!,
        Offset.lerp(a.anchor, b.anchor, t)!,
      );

  @override
  bool operator ==(Object other) =>
      other is Cam &&
      other.center == center &&
      other.scale == scale &&
      other.anchor == anchor;

  @override
  int get hashCode => Object.hash(center, scale, anchor);
}

class CamTween extends Tween<Cam> {
  CamTween({super.begin, super.end});

  @override
  Cam lerp(double t) => Cam.lerp(begin!, end!, t);
}

class MapPalette {
  const MapPalette({
    required this.land,
    required this.block,
    required this.building,
    required this.park,
    required this.tree,
    required this.road,
    required this.roadEdge,
    required this.water,
    required this.waterEdge,
    required this.label,
    required this.labelHalo,
    required this.casing,
    required this.traveled,
    required this.badge,
    required this.badgeIcon,
  });

  final Color land,
      block,
      building,
      park,
      tree,
      road,
      roadEdge,
      water,
      waterEdge,
      label,
      labelHalo,
      casing,
      traveled,
      badge,
      badgeIcon;

  static const light = MapPalette(
    land: Color(0xFFEDF1F6),
    block: Color(0xFFE3E9F1),
    building: Color(0xFFDCE3ED),
    park: Color(0xFFCFEBCB),
    tree: Color(0xFFB5DDB0),
    road: Color(0xFFFFFFFF),
    roadEdge: Color(0xFFD3DBE6),
    water: Color(0xFFB8DBF5),
    waterEdge: Color(0xFFA2CAEA),
    label: Color(0xFF475569),
    labelHalo: Color(0xFFF8FAFC),
    casing: Color(0xFFFFFFFF),
    traveled: Color(0xFFB4BCD0),
    badge: Color(0xFFFFFFFF),
    badgeIcon: Color(0xFF4F46E5),
  );

  static const dark = MapPalette(
    land: Color(0xFF0D1322),
    block: Color(0xFF131B30),
    building: Color(0xFF18213A),
    park: Color(0xFF10302A),
    tree: Color(0xFF174238),
    road: Color(0xFF232E4A),
    roadEdge: Color(0xFF182038),
    water: Color(0xFF0F2E52),
    waterEdge: Color(0xFF0B2342),
    label: Color(0xFF94A3B8),
    labelHalo: Color(0xFF0D1322),
    casing: Color(0xFF0D1322),
    traveled: Color(0xFF3B4663),
    badge: Color(0xFF1C2540),
    badgeIcon: Color(0xFFA5B4FC),
  );
}

/// A stylised, animated city map drawn entirely with [CustomPainter].
///
/// No map SDK or API key needed. Swap this widget for `google_maps_flutter`
/// or `flutter_map` when you connect real data.
class CityMap extends StatefulWidget {
  const CityMap({
    super.key,
    required this.cam,
    required this.dark,
    required this.progress,
    required this.route,
    required this.carOnRoute,
    required this.dimTraveled,
    required this.pickup,
    required this.destination,
    required this.pickupLabel,
    required this.destinationLabel,
    required this.showNearby,
    required this.pulse,
  });

  final Cam cam;
  final bool dark;
  final ValueListenable<double> progress;
  final List<Offset> route;
  final bool carOnRoute;
  final bool dimTraveled;
  final Offset pickup;
  final Offset? destination;
  final String? pickupLabel;
  final String? destinationLabel;
  final bool showNearby;
  final bool pulse;

  @override
  State<CityMap> createState() => _CityMapState();
}

class _CityMapState extends State<CityMap> with SingleTickerProviderStateMixin {
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  )..repeat();

  @override
  void dispose() {
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _CityMapPainter(
          cam: widget.cam,
          palette: widget.dark ? MapPalette.dark : MapPalette.light,
          ambient: _ambient,
          progress: widget.progress,
          route: widget.route,
          carOnRoute: widget.carOnRoute,
          dimTraveled: widget.dimTraveled,
          pickup: widget.pickup,
          destination: widget.destination,
          pickupLabel: widget.pickupLabel,
          destinationLabel: widget.destinationLabel,
          showNearby: widget.showNearby,
          pulse: widget.pulse,
        ),
      ),
    );
  }
}

class _NearCar {
  const _NearCar(this.ax, this.ay, this.bx, this.by, this.phase);
  final double ax, ay, bx, by, phase;
}

class _CityMapPainter extends CustomPainter {
  _CityMapPainter({
    required this.cam,
    required this.palette,
    required this.ambient,
    required this.progress,
    required this.route,
    required this.carOnRoute,
    required this.dimTraveled,
    required this.pickup,
    required this.destination,
    required this.pickupLabel,
    required this.destinationLabel,
    required this.showNearby,
    required this.pulse,
  }) : super(repaint: Listenable.merge([ambient, progress]));

  final Cam cam;
  final MapPalette palette;
  final Animation<double> ambient;
  final ValueListenable<double> progress;
  final List<Offset> route;
  final bool carOnRoute;
  final bool dimTraveled;
  final Offset pickup;
  final Offset? destination;
  final String? pickupLabel;
  final String? destinationLabel;
  final bool showNearby;
  final bool pulse;

  static const _routeColor = AppColors.indigo;

  // Offsets are relative to the pickup point; whole numbers sit on roads.
  static const _nearby = <_NearCar>[
    _NearCar(-2, -1, 1, -1, 0.0),
    _NearCar(2, -2, 2, 1, 0.35),
    _NearCar(-1, -3, -1, 0, 0.7),
    _NearCar(0, 2, 3, 2, 1.1),
    _NearCar(-3, 1, 0, 1, 0.9),
    _NearCar(3, -1, 3, 2, 1.5),
  ];

  static const _carColors = <Color>[
    Color(0xFF1E293B),
    Color(0xFFF8FAFC),
    Color(0xFFF59E0B),
    Color(0xFF6366F1),
    Color(0xFF1E293B),
    Color(0xFFF8FAFC),
  ];

  // ------------------------------------------------------------------ caches
  static final Map<String, TextPainter> _textCache = {};

  static TextPainter _text(
    String text,
    double size,
    FontWeight weight,
    Color color, {
    Color? halo,
  }) {
    final key = '$text|$size|${weight.index}|$color|$halo';
    final cached = _textCache[key];
    if (cached != null) return cached;
    if (_textCache.length > 300) _textCache.clear();

    final style = halo == null
        ? TextStyle(fontSize: size, fontWeight: weight, color: color)
        : TextStyle(
            fontSize: size,
            fontWeight: weight,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..strokeJoin = StrokeJoin.round
              ..color = halo,
          );
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    _textCache[key] = tp;
    return tp;
  }

  static TextPainter _iconPainter(IconData icon, double size, Color color) {
    final key = 'icon|${icon.codePoint}|$size|$color';
    final cached = _textCache[key];
    if (cached != null) return cached;
    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    _textCache[key] = tp;
    return tp;
  }

  static int _hash(int i, int j) {
    var h = (i * 73856093) ^ (j * 19349663);
    h = (h ^ (h >> 13)) & 0x7fffffff;
    return h;
  }

  // -------------------------------------------------------------------- paint
  @override
  void paint(Canvas canvas, Size size) {
    final s = cam.scale;
    Offset toPx(Offset g) => cam.anchor + (g - cam.center) * s;
    Offset toGrid(Offset px) => (px - cam.anchor) / s + cam.center;

    final tl = toGrid(Offset.zero);
    final br = toGrid(Offset(size.width, size.height));
    final i0 = tl.dx.floor() - 1;
    final i1 = br.dx.ceil() + 1;
    final j0 = tl.dy.floor() - 1;
    final j1 = br.dy.ceil() + 1;

    canvas.drawRect(Offset.zero & size, Paint()..color = palette.land);

    _paintBlocks(canvas, toPx, s, i0, i1, j0, j1);
    _paintRoads(canvas, toPx, s, size, i0, i1, j0, j1);
    _paintRiver(canvas, toPx, s, j0, j1);
    _paintLandmarks(canvas, toPx, s);
    _paintRoute(canvas, toPx, s);
    if (pulse) _paintPulse(canvas, toPx(pickup));
    if (showNearby) _paintNearbyCars(canvas, toPx, s);
    _paintMarkers(canvas, toPx);
    if (carOnRoute && route.length >= 2) {
      final sample = sampleAlong(route, progress.value);
      _drawCar(canvas, toPx(sample.point), sample.angle, AppColors.ink,
          (s * 0.5).clamp(20.0, 32.0).toDouble(),
          highlight: true);
    }
  }

  void _paintBlocks(Canvas canvas, Offset Function(Offset) toPx, double s,
      int i0, int i1, int j0, int j1) {
    final blockPaint = Paint()..color = palette.block;
    final buildingPaint = Paint()..color = palette.building;
    final parkPaint = Paint()..color = palette.park;
    final treePaint = Paint()..color = palette.tree;

    for (var i = i0; i < i1; i++) {
      for (var j = j0; j < j1; j++) {
        final a = toPx(Offset(i.toDouble(), j.toDouble()));
        final b = toPx(Offset(i + 1.0, j + 1.0));
        final rect = Rect.fromPoints(a, b).deflate(1.2);
        final rr = RRect.fromRectAndRadius(rect, Radius.circular(s * 0.08));
        final h = _hash(i, j);

        if (h % 9 == 0) {
          canvas.drawRRect(rr, parkPaint);
          if (s > 28) {
            for (var k = 0; k < 4; k++) {
              final hx = ((h >> (k * 3)) & 7) / 7.0;
              final hy = ((h >> (k * 3 + 12)) & 7) / 7.0;
              canvas.drawCircle(
                Offset(
                  rect.left + rect.width * (0.2 + 0.6 * hx),
                  rect.top + rect.height * (0.2 + 0.6 * hy),
                ),
                s * 0.07,
                treePaint,
              );
            }
          }
        } else {
          canvas.drawRRect(rr, blockPaint);
          if (s > 26) {
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                rect.deflate(s * 0.14),
                Radius.circular(s * 0.05),
              ),
              buildingPaint,
            );
          }
        }
      }
    }
  }

  void _paintRoads(Canvas canvas, Offset Function(Offset) toPx, double s,
      Size size, int i0, int i1, int j0, int j1) {
    final edge = Paint()
      ..color = palette.roadEdge
      ..style = PaintingStyle.stroke;
    final fill = Paint()
      ..color = palette.road
      ..style = PaintingStyle.stroke;

    double widthFor(int index) => s * (index % 4 == 0 ? 0.24 : 0.14);

    for (var i = i0; i <= i1; i++) {
      final x = toPx(Offset(i.toDouble(), 0)).dx;
      edge.strokeWidth = widthFor(i) + 2.4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), edge);
    }
    for (var j = j0; j <= j1; j++) {
      final y = toPx(Offset(0, j.toDouble())).dy;
      edge.strokeWidth = widthFor(j) + 2.4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), edge);
    }
    for (var i = i0; i <= i1; i++) {
      final x = toPx(Offset(i.toDouble(), 0)).dx;
      fill.strokeWidth = widthFor(i);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), fill);
    }
    for (var j = j0; j <= j1; j++) {
      final y = toPx(Offset(0, j.toDouble())).dy;
      fill.strokeWidth = widthFor(j);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), fill);
    }
  }

  void _paintRiver(
      Canvas canvas, Offset Function(Offset) toPx, double s, int j0, int j1) {
    final path = Path();
    var first = true;
    for (var y = j0 - 1.0; y <= j1 + 1.0; y += 0.5) {
      final x = -1.1 + 0.55 * math.sin(y * 0.6);
      final p = toPx(Offset(x, y));
      if (first) {
        path.moveTo(p.dx, p.dy);
        first = false;
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
        path,
        paint
          ..strokeWidth = s * 1.5 + 5
          ..color = palette.waterEdge);
    canvas.drawPath(
        path,
        paint
          ..strokeWidth = s * 1.5
          ..color = palette.water);

    // Bridges every 4th street.
    for (var j = j0; j <= j1; j++) {
      if (j % 4 != 3) continue;
      final a = toPx(Offset(-2.3, j.toDouble()));
      final b = toPx(Offset(0.2, j.toDouble()));
      canvas.drawLine(
        a,
        b,
        Paint()
          ..strokeWidth = s * 0.16 + 2.4
          ..color = palette.roadEdge,
      );
      canvas.drawLine(
        a,
        b,
        Paint()
          ..strokeWidth = s * 0.16
          ..color = palette.road,
      );
    }
  }

  void _paintLandmarks(Canvas canvas, Offset Function(Offset) toPx, double s) {
    if (s < 30) return;
    final halo = palette.labelHalo;
    for (final place in MockData.places) {
      if (place.grid == destination || place.grid == pickup) continue;
      final c = toPx(place.grid);

      canvas.drawShadow(
        Path()..addOval(Rect.fromCircle(center: c, radius: 13)),
        Colors.black,
        3,
        true,
      );
      canvas.drawCircle(c, 13, Paint()..color = palette.badge);
      final icon = _iconPainter(place.icon, 15, palette.badgeIcon);
      icon.paint(canvas, c - Offset(icon.width / 2, icon.height / 2));

      if (s >= 38) {
        final stroke =
            _text(place.name, 10.5, FontWeight.w700, palette.label, halo: halo);
        final fill = _text(place.name, 10.5, FontWeight.w700, palette.label);
        final o = Offset(c.dx - fill.width / 2, c.dy + 17);
        stroke.paint(canvas, o);
        fill.paint(canvas, o);
      }
    }
  }

  void _paintRoute(Canvas canvas, Offset Function(Offset) toPx, double s) {
    if (route.length < 2) return;
    final width = (s * 0.11).clamp(4.0, 7.5).toDouble();

    Path build(List<Offset> pts) {
      final p = Path();
      final first = toPx(pts.first);
      p.moveTo(first.dx, first.dy);
      for (var k = 1; k < pts.length; k++) {
        final q = toPx(pts[k]);
        p.lineTo(q.dx, q.dy);
      }
      return p;
    }

    final full = build(route);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(
        full,
        paint
          ..strokeWidth = width + 5
          ..color = palette.casing);
    canvas.drawPath(
        full,
        paint
          ..strokeWidth = width
          ..color = _routeColor);

    if (dimTraveled && carOnRoute) {
      final done = partialPath(route, progress.value);
      if (done.length >= 2) {
        canvas.drawPath(
            build(done),
            paint
              ..strokeWidth = width
              ..color = palette.traveled);
      }
    }
  }

  void _paintPulse(Canvas canvas, Offset center) {
    final seconds = ambient.value * 24;
    for (var k = 0; k < 3; k++) {
      final f = ((seconds / 2.4) + k / 3) % 1.0;
      final r = 14 + 90 * f;
      canvas.drawCircle(
        center,
        r,
        Paint()..color = _routeColor.o((1 - f) * 0.22),
      );
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = _routeColor.o((1 - f) * 0.55),
      );
    }
  }

  void _paintNearbyCars(
      Canvas canvas, Offset Function(Offset) toPx, double s) {
    final seconds = ambient.value * 24;
    final len = (s * 0.42).clamp(16.0, 26.0).toDouble();
    for (var n = 0; n < _nearby.length; n++) {
      final car = _nearby[n];
      final a = pickup + Offset(car.ax, car.ay);
      final b = pickup + Offset(car.bx, car.by);
      final x = ((seconds / 7) + car.phase) % 2;
      final forward = x <= 1;
      final u = forward ? x : 2 - x;
      final pos = Offset.lerp(a, b, u)!;
      final dir = forward ? (b - a) : (a - b);
      _drawCar(
        canvas,
        toPx(pos),
        math.atan2(dir.dy, dir.dx),
        _carColors[n % _carColors.length],
        len,
      );
    }
  }

  void _drawCar(Canvas canvas, Offset c, double angle, Color body, double len,
      {bool highlight = false}) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(angle + math.pi / 2);

    final w = len * 0.52;
    final rr = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: w, height: len),
      Radius.circular(w * 0.35),
    );

    if (highlight) {
      canvas.drawCircle(
        Offset.zero,
        len * 0.85,
        Paint()..color = _routeColor.o(0.16),
      );
    }
    canvas.drawShadow(Path()..addRRect(rr), Colors.black, 3, true);
    canvas.drawRRect(rr, Paint()..color = body);

    final windshield = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(0, -len * 0.14),
        width: w * 0.74,
        height: len * 0.24,
      ),
      Radius.circular(w * 0.16),
    );
    canvas.drawRRect(windshield, Paint()..color = Colors.white.o(0.78));

    final rear = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(0, len * 0.27),
        width: w * 0.62,
        height: len * 0.12,
      ),
      Radius.circular(w * 0.1),
    );
    canvas.drawRRect(rear, Paint()..color = Colors.white.o(0.45));
    canvas.restore();
  }

  void _paintMarkers(Canvas canvas, Offset Function(Offset) toPx) {
    // Destination.
    final dest = destination;
    if (dest != null) {
      final c = toPx(dest);
      final outer = RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: 26, height: 26),
        const Radius.circular(9),
      );
      canvas.drawShadow(Path()..addRRect(outer), Colors.black, 5, true);
      canvas.drawRRect(outer, Paint()..color = Colors.white);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: c, width: 12, height: 12),
          const Radius.circular(3.5),
        ),
        Paint()..color = AppColors.ink,
      );
      final label = destinationLabel;
      if (label != null) {
        _bubble(canvas, label, c - const Offset(0, 14), AppColors.ink, Colors.white);
      }
    }

    // Pickup.
    final p = toPx(pickup);
    canvas.drawCircle(p, 15, Paint()..color = AppColors.green.o(0.2));
    canvas.drawShadow(
      Path()..addOval(Rect.fromCircle(center: p, radius: 11)),
      Colors.black,
      4,
      true,
    );
    canvas.drawCircle(p, 11, Paint()..color = Colors.white);
    canvas.drawCircle(p, 6.5, Paint()..color = AppColors.green);

    final label = pickupLabel;
    if (label != null) {
      _bubble(canvas, label, p - const Offset(0, 12), Colors.white, AppColors.ink);
    }
  }

  void _bubble(
      Canvas canvas, String text, Offset anchor, Color fill, Color fg) {
    final tp = _text(text, 12, FontWeight.w800, fg);
    final w = tp.width + 22;
    final h = tp.height + 12;
    final rect = Rect.fromCenter(
      center: anchor + Offset(0, -h / 2 - 7),
      width: w,
      height: h,
    );
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(h / 2));
    final tail = Path()
      ..moveTo(anchor.dx - 6, rect.bottom - 0.5)
      ..lineTo(anchor.dx + 6, rect.bottom - 0.5)
      ..lineTo(anchor.dx, rect.bottom + 6)
      ..close();

    canvas.drawShadow(Path()..addRRect(rr), Colors.black, 5, true);
    canvas.drawRRect(rr, Paint()..color = fill);
    canvas.drawPath(tail, Paint()..color = fill);
    tp.paint(canvas, Offset(rect.center.dx - tp.width / 2, rect.center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _CityMapPainter old) =>
      old.cam != cam ||
      old.palette != palette ||
      old.route != route ||
      old.carOnRoute != carOnRoute ||
      old.dimTraveled != dimTraveled ||
      old.pickup != pickup ||
      old.destination != destination ||
      old.pickupLabel != pickupLabel ||
      old.destinationLabel != destinationLabel ||
      old.showNearby != showNearby ||
      old.pulse != pulse;
}
