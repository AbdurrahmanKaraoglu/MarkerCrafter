import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marker_crafter/marker_crafter.dart';

import 'app_theme.dart';
import 'map_page.dart' show PlaceKind;
import 'marker_preview.dart';

const List<Color> _palette = <Color>[
  Color(0xFF1F3A5F),
  Color(0xFF0F766E),
  Color(0xFF4338CA),
  Color(0xFF7A4E2D),
  Color(0xFFDC2626),
  Color(0xFF334155),
];

/// Edits a marker and shows the generated bitmap live. Works without a Google
/// Maps API key.
class StudioPage extends StatefulWidget {
  const StudioPage({super.key});

  @override
  State<StudioPage> createState() => _StudioPageState();
}

class _StudioPageState extends State<StudioPage> {
  final TextEditingController _text = TextEditingController(text: 'Galata Tower');
  PlaceKind _kind = PlaceKind.label;
  Color _color = _palette.first;
  double _labelWidth = 160;
  double _ringRadius = 22;
  double _locationSize = 32;
  int? _maxLines = 2;
  bool _followFontSize = true;

  BitmapDescriptor? _icon;
  int _generation = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _render();
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _update(VoidCallback change) {
    setState(change);
    _render();
  }

  Future<void> _render() async {
    final int generation = ++_generation;
    final double pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final TextScaler textScaler = _followFontSize ? MediaQuery.textScalerOf(context) : TextScaler.noScaling;
    final BitmapDescriptor icon = switch (_kind) {
      PlaceKind.label => await createLabelMarkerBitmap(
        _text.text,
        backgroundColor: _color,
        maxWidth: _labelWidth,
        maxLines: _maxLines,
        textScaler: textScaler,
        pixelRatio: pixelRatio,
      ),
      PlaceKind.ring => await createRingMarkerBitmap(
        _text.text,
        radius: _ringRadius,
        backgroundColor: _color,
        textScaler: textScaler,
        pixelRatio: pixelRatio,
      ),
      PlaceKind.location => await createLocationMarkerBitmap(_color, size: _locationSize, pixelRatio: pixelRatio),
    };
    if (mounted && generation == _generation) {
      setState(() => _icon = icon);
    }
  }

  String get _code {
    final String color = '0x${_color.toARGB32().toRadixString(16).toUpperCase()}';
    final String text = _kind == PlaceKind.location ? '' : "\n    text: '${_text.text}',";
    final String crafter =
        '  MarkerCrafter($text\n'
        '    markerId: id,\n'
        '    position: position,\n'
        '    backgroundColor: Color($color),\n'
        '  ),';
    final String font = _followFontSize ? '\n  textScaler: MediaQuery.textScalerOf(context),' : '';
    final String lines = _maxLines == null ? '' : '\n  maxLines: $_maxLines,';
    return switch (_kind) {
      PlaceKind.label => 'await markers.addLabelMarker(\n$crafter\n  maxWidth: ${_labelWidth.round()},$lines$font\n);',
      PlaceKind.ring => 'await markers.addRingMarker(\n$crafter\n  radius: ${_ringRadius.round()},$font\n);',
      PlaceKind.location => 'await markers.addLocationMarker(\n$crafter\n  size: ${_locationSize.round()},\n);',
    };
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Marker Studio'),
            Text(
              'Design a marker and copy the code',
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.md, Gap.sm, Gap.md, Gap.lg),
        children: <Widget>[
          _PreviewCard(icon: _icon, anchor: _kind == PlaceKind.label ? const Offset(0.5, 1) : const Offset(0.5, 0.5)),
          const SizedBox(height: Gap.md),
          _Section(
            title: 'Shape',
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<PlaceKind>(
                showSelectedIcon: false,
                segments: const <ButtonSegment<PlaceKind>>[
                  ButtonSegment<PlaceKind>(value: PlaceKind.label, label: Text('Label'), icon: Icon(Icons.chat_bubble_outline)),
                  ButtonSegment<PlaceKind>(value: PlaceKind.ring, label: Text('Ring'), icon: Icon(Icons.radio_button_checked)),
                  ButtonSegment<PlaceKind>(value: PlaceKind.location, label: Text('Location'), icon: Icon(Icons.my_location)),
                ],
                selected: <PlaceKind>{_kind},
                onSelectionChanged: (Set<PlaceKind> value) => _update(() {
                  _kind = value.single;
                  if (_kind == PlaceKind.ring && _text.text.length > 4) {
                    _text.text = '12';
                  } else if (_kind == PlaceKind.label && _text.text.length <= 4) {
                    _text.text = 'Galata Tower';
                  }
                }),
              ),
            ),
          ),
          if (_kind != PlaceKind.location) ...<Widget>[
            const SizedBox(height: Gap.md),
            _Section(
              title: 'Text',
              child: TextField(
                controller: _text,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.text_fields), hintText: 'Marker text'),
                onChanged: (_) => _update(() {}),
              ),
            ),
          ],
          const SizedBox(height: Gap.md),
          _Section(
            title: 'Color',
            child: Wrap(
              spacing: Gap.sm + Gap.xs,
              runSpacing: Gap.sm,
              children: <Widget>[
                for (final Color color in _palette)
                  _Swatch(color: color, selected: color == _color, onTap: () => _update(() => _color = color)),
              ],
            ),
          ),
          const SizedBox(height: Gap.md),
          _Section(
            title: switch (_kind) {
              PlaceKind.label => 'Max width · ${_labelWidth.round()} pt',
              PlaceKind.ring => 'Radius · ${_ringRadius.round()} pt',
              PlaceKind.location => 'Size · ${_locationSize.round()} pt',
            },
            child: switch (_kind) {
              PlaceKind.label => Slider(
                value: _labelWidth,
                min: 80,
                max: 240,
                divisions: 16,
                onChanged: (double v) => _update(() => _labelWidth = v),
              ),
              PlaceKind.ring => Slider(
                value: _ringRadius,
                min: 14,
                max: 36,
                divisions: 11,
                onChanged: (double v) => _update(() => _ringRadius = v),
              ),
              PlaceKind.location => Slider(
                value: _locationSize,
                min: 20,
                max: 56,
                divisions: 9,
                onChanged: (double v) => _update(() => _locationSize = v),
              ),
            },
          ),
          if (_kind == PlaceKind.label) ...<Widget>[
            const SizedBox(height: Gap.md),
            _Section(
              title: 'Max lines',
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<int>(
                  showSelectedIcon: false,
                  segments: const <ButtonSegment<int>>[
                    ButtonSegment<int>(value: 1, label: Text('1')),
                    ButtonSegment<int>(value: 2, label: Text('2')),
                    ButtonSegment<int>(value: 3, label: Text('3')),
                    ButtonSegment<int>(value: 0, label: Text('No limit')),
                  ],
                  selected: <int>{_maxLines ?? 0},
                  onSelectionChanged: (Set<int> value) => _update(() => _maxLines = value.single == 0 ? null : value.single),
                ),
              ),
            ),
          ],
          if (_kind != PlaceKind.location) ...<Widget>[
            const SizedBox(height: Gap.sm),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Follow system font size'),
              subtitle: const Text('Uses MediaQuery.textScalerOf(context)'),
              value: _followFontSize,
              onChanged: (bool v) => _update(() => _followFontSize = v),
            ),
          ],
          const SizedBox(height: Gap.md),
          _CodeCard(code: _code),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: Gap.sm),
        child,
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.selected, required this.onTap});

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Color ${color.toARGB32().toRadixString(16)}',
      child: InkResponse(
        onTap: onTap,
        radius: 28,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: selected ? scheme.primary : Colors.transparent, width: 2),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: selected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
          ),
        ),
      ),
    );
  }
}

/// Shows the marker on a neutral grid with a crosshair at the anchor point,
/// which is the point that sits on the map position.
class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.icon, required this.anchor});

  final BitmapDescriptor? icon;
  final Offset anchor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final BitmapDescriptor? icon = this.icon;
    final Size? size = icon is BytesMapBitmap ? _logicalSize(icon) : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 220,
            child: CustomPaint(
              painter: _GridPainter(
                grid: scheme.outlineVariant.withValues(alpha: 0.5),
                guide: scheme.error.withValues(alpha: 0.55),
              ),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final Offset center = constraints.biggest.center(Offset.zero);
                  return Stack(
                    children: <Widget>[
                      if (size != null)
                        Positioned(
                          left: center.dx - size.width * anchor.dx,
                          top: center.dy - size.height * anchor.dy,
                          child: MarkerPreview(icon: icon),
                        )
                      else
                        Center(child: MarkerPreview(icon: icon)),
                    ],
                  );
                },
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.sm + Gap.xs),
            child: Row(
              children: <Widget>[
                Icon(Icons.straighten, size: 18, color: scheme.onSurfaceVariant),
                const SizedBox(width: Gap.sm),
                Expanded(
                  child: Text(
                    size == null
                        ? 'Rendering…'
                        : '${size.width.round()} × ${size.height.round()} pt  ·  '
                              '${(icon as BytesMapBitmap).imagePixelRatio}x  ·  '
                              '${(icon.byteData.lengthInBytes / 1024).toStringAsFixed(1)} KB',
                    style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
                Container(width: 14, height: 2, color: scheme.error.withValues(alpha: 0.55)),
                const SizedBox(width: Gap.xs + 2),
                Text('anchor guides', style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Size _logicalSize(BytesMapBitmap icon) {
    final ByteData data = ByteData.sublistView(icon.byteData);
    final double ratio = icon.imagePixelRatio;
    return Size(data.getUint32(16) / ratio, data.getUint32(20) / ratio);
  }
}

/// A neutral grid with two guide lines crossing at the center, where the
/// marker's anchor is placed. Painted behind the marker so it never hides it.
class _GridPainter extends CustomPainter {
  _GridPainter({required this.grid, required this.guide});

  final Color grid;
  final Color guide;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    const double step = 20;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final Paint guidePaint = Paint()
      ..color = guide
      ..strokeWidth = 1.5;
    final Offset center = size.center(Offset.zero);
    canvas
      ..drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), guidePaint)
      ..drawLine(Offset(0, center.dy), Offset(size.width, center.dy), guidePaint);
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => oldDelegate.grid != grid || oldDelegate.guide != guide;
}

class _CodeCard extends StatelessWidget {
  const _CodeCard({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Card(
      color: scheme.inverseSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.md, Gap.xs, Gap.xs, Gap.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'CODE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onInverseSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Copy',
                  color: scheme.onInverseSurface,
                  icon: const Icon(Icons.copy_rounded, size: 20),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: code));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copied')));
                    }
                  },
                ),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                code,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12.5,
                  height: 1.5,
                  color: scheme.onInverseSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
