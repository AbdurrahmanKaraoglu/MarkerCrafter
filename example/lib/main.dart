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

  final Set<Marker> _markers = <Marker>{};
  double? _pixelRatio;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Markers are drawn at the pixel ratio of the screen showing the map.
    final double pixelRatio = MediaQuery.devicePixelRatioOf(context);
    if (pixelRatio != _pixelRatio) {
      _pixelRatio = pixelRatio;
      _addMarkers(pixelRatio);
    }
  }

  Future<void> _addMarkers(double pixelRatio) async {
    await _markers.addLabelMarker(
      const MarkerCrafter(
        text: 'Galata Kulesi',
        markerId: MarkerId('label'),
        position: LatLng(41.0256, 28.9741),
        infoWindow: InfoWindow(title: 'Label marker'),
      ),
      pixelRatio: pixelRatio,
    );
    await _markers.addRingMarker(
      const MarkerCrafter(
        text: '12',
        markerId: MarkerId('ring'),
        position: LatLng(41.0086, 28.9802),
        backgroundColor: Colors.teal,
        infoWindow: InfoWindow(title: 'Ring marker'),
      ),
      pixelRatio: pixelRatio,
    );
    await _markers.addLocationMarker(
      const MarkerCrafter(
        text: '',
        markerId: MarkerId('location'),
        position: LatLng(41.0115, 28.9834),
        backgroundColor: Colors.red,
        infoWindow: InfoWindow(title: 'Location marker'),
      ),
      pixelRatio: pixelRatio,
    );
    if (mounted) {
      setState(() {});
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
