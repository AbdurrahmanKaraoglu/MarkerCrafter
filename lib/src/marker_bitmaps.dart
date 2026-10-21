import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'location_marker_painter.dart';

/// Default background color of [createRingMarkerBitmap].
const Color defaultRingColor = Color(0xFF3644FF);

const double _labelHorizontalPadding = 16;
const double _labelVerticalPadding = 8;
const double _labelCornerRadius = 8;
const double _labelArrowWidth = 20;
const double _labelArrowHeight = 10;

/// Draws a rounded "speech bubble" with [text] inside and an arrow pointing
/// down, and returns it as a [BitmapDescriptor].
///
/// The tip of the arrow is the bottom center of the image, so use an anchor of
/// `Offset(0.5, 1.0)` (the [Marker] default) to put the tip on the position.
///
/// All sizes are logical pixels. The image is rendered at [pixelRatio]
/// (defaults to the device pixel ratio) so it stays sharp on high density
/// screens and shows up on the map at its logical size.
///
/// The text wraps at [maxWidth] logical pixels (the bubble is 32 pixels wider
/// for its padding). With [maxLines], text that does not fit ends with "…".
/// Without limits a very long text gives a very large image, so set them for
/// user provided text.
///
/// [textScaler] scales the text, for example with
/// `MediaQuery.textScalerOf(context)` to follow the system font size.
Future<BitmapDescriptor> createLabelMarkerBitmap(
  String text, {
  TextStyle? textStyle,
  Color backgroundColor = Colors.blueAccent,
  double maxWidth = double.infinity,
  int? maxLines,
  TextScaler textScaler = TextScaler.noScaling,
  double? pixelRatio,
}) {
  assert(maxWidth > 0, 'maxWidth must be positive');
  assert(maxLines == null || maxLines > 0, 'maxLines must be positive');
  final TextPainter textPainter = _layoutText(
    text,
    textStyle ?? const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
    textScaler: textScaler,
    maxWidth: maxWidth,
    maxLines: maxLines,
  );
  final double bubbleWidth = math.max(textPainter.width + _labelHorizontalPadding * 2, _labelArrowWidth + _labelCornerRadius * 2);
  final double bubbleHeight = textPainter.height + _labelVerticalPadding * 2;
  final Size size = Size(bubbleWidth, bubbleHeight + _labelArrowHeight);

  return _render(size, pixelRatio, (Canvas canvas) {
    final Paint paint = Paint()..color = backgroundColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, bubbleWidth, bubbleHeight), const Radius.circular(_labelCornerRadius)),
      paint,
    );
    final double centerX = bubbleWidth / 2;
    canvas.drawPath(
      Path()
        // Starts slightly inside the bubble so no seam shows between the shapes.
        ..moveTo(centerX - _labelArrowWidth / 2, bubbleHeight - 1)
        ..lineTo(centerX, size.height)
        ..lineTo(centerX + _labelArrowWidth / 2, bubbleHeight - 1)
        ..close(),
      paint,
    );
    textPainter.paint(
      canvas,
      Offset((bubbleWidth - textPainter.width) / 2, _labelVerticalPadding),
    );
  }).whenComplete(textPainter.dispose);
}

/// Draws a filled circle of [radius] with a white inner circle and [text] in
/// the middle, and returns it as a [BitmapDescriptor].
///
/// The text is scaled down when it does not fit in the inner circle. Without a
/// [textStyle], the text is bold and drawn in [backgroundColor]. [textScaler]
/// works as in [createLabelMarkerBitmap], within the inner circle.
///
/// The marker is round, so an anchor of `Offset(0.5, 0.5)` centers it on the
/// position. See [createLabelMarkerBitmap] for [pixelRatio].
Future<BitmapDescriptor> createRingMarkerBitmap(
  String text, {
  double radius = 20,
  TextStyle? textStyle,
  Color backgroundColor = defaultRingColor,
  TextScaler textScaler = TextScaler.noScaling,
  double? pixelRatio,
}) {
  assert(radius > 0, 'radius must be positive');
  final double innerRadius = radius * 0.6;
  final TextPainter textPainter = _layoutText(
    text,
    textStyle ?? TextStyle(fontSize: radius * 0.6, color: backgroundColor, fontWeight: FontWeight.bold),
    textScaler: textScaler,
  );

  return _render(Size.square(radius * 2), pixelRatio, (Canvas canvas) {
    final Offset center = Offset(radius, radius);
    canvas.drawCircle(center, radius, Paint()..color = backgroundColor);
    canvas.drawCircle(center, innerRadius, Paint()..color = Colors.white);

    if (textPainter.width == 0 || textPainter.height == 0) {
      return;
    }
    // Fit the text box in the square inscribed in the inner circle.
    final double available = innerRadius * math.sqrt2;
    final double scale = math.min(1, available / math.max(textPainter.width, textPainter.height));
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..scale(scale);
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    canvas.restore();
  }).whenComplete(textPainter.dispose);
}

/// Draws a [LocationMarkerPainter] of [size] × [size] logical pixels in
/// [color] and returns it as a [BitmapDescriptor].
///
/// See [createLabelMarkerBitmap] for [pixelRatio].
Future<BitmapDescriptor> createLocationMarkerBitmap(
  Color color, {
  double size = 30,
  double? pixelRatio,
}) {
  assert(size > 0, 'size must be positive');
  final Size canvasSize = Size.square(size);
  return _render(canvasSize, pixelRatio, (Canvas canvas) {
    LocationMarkerPainter(color: color).paint(canvas, canvasSize);
  });
}

/// The pixel ratio used when none is passed: the one of the app's main view,
/// or 1.0 when there is none (for example in a background isolate).
///
/// Right after start-up, before the platform has reported the screen metrics,
/// the main view reports 1.0. The marker functions wait for the metrics in that
/// case (see [waitForPixelRatio]); this synchronous getter does not.
double resolvePixelRatio([double? pixelRatio]) {
  final double ratio = pixelRatio ?? _platformDispatcher.implicitView?.devicePixelRatio ?? 1.0;
  assert(ratio > 0, 'pixelRatio must be positive');
  return ratio;
}

/// Like [resolvePixelRatio], but when no [pixelRatio] is passed and the main
/// view has no size yet (its metrics have not arrived, as in `initState` of the
/// first screen), waits up to [timeout] for the metrics first.
Future<double> waitForPixelRatio([double? pixelRatio, Duration timeout = const Duration(seconds: 2)]) async {
  if (pixelRatio != null) {
    return resolvePixelRatio(pixelRatio);
  }
  final ui.FlutterView? view = _platformDispatcher.implicitView;
  if (view != null && view.physicalSize.isEmpty && _hasWidgetsBinding) {
    final _MetricsObserver observer = _MetricsObserver(view);
    WidgetsBinding.instance.addObserver(observer);
    try {
      await observer.ready.timeout(timeout, onTimeout: () {});
    } finally {
      WidgetsBinding.instance.removeObserver(observer);
    }
  }
  return resolvePixelRatio();
}

/// Whether a [WidgetsBinding] exists. It does not, for example, in a background
/// isolate, and accessing [WidgetsBinding.instance] then throws.
bool get _hasWidgetsBinding {
  try {
    WidgetsBinding.instance;
    return true;
  } catch (_) {
    return false;
  }
}

/// The binding's dispatcher (the test one in widget tests), or the global one.
ui.PlatformDispatcher get _platformDispatcher =>
    _hasWidgetsBinding ? WidgetsBinding.instance.platformDispatcher : ui.PlatformDispatcher.instance;

class _MetricsObserver with WidgetsBindingObserver {
  _MetricsObserver(this.view);

  final ui.FlutterView view;
  final Completer<void> _ready = Completer<void>();

  Future<void> get ready => _ready.future;

  @override
  void didChangeMetrics() {
    if (!view.physicalSize.isEmpty && !_ready.isCompleted) {
      _ready.complete();
    }
  }
}

TextPainter _layoutText(
  String text,
  TextStyle style, {
  TextScaler textScaler = TextScaler.noScaling,
  double maxWidth = double.infinity,
  int? maxLines,
}) {
  return TextPainter(
    text: TextSpan(text: text, style: style),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
    textScaler: textScaler,
    textWidthBasis: TextWidthBasis.longestLine,
    maxLines: maxLines,
    ellipsis: maxLines == null ? null : '…',
  )..layout(maxWidth: maxWidth);
}

/// Records [draw] on a canvas of [logicalSize], rasterizes it at the pixel
/// ratio and wraps the PNG in a [BitmapDescriptor].
Future<BitmapDescriptor> _render(Size logicalSize, double? pixelRatio, void Function(Canvas canvas) draw) async {
  final double ratio = await waitForPixelRatio(pixelRatio);
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder)..scale(ratio);
  draw(canvas);
  final ui.Picture picture = recorder.endRecording();

  final ui.Image image;
  try {
    image = await picture.toImage(
      math.max(1, (logicalSize.width * ratio).ceil()),
      math.max(1, (logicalSize.height * ratio).ceil()),
    );
  } finally {
    picture.dispose();
  }

  try {
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Could not encode the marker image as PNG.');
    }
    return BitmapDescriptor.bytes(byteData.buffer.asUint8List(), imagePixelRatio: ratio);
  } finally {
    image.dispose();
  }
}
