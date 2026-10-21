import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Paints a filled circle with two short "antennas" pointing up-left and
/// up-right.
///
/// It is used by [createLocationMarkerBitmap], but it is a regular
/// [CustomPainter], so it can also be used inside a [CustomPaint] widget.
class LocationMarkerPainter extends CustomPainter {
  /// Creates a painter that draws the marker in [color].
  const LocationMarkerPainter({required this.color});

  /// Fill and stroke color of the marker.
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double side = math.min(size.width, size.height);
    final Offset center = size.center(Offset.zero);
    final double radius = side / 2;

    canvas.drawCircle(center, radius, Paint()..color = color);

    final double distanceFromCenter = side * 0.3;
    final double markerLength = side * 0.4;
    final Paint markerPaint = Paint()
      ..color = color
      ..strokeWidth = side / 6
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
