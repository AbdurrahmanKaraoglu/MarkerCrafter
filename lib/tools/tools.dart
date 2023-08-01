import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
 
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:marker_crafter/tools/location_marker_painter.dart';


Future<BitmapDescriptor> createLocationMarkerBitmap(String title, {required TextStyle textStyle, Color backgroundColor = const Color(0XFF3644ff)}) async {
  double outerRadius = 20.0;
  double innerRadius = 10.0;

  ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  Canvas canvas = Canvas(pictureRecorder);

  Paint outerCirclePaint = Paint()..color = backgroundColor;
  canvas.drawCircle(Offset(outerRadius, outerRadius), outerRadius, outerCirclePaint);

  Paint innerCirclePaint = Paint()..color = Colors.white;
  canvas.drawCircle(Offset(outerRadius, outerRadius), innerRadius, innerCirclePaint);

  TextSpan span = TextSpan(
    style: textStyle,
    text: title,
  );
  TextPainter textPainter = TextPainter(
    text: span,
    textAlign: TextAlign.center,
    textDirection: ui.TextDirection.ltr,
  );
  textPainter.layout();
  textPainter.paint(canvas, Offset(outerRadius - textPainter.width / 2, outerRadius - textPainter.height / 2));

  ui.Picture picture = pictureRecorder.endRecording();
  ui.Image image = await picture.toImage((outerRadius * 2).toInt(), (outerRadius * 2).toInt());
  ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  Uint8List imageData = byteData!.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(imageData);
}

Future<BitmapDescriptor> createRoundedMarkerIcon(String title, {required TextStyle textStyle, Color backgroundColor = Colors.blueAccent}) async {
  TextSpan span = TextSpan(
    style: textStyle,
    text: title,
  );
  TextPainter painter = TextPainter(
    text: span,
    textAlign: TextAlign.center,
    textDirection: ui.TextDirection.ltr,
  );
  painter.text = TextSpan(
    text: title.toString(),
    style: textStyle,
  );
  painter.layout();

  int textWidth = painter.width.toInt();
  int textHeight = painter.height.toInt();

  ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  Canvas canvas = Canvas(pictureRecorder);

  RRect roundedRect = RRect.fromLTRBAndCorners(
    0,
    0,
    textWidth + 40,
    textHeight + 20,
    bottomLeft: const Radius.circular(10),
    bottomRight: const Radius.circular(10),
    topLeft: const Radius.circular(10),
    topRight: const Radius.circular(10),
  );

  Paint rectPaint = Paint()..color = backgroundColor;
  canvas.drawRRect(roundedRect, rectPaint);

  Path arrowPath = Path();
  arrowPath.moveTo((textWidth + 40) / 2 - 15, textHeight + 20);
  arrowPath.lineTo((textWidth + 40) / 2, textHeight + 40);
  arrowPath.lineTo((textWidth + 40) / 2 + 15, textHeight + 20);
  arrowPath.close();

  Paint arrowPaint = Paint()..color = backgroundColor;
  canvas.drawPath(arrowPath, arrowPaint);

  painter.paint(canvas, const Offset(20.0, 10.0));

  ui.Picture p = pictureRecorder.endRecording();
  ByteData? pngBytes = await (await p.toImage((textWidth + 40), (textHeight + 50))).toByteData(format: ui.ImageByteFormat.png);
  Uint8List data = Uint8List.view(pngBytes!.buffer);

  return BitmapDescriptor.fromBytes(data);
}

 

Future<BitmapDescriptor> createLocationMarkerIcon4(double size, Color color) async {
  final PictureRecorder pictureRecorder = PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);

  final LocationMarkerPainter painter = LocationMarkerPainter(size: size, color: color);
  painter.paint(canvas, Size(size, size));

  final ui.Picture picture = pictureRecorder.endRecording();
  final ui.Image image = await picture.toImage(size.toInt(), size.toInt());
  final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List data = byteData!.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(data);
}


Future<BitmapDescriptor> createLocationMarkerIcon2(double size, Color color) async {
  final PictureRecorder pictureRecorder = PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);

  final double centerX = size / 2;
  final double centerY = size / 2;
  final double radius = size / 2;

  final Paint circlePaint = Paint()..color = color;
  canvas.drawCircle(Offset(centerX, centerY), radius, circlePaint);

  final Paint innerCirclePaint = Paint()..color = Colors.white;
  canvas.drawCircle(Offset(centerX, centerY), radius - 4, innerCirclePaint);

  final Paint markerPaint = Paint()..color = color;
  canvas.drawRect(Rect.fromLTWH(centerX - 2, centerY + 8, 4, size - 8), markerPaint);

  final ui.Picture picture = pictureRecorder.endRecording();
  final ui.Image image = await picture.toImage(size.toInt(), size.toInt());
  final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List data = byteData!.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(data);
}

Future<BitmapDescriptor> createLocationMarkerIcon3(double size, Color color) async {
  final PictureRecorder pictureRecorder = PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);

  final double centerX = size / 2;
  final double centerY = size / 2;
  final double radius = size / 2;
  final double distanceFromCenter = size * 0.3;
  const double markerWidth = 5.0;
  final double markerLength = size * 0.4;

  final Paint circlePaint = Paint()..color = color;
  canvas.drawCircle(Offset(centerX, centerY), radius, circlePaint);

  const double angle1 = math.pi / 4; // 45 derece
  const double angle2 = 3 * math.pi / 4; // 135 derece

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

  final ui.Picture picture = pictureRecorder.endRecording();
  final ui.Image image = await picture.toImage(size.toInt(), size.toInt());
  final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List data = byteData!.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(data);
}

Future<BitmapDescriptor> createRoundedMarkerIcon2(String title, {required TextStyle textStyle, Color backgroundColor = const Color(0XFF3644ff)}) async {
  double outerRadius = 15.0;
  double innerRadius = 7.5;

  ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  Canvas canvas = Canvas(pictureRecorder);

  Paint outerCirclePaint = Paint()..color = backgroundColor;
  canvas.drawCircle(Offset(outerRadius, outerRadius), outerRadius, outerCirclePaint);

  Paint innerCirclePaint = Paint()..color = Colors.white;
  canvas.drawCircle(Offset(outerRadius, outerRadius), innerRadius, innerCirclePaint);

  TextSpan span = TextSpan(
    style: textStyle,
    text: title,
  );
  TextPainter textPainter = TextPainter(
    text: span,
    textAlign: TextAlign.center,
    textDirection: ui.TextDirection.ltr,
  );
  textPainter.layout();
  textPainter.paint(canvas, Offset(outerRadius - textPainter.width / 2, outerRadius - textPainter.height / 2));

  ui.Picture picture = pictureRecorder.endRecording();
  ui.Image image = await picture.toImage((outerRadius * 2).toInt(), (outerRadius * 2).toInt());
  ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  Uint8List imageData = byteData!.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(imageData);
}