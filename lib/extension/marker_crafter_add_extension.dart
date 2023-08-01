import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marker_crafter/marker_crafter.dart';

import 'package:marker_crafter/tools/tools.dart';

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
    await createRoundedMarkerIcon(markerCrafter.text, backgroundColor: markerCrafter.backgroundColor, textStyle: markerCrafter.textStyle).then((value) {
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

  Future<bool> addTextMarker2(MarkerCrafter markerCrafter) async {
    bool result = false;

    await createLocationMarkerIcon4(30, markerCrafter.backgroundColor).then((value) {
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

  Future<bool> addEvilEyeBeadMarker(MarkerCrafter markerCrafter) async {
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

  Future<bool> addRoundedMarker(MarkerCrafter markerCrafter) async {
    bool result = false;
    await createRoundedMarkerIcon2(markerCrafter.text, backgroundColor: markerCrafter.backgroundColor, textStyle: markerCrafter.textStyle).then((value) {
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
