library marker_crafter;

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;

extension MarkerCrafterAddExtension on Set<Marker> {
  /// Add a MarkerCrafter to existing set of Markers
  ///
  /// * Pass the [MarkerCrafter] object to add to the set
  /// * !!! IMPORTANT!!!
  /// *   Call setstate after calling this function, as shown in the example
  ///
  /// Example
  ///
  ///       markers.addTextMarker(MarkerCrafter(
  ///         label: "makerLabel",
  ///         markerId: MarkerId("markerIdString"),
  ///         position: LatLng(11.1203, 45.33),),
  ///       ).then((_) {
  ///          setState(() {});
  ///      });
  Future<bool> addTextMarker(MarkerCrafter markerCrafter) async {
    bool result = false;
    await createLocationMarkerBitmap(markerCrafter.text, backgroundColor: markerCrafter.backgroundColor, textStyle: markerCrafter.textStyle).then((value) {
      add(Marker(
          markerId: markerCrafter.markerId,
          position: markerCrafter.position,
          icon: value,
          alpha: markerCrafter.alpha,
          anchor: markerCrafter.anchor,
          consumeTapEvents: markerCrafter.consumeTapEvents,
          draggable: markerCrafter.draggable,
          flat: markerCrafter.flat,
          infoWindow: markerCrafter.infoWindow,
          rotation: markerCrafter.rotation,
          visible: markerCrafter.visible,
          zIndex: markerCrafter.zIndex,
          onTap: markerCrafter.onTap,
          onDragStart: markerCrafter.onDragStart,
          onDrag: markerCrafter.onDrag,
          onDragEnd: markerCrafter.onDragEnd));
      result = true;
    });
    return (result);
  }
}

Future<BitmapDescriptor> createLocationMarkerBitmap(String text, {required TextStyle textStyle, Color backgroundColor = Colors.blueAccent}) async {
  TextSpan span = TextSpan(
    style: textStyle,
    text: text,
  );
  TextPainter painter = TextPainter(
    text: span,
    textAlign: TextAlign.center,
    textDirection: ui.TextDirection.ltr,
  );
  painter.text = TextSpan(
    text: text.toString(),
    style: textStyle,
  );
  ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  Canvas canvas = Canvas(pictureRecorder);
  painter.layout();

  int textWidth = painter.width.toInt();
  int textHeight = painter.height.toInt();

  double circleRadius = textWidth * 0.6;
  double circleDiameter = circleRadius * 2;
  double labelHeight = textHeight + 10;
  double markerHeight = circleDiameter + labelHeight;

  canvas.drawCircle(
    Offset(circleRadius, circleRadius),
    circleRadius,
    Paint()..color = backgroundColor,
  );

  canvas.drawRRect(
    RRect.fromLTRBAndCorners(
      0,
      circleDiameter,
      textWidth + 20,
      markerHeight,
      topLeft: const Radius.circular(10),
      topRight: const Radius.circular(10),
      bottomLeft: const Radius.circular(10),
      bottomRight: const Radius.circular(10),
    ),
    Paint()..color = backgroundColor,
  );

  painter.paint(canvas, Offset(10, circleDiameter + 5));

  ui.Picture p = pictureRecorder.endRecording();
  ByteData? pngBytes = await (await p.toImage(textWidth.toInt() + 20, markerHeight.toInt())).toByteData(format: ui.ImageByteFormat.png);
  Uint8List data = Uint8List.view(pngBytes!.buffer);

  return BitmapDescriptor.fromBytes(data);
}

class MarkerCrafter {
  /// The text to be displayed on the marker
  final String text;

  /// Uniquely identifies a [Marker].
  final MarkerId markerId;

  /// Geographical location of the marker.
  final LatLng position;

  /// Background color of the label marker.
  final Color backgroundColor;

  /// TextStyle for the text to be displayed in the label marker.
  final TextStyle textStyle;

  /// The opacity of the marker, between 0.0 and 1.0 inclusive.
  ///
  /// 0.0 means fully transparent, 1.0 means fully opaque.
  final double alpha;

  /// The icon image point that will be placed at the [position] of the marker.
  ///
  /// The image point is specified in normalized coordinates: An anchor of
  /// (0.0, 0.0) means the top left corner of the image. An anchor
  /// of (1.0, 1.0) means the bottom right corner of the image.
  final Offset anchor;

  /// True if the marker icon consumes tap events. If not, the map will perform
  /// default tap handling by centering the map on the marker and displaying its
  /// info window.
  final bool consumeTapEvents;

  /// True if the marker is draggable by user touch events.
  final bool draggable;

  /// True if the marker is rendered flatly against the surface of the Earth, so
  /// that it will rotate and tilt along with map camera movements.
  final bool flat;

  /// A description of the bitmap used to draw the marker icon.
  final BitmapDescriptor icon;

  /// A Google Maps InfoWindow.
  ///
  /// The window is displayed when the marker is tapped.
  final InfoWindow infoWindow;

  /// Rotation of the marker image in degrees clockwise from the [anchor] point.
  final double rotation;

  /// True if the marker is visible.
  final bool visible;

  /// The z-index of the marker, used to determine relative drawing order of
  /// map overlays.
  ///
  /// Overlays are drawn in order of z-index, so that lower values means drawn
  /// earlier, and thus appearing to be closer to the surface of the Earth.
  final double zIndex;

  /// Callbacks to receive tap events for markers placed on this map.
  final VoidCallback? onTap;

  /// Signature reporting the new [LatLng] at the start of a drag event.
  final ValueChanged<LatLng>? onDragStart;

  /// Signature reporting the new [LatLng] at the end of a drag event.
  final ValueChanged<LatLng>? onDragEnd;

  /// Signature reporting the new [LatLng] during the drag event.
  final ValueChanged<LatLng>? onDrag;

  /// Creates a marker with text label
  ///
  /// * Pass the [text] to be displayed on the marker
  /// * Pass the [markerId] to be used as a key for the marker
  /// * Pass the [position] to be used as the marker's position
  /// * Optionally pass the [backgroundColor] to be used as the marker's background color
  /// * Optionally pass the [textStyle] to be used as the marker's text style
  /// * Optionally you could pass all the other parameters passed for a normal marker
  ///
  MarkerCrafter({
    required this.text,
    required this.markerId,
    required this.position,
    this.backgroundColor = Colors.blueAccent,
    this.textStyle = const TextStyle(fontSize: 27.0, color: Colors.white, letterSpacing: 1.0, fontFamily: 'Roboto Bold'),
    this.alpha = 1.0,
    this.anchor = const Offset(0.5, 1.0),
    this.consumeTapEvents = false,
    this.draggable = false,
    this.flat = false,
    this.icon = BitmapDescriptor.defaultMarker,
    this.infoWindow = InfoWindow.noText,
    this.rotation = 0.0,
    this.visible = true,
    this.zIndex = 0.0,
    this.onTap,
    this.onDrag,
    this.onDragStart,
    this.onDragEnd,
  });
}