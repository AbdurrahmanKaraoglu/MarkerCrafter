# Marker Crafter

[![pub package](https://img.shields.io/pub/v/marker_crafter.svg)](https://pub.dev/packages/marker_crafter)

Marker Crafter, harita üzerinde kullanıcı tanımlı metin etiketlerini işaretçilere eklemek için kullanılan bir Flutter paketidir. Bu paket, Google Maps Flutter paketini kullanarak harita üzerindeki işaretçilere özel metin eklemenizi sağlar.

## Kullanım

1. İlk olarak, projenize `google_maps_flutter` paketini ekleyin. `pubspec.yaml` dosyasını aşağıdaki gibi düzenleyin:

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_maps_flutter: ^2.0.10
```

2. Ardından, projenize `marker_crafter` paketini ekleyin. `pubspec.yaml` dosyasını aşağıdaki gibi düzenleyin ve paketi projenize ekleyin:

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_maps_flutter: ^2.0.10
  marker_crafter: ^1.0.0
```

3. İşte bir örnek kod:

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marker_crafter/marker_crafter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    addMarkers();
  }

  void addMarkers() async {
    MarkerCrafter marker = MarkerCrafter(
      text: "İşaretçi Etiketi",
      markerId: MarkerId("markerIdString"),
      position: LatLng(11.1203, 45.33),
    );

    bool success = await markers.addTextMarker(marker);
    if (success) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Marker Crafter Demo"),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(11.1203, 45.33),
          zoom: 10,
        ),
        markers: markers,
      ),
    );
  }
}
```

Bu örnekte, `MarkerCrafter` sınıfını kullanarak bir işaretçi haritaya eklenmektedir. `addTextMarker` fonksiyonu, bir `MarkerCrafter` örneği alır ve verilen metin ile bir işaretçi oluşturur.

---

Bu kadar! Artık Flutter projenizde Marker Crafter paketini kullanabilirsiniz. İşaretçilere metin eklemek için `MarkerCrafter` sınıfını kullanabilirsiniz.

## Lisans

Bu proje MIT Lisansı altında lisanslanmıştır. Daha fazla bilgi için [LICENSE](https://github.com/example/repo/blob/main/LICENSE) dosyasını inceleyebilirsiniz.


# Marker Crafter

[![pub package](https://img.shields.io/pub/v/marker_crafter.svg)](https://pub.dev/packages/marker_crafter)

Marker Crafter is a Flutter package used to add user-defined text labels to markers on a map. This package allows you to add custom text to markers on a map using the Google Maps Flutter package.

## Usage

1. First, add the `google_maps_flutter` package to your project. Edit the `pubspec.yaml` file as follows:

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_maps_flutter: ^2.0.10
```

2. Next, add the `marker_crafter` package to your project. Edit the `pubspec.yaml` file as follows and add the package to your project:

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_maps_flutter: ^2.0.10
  marker_crafter: ^1.0.0
```

3. Here's an example code:

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marker_crafter/marker_crafter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    addMarkers();
  }

  void addMarkers() async {
    MarkerCrafter marker = MarkerCrafter(
      text: "Marker Label",
      markerId: MarkerId("markerIdString"),
      position: LatLng(11.1203, 45.33),
    );

    bool success = await markers.addTextMarker(marker);
    if (success) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Marker Crafter Demo"),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(11.1203, 45.33),
          zoom: 10,
        ),
        markers: markers,
      ),
    );
  }
}
```

In this example, a marker is added to the map using the `MarkerCrafter` class. The `addTextMarker` function takes a `MarkerCrafter` instance and creates a marker with the given text.

---

That's it! You can now use the Marker Crafter package in your Flutter project. You can use the `MarkerCrafter` class to add text to markers.

## License

This project is licensed under the MIT License. For more information, see the [LICENSE](https://github.com/example/repo/blob/main/LICENSE) file.