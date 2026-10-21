import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Describes a marker whose icon is drawn by Marker Crafter.
///
/// It holds the same options as a [Marker], plus the [text], [backgroundColor]
/// and [textStyle] used to draw the icon. Add it to a marker set with the
/// `addLabelMarker`, `addRingMarker` or `addLocationMarker` extension methods.
@immutable
class MarkerCrafter {
  /// Creates a marker description.
  ///
  /// * [text] is drawn on the marker (ignored by the location marker, so it
  ///   can be left out there).
  /// * [markerId] identifies the marker; adding a marker with an id that is
  ///   already in the set replaces the old one.
  /// * [position] is where the marker is placed.
  /// * [textStyle] defaults to a style that suits the chosen marker shape.
  /// * [anchor] defaults to the bottom center for label markers and to the
  ///   center for ring and location markers.
  /// * The remaining parameters are passed to [Marker] unchanged.
  const MarkerCrafter({
    this.text = '',
    required this.markerId,
    required this.position,
    this.backgroundColor = const Color(0xFF448AFF),
    this.textStyle,
    this.alpha = 1.0,
    this.anchor,
    this.consumeTapEvents = false,
    this.draggable = false,
    this.flat = false,
    this.infoWindow = InfoWindow.noText,
    this.rotation = 0.0,
    this.visible = true,
    this.zIndexInt = 0,
    this.clusterManagerId,
    this.onTap,
    this.onDrag,
    this.onDragStart,
    this.onDragEnd,
  }) : assert(0.0 <= alpha && alpha <= 1.0);

  /// The text to be displayed on the marker.
  final String text;

  /// Uniquely identifies a [Marker].
  final MarkerId markerId;

  /// Geographical location of the marker.
  final LatLng position;

  /// Background color of the marker.
  final Color backgroundColor;

  /// Style of [text]. When null, each marker shape uses its own default.
  final TextStyle? textStyle;

  /// The opacity of the marker, between 0.0 and 1.0 inclusive.
  ///
  /// 0.0 means fully transparent, 1.0 means fully opaque.
  final double alpha;

  /// The icon image point that will be placed at the [position] of the marker.
  ///
  /// The image point is specified in normalized coordinates: An anchor of
  /// (0.0, 0.0) means the top left corner of the image. An anchor
  /// of (1.0, 1.0) means the bottom right corner of the image.
  ///
  /// When null, a default that suits the marker shape is used.
  final Offset? anchor;

  /// True if the marker icon consumes tap events. If not, the map will perform
  /// default tap handling by centering the map on the marker and displaying its
  /// info window.
  final bool consumeTapEvents;

  /// True if the marker is draggable by user touch events.
  final bool draggable;

  /// True if the marker is rendered flatly against the surface of the Earth, so
  /// that it will rotate and tilt along with map camera movements.
  final bool flat;

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
  final int zIndexInt;

  /// The cluster manager this marker belongs to, if any. The cluster manager
  /// must be added to the [GoogleMap] as well.
  final ClusterManagerId? clusterManagerId;

  /// Callbacks to receive tap events for markers placed on this map.
  final VoidCallback? onTap;

  /// Signature reporting the new [LatLng] at the start of a drag event.
  final ValueChanged<LatLng>? onDragStart;

  /// Signature reporting the new [LatLng] at the end of a drag event.
  final ValueChanged<LatLng>? onDragEnd;

  /// Signature reporting the new [LatLng] during the drag event.
  final ValueChanged<LatLng>? onDrag;

  /// Builds a [Marker] with these options and the given [icon].
  ///
  /// [defaultAnchor] is used when [anchor] is null.
  Marker toMarker(BitmapDescriptor icon, {Offset defaultAnchor = const Offset(0.5, 1.0)}) {
    return Marker(
      markerId: markerId,
      position: position,
      icon: icon,
      alpha: alpha,
      anchor: anchor ?? defaultAnchor,
      consumeTapEvents: consumeTapEvents,
      draggable: draggable,
      flat: flat,
      infoWindow: infoWindow,
      rotation: rotation,
      visible: visible,
      zIndexInt: zIndexInt,
      clusterManagerId: clusterManagerId,
      onTap: onTap,
      onDragStart: onDragStart,
      onDrag: onDrag,
      onDragEnd: onDragEnd,
    );
  }
}
