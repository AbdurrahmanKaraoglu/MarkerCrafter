 
import 'package:flutter/material.dart';
 
import 'dart:math' as math;

class LocationMarkerPainter extends CustomPainter {
  final double size;
  final Color color;

  LocationMarkerPainter({required this.size, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2;

    final Paint circlePaint = Paint()..color = color;
    canvas.drawCircle(Offset(centerX, centerY), radius, circlePaint);

    const double markerWidth = 5.0;
    final double markerLength = size.width * 0.4;
    final double distanceFromCenter = size.width * 0.3;

    const double angle1 = -45 * (3.141592653589793 / 180); // 45 derece
    const double angle2 = -135 * (3.141592653589793 / 180); // 135 derece

    final double startX1 = centerX + distanceFromCenter * math.cos(angle1);
    final double startY1 = centerY + distanceFromCenter * math.sin(angle1);
    final double endX1 = startX1 + markerLength * math.cos(angle1);
    final double endY1 = startY1 + markerLength * math.sin(angle1);

    final double startX2 = centerX + distanceFromCenter * math.cos(angle2);
    final double startY2 = centerY + distanceFromCenter * math.sin(angle2);
    final double endX2 = startX2 + markerLength * math.cos(angle2);
    final double endY2 = startY2 + markerLength * math.sin(angle2);

    final Paint markerPaint = Paint()
      ..color = color
      ..strokeWidth = markerWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(startX1, startY1), Offset(endX1, endY1), markerPaint);
    canvas.drawLine(Offset(startX2, startY2), Offset(endX2, endY2), markerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

 