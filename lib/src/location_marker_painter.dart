import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Paints a filled circle with two short "antennas" pointing up-left and
/// up-right, sized so the whole shape fits in the canvas with the circle
/// centered.
///
/// It is used by [createLocationMarkerBitmap], but it is a regular
/// [CustomPainter], so it can also be used inside a [CustomPaint] widget.
class LocationMarkerPainter extends CustomPainter {
  /// Creates a painter that draws the marker in [color].
  const LocationMarkerPainter({required this.color});

  /// Fill and stroke color of the marker.
  final Color color;

  // Antenna geometry relative to the circle radius.
  static const double _antennaStart = 0.6;
  static const double _antennaEnd = 1.4;
  static const double _strokeWidth = 1 / 3;

  // How far the antenna tips (with their round caps) reach from the center,
  // horizontally and upwards, in circle radii.
  static final double _reach = _antennaEnd * math.sqrt1_2 + _strokeWidth / 2;

  // Leaves a little room so anti-aliasing does not touch the edges.
  static const double _margin = 0.95;

  @override
  void paint(Canvas canvas, Size size) {
    final double side = math.min(size.width, size.height);
    final Offset center = size.center(Offset.zero);
    // The circle is centered, so the antennas need [_reach] radii on each side.
    final double radius = side / 2 / _reach * _margin;

    canvas.drawCircle(center, radius, Paint()..color = color);

    final double distanceFromCenter = radius * _antennaStart;
    final double markerLength = radius * (_antennaEnd - _antennaStart);
    final Paint markerPaint = Paint()
      ..color = color
      ..strokeWidth = radius * _strokeWidth
      ..strokeCap = StrokeCap.round;

    for (final double degrees in const <double>[-45, -135]) {
      final double angle = degrees * math.pi / 180;
      final Offset direction = Offset(math.cos(angle), math.sin(angle));
      final Offset start = center + direction * distanceFromCenter;
      final Offset end = start + direction * markerLength;
      canvas.drawLine(start, end, markerPaint);
    }
  }

  @override
  bool shouldRepaint(LocationMarkerPainter oldDelegate) => oldDelegate.color != color;
}
