# Marker Crafter

[![pub package](https://img.shields.io/pub/v/marker_crafter.svg)](https://pub.dev/packages/marker_crafter)

Draws custom [Google Maps](https://pub.dev/packages/google_maps_flutter) markers
with `Canvas` and turns them into `BitmapDescriptor`s:

| Shape | Method | Default anchor |
| --- | --- | --- |
| Speech bubble with text and an arrow | `addLabelMarker` / `createLabelMarkerBitmap` | bottom center (arrow tip) |
| Colored ring with text in the middle | `addRingMarker` / `createRingMarkerBitmap` | center |
| Circle with two "antennas" | `addLocationMarker` / `createLocationMarkerBitmap` | center |

Sizes are logical pixels. Markers are rendered at the device pixel ratio, so
they are sharp and the same size on every screen.

Türkçe açıklama için [aşağıya](#türkçe) bakın.

## Installation

```yaml
dependencies:
  google_maps_flutter: ^2.13.0
  marker_crafter: ^2.1.0
```

Set up a Google Maps API key as described in the
[google_maps_flutter README](https://pub.dev/packages/google_maps_flutter).

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marker_crafter/marker_crafter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Set<Marker> _markers = <Marker>{};

  @override
  void initState() {
    super.initState();
    _addMarkers();
  }

  Future<void> _addMarkers() async {
    await _markers.addLabelMarker(
      const MarkerCrafter(
        text: 'Galata Kulesi',
        markerId: MarkerId('label'),
        position: LatLng(41.0256, 28.9741),
      ),
    );
    await _markers.addRingMarker(
      const MarkerCrafter(
        text: '12',
        markerId: MarkerId('ring'),
        position: LatLng(41.0086, 28.9802),
        backgroundColor: Colors.teal,
      ),
      radius: 20,
    );
    // The set changes after an await: rebuild once the markers are added.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(target: LatLng(41.0082, 28.9784), zoom: 13),
      markers: _markers,
    );
  }
}
```

* Adding a marker with a `MarkerId` that is already in the set replaces it.
* Every `MarkerCrafter` option except `text`, `backgroundColor` and `textStyle`
  is passed to `Marker` unchanged (`infoWindow`, `onTap`, `draggable`, ...).
* The pixel ratio defaults to the main view's. Calling the methods in
  `initState` is fine: they wait until the screen metrics are known. Pass
  `pixelRatio:` to draw for a specific screen; note that
  `MediaQuery.devicePixelRatioOf(context)` can be 1.0 during the very first
  build, so redraw when it changes (as the example app does).
* Pass `textScaler: MediaQuery.textScalerOf(context)` to follow the system
  font size, and `maxWidth:` / `maxLines:` to `addLabelMarker` to keep long
  text in bounds (it ends with "…").
* `MarkerCrafter.clusterManagerId` adds the marker to a marker cluster.
* To build the `Marker` yourself, call `createLabelMarkerBitmap(...)` and
  `MarkerCrafter.toMarker(icon)`.

See the [example app](example/) for a runnable demo.

## Migrating from 1.x

| 1.x | 2.0 |
| --- | --- |
| `import 'package:marker_crafter/extension/marker_crafter_add_extension.dart'` | `import 'package:marker_crafter/marker_crafter.dart'` |
| `addTextMarker` | `addLabelMarker` |
| `addTextMarker2` | `addLocationMarker` |
| `addEvilEyeBeadMarker` | `addRingMarker(radius: 20)` |
| `addRoundedMarker` | `addRingMarker(radius: 15)` |
| `zIndex: 1.0` | `zIndexInt: 1` |
| `icon:` | removed (the icon is always drawn) |

The old methods still work but are deprecated. Markers are now sized in logical
pixels, so they look larger than in 1.x; see the [changelog](CHANGELOG.md).

## Türkçe

Marker Crafter, Google Maps işaretçilerini `Canvas` ile çizip
`BitmapDescriptor`'a çeviren bir Flutter paketidir: metinli konuşma balonu
(`addLabelMarker`), ortasında metin olan halka (`addRingMarker`) ve konum
işaretçisi (`addLocationMarker`).

* Boyutlar mantıksal pikseldir; işaretçiler cihazın piksel oranında çizilir,
  bu yüzden her ekranda net ve aynı boyutta görünür.
* Aynı `MarkerId` ile eklenen işaretçi eskisinin yerine geçer.
* Uzun metin için `addLabelMarker`'a `maxWidth` ve `maxLines`, sistem yazı
  boyutu için `textScaler: MediaQuery.textScalerOf(context)` verin.
* Metot `await` ile tamamlandıktan sonra `setState` çağırın.
* 1.x'ten geçiş için yukarıdaki tabloya bakın.

## License

MIT. See [LICENSE](LICENSE).
