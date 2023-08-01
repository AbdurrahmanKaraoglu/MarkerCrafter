import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marker_crafter/marker_crafter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
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
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    addMarkers();
  }

  void addMarkers() async {
    MarkerCrafter marker = MarkerCrafter(
      text: "İşaretçi Etiketi",
      markerId: const MarkerId("markerIdString"),
      position: const LatLng(11.1203, 45.33),
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
        title: const Text("Marker Crafter Demo"),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(11.1203, 45.33),
          zoom: 10,
        ),
        markers: markers,
      ),
    );
  }
}
