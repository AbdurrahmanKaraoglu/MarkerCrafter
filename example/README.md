# marker_crafter_example

Shows what `marker_crafter` can do:

- **Map:** label, ring and location markers on a Google Map, with a card
  carousel that moves the camera to each place.
- **Studio:** edit a marker (shape, text, color, size, lines, font scaling),
  see the generated bitmap at its real size with its anchor, and copy the
  code. Studio works without an API key.

The app needs a Google Maps API key. Keys are never committed; put yours in
one of these git-ignored places before running:

- **Android:** `MAPS_API_KEY=<key>` in `android/local.properties`
  (or a `MAPS_API_KEY` environment variable).
- **iOS:** `MAPS_API_KEY = <key>` in `ios/Flutter/MapsApiKey.xcconfig`.
- **Web:** `window.MAPS_API_KEY = '<key>';` in `web/maps_api_key.js`.

Then run `flutter run`.
