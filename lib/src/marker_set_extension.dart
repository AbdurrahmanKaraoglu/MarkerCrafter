import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'marker_bitmaps.dart';
import 'marker_crafter.dart';

const Offset _bottomCenter = Offset(0.5, 1.0);
const Offset _center = Offset(0.5, 0.5);

/// Adds Marker Crafter markers to a set of [Marker]s.
///
/// Each method draws the icon, adds the marker to the set and returns it. A
/// marker already in the set with the same [MarkerId] is replaced. The set is
/// changed after an `await`, so call `setState` (or notify your state
/// management) once the future completes:
///
/// ```dart
/// await markers.addLabelMarker(
///   const MarkerCrafter(text: 'Home', markerId: MarkerId('home'), position: LatLng(41.0, 29.0)),
/// );
/// if (mounted) setState(() {});
/// ```
extension MarkerCrafterSetExtension on Set<Marker> {
  /// Adds a speech bubble marker with [MarkerCrafter.text] in it.
  ///
  /// See [createLabelMarkerBitmap].
  Future<Marker> addLabelMarker(
    MarkerCrafter markerCrafter, {
    double maxWidth = double.infinity,
    int? maxLines,
    TextScaler textScaler = TextScaler.noScaling,
    TextDirection textDirection = TextDirection.ltr,
    double? pixelRatio,
  }) async {
    final BitmapDescriptor icon = await createLabelMarkerBitmap(
      markerCrafter.text,
      textStyle: markerCrafter.textStyle,
      backgroundColor: markerCrafter.backgroundColor,
      maxWidth: maxWidth,
      maxLines: maxLines,
      textScaler: textScaler,
      textDirection: textDirection,
      pixelRatio: pixelRatio,
    );
    return _put(markerCrafter.toMarker(icon, defaultAnchor: _bottomCenter));
  }

  /// Adds a round marker of [radius] with [MarkerCrafter.text] in the middle.
  ///
  /// See [createRingMarkerBitmap].
  Future<Marker> addRingMarker(
    MarkerCrafter markerCrafter, {
    double radius = 20,
    TextScaler textScaler = TextScaler.noScaling,
    TextDirection textDirection = TextDirection.ltr,
    double? pixelRatio,
  }) async {
    final BitmapDescriptor icon = await createRingMarkerBitmap(
      markerCrafter.text,
      radius: radius,
      textStyle: markerCrafter.textStyle,
      backgroundColor: markerCrafter.backgroundColor,
      textScaler: textScaler,
      textDirection: textDirection,
      pixelRatio: pixelRatio,
    );
    return _put(markerCrafter.toMarker(icon, defaultAnchor: _center));
  }

  /// Adds a [size] × [size] location marker in [MarkerCrafter.backgroundColor].
  /// [MarkerCrafter.text] is not drawn.
  ///
  /// See [createLocationMarkerBitmap].
  Future<Marker> addLocationMarker(MarkerCrafter markerCrafter, {double size = 30, double? pixelRatio}) async {
    final BitmapDescriptor icon = await createLocationMarkerBitmap(
      markerCrafter.backgroundColor,
      size: size,
      pixelRatio: pixelRatio,
    );
    return _put(markerCrafter.toMarker(icon, defaultAnchor: _center));
  }

  /// Use [addLabelMarker] instead.
  @Deprecated('Use addLabelMarker instead. This will be removed in 3.0.0.')
  Future<bool> addTextMarker(MarkerCrafter markerCrafter) async {
    await addLabelMarker(markerCrafter);
    return true;
  }

  /// Use [addLocationMarker] instead.
  @Deprecated('Use addLocationMarker instead. This will be removed in 3.0.0.')
  Future<bool> addTextMarker2(MarkerCrafter markerCrafter) async {
    await addLocationMarker(markerCrafter);
    return true;
  }

  /// Use [addRingMarker] instead.
  @Deprecated('Use addRingMarker(radius: 20) instead. This will be removed in 3.0.0.')
  Future<bool> addEvilEyeBeadMarker(MarkerCrafter markerCrafter) async {
    await addRingMarker(markerCrafter, radius: 20);
    return true;
  }

  /// Use [addRingMarker] instead.
  @Deprecated('Use addRingMarker(radius: 15) instead. This will be removed in 3.0.0.')
  Future<bool> addRoundedMarker(MarkerCrafter markerCrafter) async {
    await addRingMarker(markerCrafter, radius: 15);
    return true;
  }

  Marker _put(Marker marker) {
    removeWhere((Marker existing) => existing.markerId == marker.markerId);
    add(marker);
    return marker;
  }
}
