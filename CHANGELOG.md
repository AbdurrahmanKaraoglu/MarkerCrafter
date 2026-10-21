## 2.1.1

* The location marker (`LocationMarkerPainter`, `createLocationMarkerBitmap`,
  `addLocationMarker`) no longer cuts off the tips of its antennas at the
  image edges. The circle is a little smaller so the whole shape fits, and it
  stays centered.

## 2.1.0

* `MarkerCrafter.clusterManagerId` puts the marker in a marker cluster.
* `addLabelMarker` / `createLabelMarkerBitmap` take `maxWidth` and `maxLines`
  (with "…"), so long text no longer produces an oversized image.
* `textScaler` on label and ring markers, for example
  `MediaQuery.textScalerOf(context)` to follow the system font size. The
  default is still no scaling.
* `MarkerCrafter.text` is optional (defaults to `''`), since location markers
  do not draw it.
* Example app: the web page loads the Maps JavaScript API without
  `document.write` and starts Flutter after it; markers follow the font size.

## 2.0.0

Requires Dart 3 and Flutter 3.10 or newer, and `google_maps_flutter` 2.13 or newer.

### Breaking changes

* Markers are now sized in logical pixels and rendered at the device pixel ratio
  (`BitmapDescriptor.bytes` with `imagePixelRatio`), so they look the same size
  and stay sharp on every screen. Pass `pixelRatio` to override it. Markers look
  larger than in 1.x, where the bitmap was shown at its raw pixel size.
* The default label text style is bold 14 instead of `fontSize: 27` with the
  non-existent `Roboto Bold` family.
* `MarkerCrafter.icon` is removed (it was never used), `zIndex` is replaced by
  `zIndexInt`, `textStyle` and `anchor` are nullable and default per marker
  shape, and the constructor is `const`.
* The `lib/tools/` functions are replaced by `createLabelMarkerBitmap`,
  `createRingMarkerBitmap` and `createLocationMarkerBitmap`, exported from
  `package:marker_crafter/marker_crafter.dart`. The unused
  `createLocationMarkerIcon2` and `createLocationMarkerIcon3` are gone.
* `LocationMarkerPainter` no longer takes a `size` argument.
* Adding a marker whose `MarkerId` is already in the set now replaces it instead
  of leaving two markers with the same id.
* The unused `font_awesome_flutter` dependency is removed.

### New

* `addLabelMarker`, `addRingMarker` and `addLocationMarker` return the added
  `Marker`. The 1.x methods (`addTextMarker`, `addTextMarker2`,
  `addEvilEyeBeadMarker`, `addRoundedMarker`) still work but are deprecated.
* `MarkerCrafter.toMarker(icon)` builds a `Marker` from the options.
* Ring markers scale long text down to fit.

### Fixes

* The label arrow tip is now the bottom edge of the image, so the default
  anchor points exactly at the position (it was 10 px above it).
* Ring markers drew white text on the white inner circle; the default text
  color is now the background color.
* Text width is rounded up instead of truncated, so the last glyph is not cut.
* `Picture`, `Image` and `TextPainter` objects are disposed after rendering.
* `LocationMarkerPainter.shouldRepaint` compares colors and its stroke scales
  with the size.
* Removed generated platform folders from the package root and refreshed the
  example app; its Google Maps key is read from git-ignored files.

## 1.1.3

* Earlier releases.
