import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marker_crafter/marker_crafter.dart';

import 'app_theme.dart';
import 'marker_preview.dart';

enum PlaceKind { label, ring, location }

class Place {
  const Place(this.id, this.name, this.category, this.position, this.kind, this.color, {this.badge = ''});

  final String id;
  final String name;
  final String category;
  final LatLng position;
  final PlaceKind kind;
  final Color color;

  /// Text drawn on ring markers.
  final String badge;
}

const List<Place> _places = <Place>[
  Place('galata', 'Galata Tower', 'Landmark', LatLng(41.0256, 28.9741), PlaceKind.label, Color(0xFF1F3A5F)),
  Place('hagia', 'Hagia Sophia', 'Landmark', LatLng(41.0086, 28.9802), PlaceKind.label, Color(0xFF7A4E2D)),
  Place('office', 'Head Office', '12 open roles', LatLng(41.0766, 29.0135), PlaceKind.ring, Color(0xFF0F766E), badge: '12'),
  Place('hub', 'Logistics Hub', '48 vehicles', LatLng(41.0422, 28.8922), PlaceKind.ring, Color(0xFF4338CA), badge: '48'),
  Place('team', 'Field Team', 'Live location', LatLng(41.0369, 28.9850), PlaceKind.location, Color(0xFFDC2626)),
];

/// Places on a Google Map with a card carousel underneath.
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const CameraPosition _start = CameraPosition(target: LatLng(41.035, 28.97), zoom: 11.6);

  GoogleMapController? _controller;
  Set<Marker> _markers = <Marker>{};
  Map<String, BitmapDescriptor> _icons = <String, BitmapDescriptor>{};
  String? _selected;
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
      _buildMarkers(pixelRatio, textScaler);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _buildMarkers(double pixelRatio, TextScaler textScaler) async {
    // Draws into a new set and keeps only the newest one, so a slower, older
    // drawing (for example the one made before the screen metrics arrived)
    // never replaces a newer one.
    final int generation = ++_generation;
    final Set<Marker> markers = <Marker>{};
    final Map<String, BitmapDescriptor> icons = <String, BitmapDescriptor>{};

    for (final Place place in _places) {
      final MarkerCrafter crafter = MarkerCrafter(
        text: place.kind == PlaceKind.ring ? place.badge : place.name,
        markerId: MarkerId(place.id),
        position: place.position,
        backgroundColor: place.color,
        infoWindow: InfoWindow(title: place.name, snippet: place.category),
        onTap: () => _select(place, moveCamera: false),
      );
      final Marker marker = switch (place.kind) {
        PlaceKind.label => await markers.addLabelMarker(crafter, maxWidth: 140, maxLines: 2, textScaler: textScaler, pixelRatio: pixelRatio),
        PlaceKind.ring => await markers.addRingMarker(crafter, radius: 22, textScaler: textScaler, pixelRatio: pixelRatio),
        PlaceKind.location => await markers.addLocationMarker(crafter, size: 32, pixelRatio: pixelRatio),
      };
      icons[place.id] = marker.icon;
    }

    if (mounted && generation == _generation) {
      setState(() {
        _markers = markers;
        _icons = icons;
      });
    }
  }

  void _select(Place place, {bool moveCamera = true}) {
    setState(() => _selected = place.id);
    if (moveCamera) {
      _controller?.animateCamera(CameraUpdate.newLatLngZoom(place.position, 14));
      _controller?.showMarkerInfoWindow(MarkerId(place.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Stack(
      children: <Widget>[
        GoogleMap(
          initialCameraPosition: _start,
          markers: _markers,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          myLocationButtonEnabled: false,
          // Leaves room for the header and the cards.
          padding: const EdgeInsets.only(top: 96, bottom: 150),
          onMapCreated: (GoogleMapController controller) => _controller = controller,
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Gap.md, Gap.sm, Gap.md, 0),
            child: _Header(count: _places.length),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: Gap.md,
          child: SizedBox(
            height: 118,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: Gap.md),
              scrollDirection: Axis.horizontal,
              itemCount: _places.length,
              separatorBuilder: (_, _) => const SizedBox(width: Gap.sm + Gap.xs),
              itemBuilder: (BuildContext context, int index) {
                final Place place = _places[index];
                return _PlaceCard(
                  place: place,
                  icon: _icons[place.id],
                  selected: place.id == _selected,
                  selectedColor: scheme.primary,
                  onTap: () => _select(place),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.md, Gap.sm + Gap.xs, Gap.sm + Gap.xs, Gap.sm + Gap.xs),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.place_rounded, color: scheme.onPrimary),
            ),
            const SizedBox(width: Gap.sm + Gap.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Marker Crafter', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  Text('Istanbul operations', style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
            Chip(
              avatar: Icon(Icons.layers_outlined, size: 18, color: scheme.primary),
              label: Text('$count markers'),
              side: BorderSide(color: scheme.outlineVariant),
              backgroundColor: scheme.surfaceContainerLow,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({
    required this.place,
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  final Place place;
  final BitmapDescriptor? icon;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final String kind = switch (place.kind) {
      PlaceKind.label => 'Label',
      PlaceKind.ring => 'Ring',
      PlaceKind.location => 'Location',
    };
    return SizedBox(
      width: 236,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: selected ? selectedColor : scheme.outlineVariant, width: selected ? 2 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(Gap.sm + Gap.xs),
            child: Row(
              children: <Widget>[
                Container(
                  width: 72,
                  height: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: scheme.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(padding: const EdgeInsets.all(Gap.xs), child: MarkerPreview(icon: icon)),
                  ),
                ),
                const SizedBox(width: Gap.sm + Gap.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        place.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        place.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: Gap.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: Gap.sm, vertical: 2),
                        decoration: BoxDecoration(
                          color: place.color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          kind,
                          style: theme.textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
