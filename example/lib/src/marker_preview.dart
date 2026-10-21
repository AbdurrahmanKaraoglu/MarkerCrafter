import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Shows a Marker Crafter [BitmapDescriptor] at the size the map shows it.
class MarkerPreview extends StatelessWidget {
  const MarkerPreview({super.key, required this.icon});

  final BitmapDescriptor? icon;

  @override
  Widget build(BuildContext context) {
    final BitmapDescriptor? icon = this.icon;
    if (icon is! BytesMapBitmap) {
      return const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Image.memory(
      icon.byteData,
      scale: icon.imagePixelRatio,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
    );
  }
}
