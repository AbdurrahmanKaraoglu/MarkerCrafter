```markdown
# Marker Crafter

[![pub package](https://img.shields.io/pub/v/marker_crafter.svg)](https://pub.dev/packages/marker_crafter)

Marker Crafter, Flutter'da kullanıcı tanımlı metin etiketlerini harita üzerinde göstermek için kullanılan bir Flutter paketidir. Bu paket, Google Maps Flutter paketini kullanarak harita üzerindeki işaretçilere özel metin eklemenizi sağlar.

## Kullanım

1. İlk olarak, `google_maps_flutter` paketini projenize ekleyin. Aşağıdaki gibi `pubspec.yaml` dosyasını düzenleyin:

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_maps_flutter: ^2.0.10
```

2. Daha sonra, `marker_crafter` paketini projenize ekleyin. Aşağıdaki gibi `pubspec.yaml` dosyasını düzenleyin ve paketi projenize ekleyin:

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_maps_flutter: ^2.0.10
  marker_crafter: ^1.0.0
```

3. Koddan bir örnek:

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

Bu örnekte, `MarkerCrafter` sınıfını kullanarak harita üzerinde bir işaretçi ekleniyor. `addTextMarker` işlevi, `MarkerCrafter` örneğini alır ve verilen metne sahip bir işaretçi oluşturur.

---

Bu kadar! Artık Flutter projenizde Marker Crafter paketini kullanabilirsiniz. İşaretçilere metin eklemek için `MarkerCrafter` sınıfını kullanabilirsiniz.

## Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Daha fazla bilgi için [LICENSE](https://github.com/example/repo/blob/main/LICENSE) dosyasını inceleyebilirsiniz.
```

Bu Türkçe README, `marker_c

rafter` paketinin kullanımı hakkında bilgi vermektedir. Örnek bir Flutter uygulamasında nasıl kullanılacağını ve paketin nasıl eklenip kullanılacağını göstermektedir. Örnekte, harita üzerine metin eklemek için `MarkerCrafter` sınıfının nasıl kullanılacağı açıklanmaktadır. Ayrıca, projeyi eklediğinizde hangi bağımlılıklara ihtiyaç duyulduğu belirtilmiştir.

Not: Bu README örneği, README.md dosyanızı oluşturmanız için bir temel sağlamaktadır. Kodunuz ve projeniz hakkındaki özel bilgileri eklemeyi unutmayın.