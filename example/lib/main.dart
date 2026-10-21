import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marker_crafter/marker_crafter.dart';

void main() {
  runApp(const MarkerCrafterExampleApp());
}

class MarkerCrafterExampleApp extends StatelessWidget {
  const MarkerCrafterExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marker Crafter',
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _istanbul = LatLng(41.0082, 28.9784);

  Set<Marker> _markers = <Marker>{};
  int _generation = 0;
  double? _pixelRatio;
  TextScaler? _textScaler;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Markers follow the pixel ratio and the font size of the screen.
    final double pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final TextScaler textScaler = MediaQuery.textScalerOf(context);
    if (pixelRatio != _pixelRatio || textScaler != _textScaler) {
      _pixelRatio = pixelRatio;
      _textScaler = textScaler;
      _addMarkers(pixelRatio, textScaler);
    }
  }

  Future<void> _addMarkers(double pixelRatio, TextScaler textScaler) async {
    // Draws into a new set and keeps only the newest one, so a slower, older
    // drawing (for example the one made before the screen metrics arrived)
    // never replaces a newer one.
    final int generation = ++_generation;
    final Set<Marker> markers = <Marker>{};
    await markers.addLabelMarker(
      const MarkerCrafter(
        text: 'Galata Kulesi',
        markerId: MarkerId('label'),
        position: LatLng(41.0256, 28.9741),
        infoWindow: InfoWindow(title: 'Label marker'),
      ),
      maxWidth: 160,
      maxLines: 2,
      textScaler: textScaler,
      pixelRatio: pixelRatio,
    );
    await markers.addRingMarker(
      const MarkerCrafter(
        text: '12',
        markerId: MarkerId('ring'),
        position: LatLng(41.0086, 28.9802),
        backgroundColor: Colors.teal,
        infoWindow: InfoWindow(title: 'Ring marker'),
      ),
      textScaler: textScaler,
      pixelRatio: pixelRatio,
    );
    await markers.addLocationMarker(
      const MarkerCrafter(
        markerId: MarkerId('location'),
        position: LatLng(41.0115, 28.9834),
        backgroundColor: Colors.red,
        infoWindow: InfoWindow(title: 'Location marker'),
      ),
      pixelRatio: pixelRatio,
    );
    if (mounted && generation == _generation) {
      setState(() => _markers = markers);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Marker Crafter')),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(target: _istanbul, zoom: 13),
        markers: _markers,
      ),
    );
  }
}
