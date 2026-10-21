import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marker_crafter/marker_crafter.dart';

/// Width and height stored in the IHDR chunk of a PNG.
Size pngSize(Uint8List png) {
  final ByteData data = ByteData.sublistView(png);
  expect(png.sublist(1, 4), 'PNG'.codeUnits, reason: 'not a PNG');
  return Size(data.getUint32(16).toDouble(), data.getUint32(20).toDouble());
}

/// Decodes [png] and returns the RGBA color at ([x], [y]).
Future<Color> pixelAt(Uint8List png, int x, int y) async {
  final ui.Codec codec = await ui.instantiateImageCodec(png);
  final ui.FrameInfo frame = await codec.getNextFrame();
  final ByteData rgba = (await frame.image.toByteData())!;
  final int offset = (y * frame.image.width + x) * 4;
  final Color color = Color.fromARGB(
    rgba.getUint8(offset + 3),
    rgba.getUint8(offset),
    rgba.getUint8(offset + 1),
    rgba.getUint8(offset + 2),
  );
  frame.image.dispose();
  codec.dispose();
  return color;
}

BytesMapBitmap asBytes(BitmapDescriptor descriptor) {
  expect(descriptor, isA<BytesMapBitmap>());
  return descriptor as BytesMapBitmap;
}

const MarkerCrafter crafter = MarkerCrafter(
  text: 'AB',
  markerId: MarkerId('m1'),
  position: LatLng(41.0, 29.0),
  backgroundColor: Color(0xFFFF0000),
);

void main() {
  // The test font draws every glyph as a fontSize × fontSize box, so text
  // measurements are exact.
  const TextStyle style = TextStyle(fontSize: 10, color: Colors.white);

  group('createLabelMarkerBitmap', () {
    testWidgets('sizes the bubble from the text and the pixel ratio', (WidgetTester tester) async {
      final BytesMapBitmap bitmap = asBytes(
        (await tester.runAsync(() => createLabelMarkerBitmap('ABCDEF', textStyle: style, pixelRatio: 2)))!,
      );

      // 60 text + 2 × 16 padding wide, 10 text + 2 × 8 padding + 10 arrow high.
      expect(pngSize(bitmap.byteData), const Size(92 * 2, 36 * 2));
      expect(bitmap.imagePixelRatio, 2);
    });

    testWidgets('keeps a minimum width for short text', (WidgetTester tester) async {
      final BytesMapBitmap bitmap = asBytes(
        (await tester.runAsync(() => createLabelMarkerBitmap('', textStyle: style, pixelRatio: 1)))!,
      );

      expect(pngSize(bitmap.byteData).width, 36);
    });

    testWidgets('wraps the text at maxWidth', (WidgetTester tester) async {
      final BytesMapBitmap bitmap = asBytes(
        (await tester.runAsync(() => createLabelMarkerBitmap('AB CD EF', textStyle: style, maxWidth: 30, pixelRatio: 1)))!,
      );

      // Three 20 px wide lines: "AB", "CD" and "EF".
      expect(pngSize(bitmap.byteData), const Size(20 + 32, 30 + 16 + 10));
    });

    testWidgets('cuts the text at maxLines', (WidgetTester tester) async {
      final BytesMapBitmap bitmap = asBytes(
        (await tester.runAsync(
          () => createLabelMarkerBitmap('AB CD EF', textStyle: style, maxWidth: 30, maxLines: 1, pixelRatio: 1),
        ))!,
      );

      expect(pngSize(bitmap.byteData).height, 10 + 16 + 10);
    });

    testWidgets('scales the text with textScaler', (WidgetTester tester) async {
      final BytesMapBitmap bitmap = asBytes(
        (await tester.runAsync(
          () => createLabelMarkerBitmap('AB', textStyle: style, textScaler: const TextScaler.linear(2), pixelRatio: 1),
        ))!,
      );

      expect(pngSize(bitmap.byteData), const Size(40 + 32, 20 + 16 + 10));
    });

    testWidgets('lays the text out in textDirection', (WidgetTester tester) async {
      const Color background = Color(0xFF00FF00);
      const Color white = Color(0xFFFFFFFF);
      await tester.runAsync(() async {
        // "A B." is left-to-right letters plus a neutral period. In a
        // right-to-left paragraph the period moves to the left: ".A B".
        final BytesMapBitmap ltr = asBytes(
          await createLabelMarkerBitmap('A B.', textStyle: style, backgroundColor: background, pixelRatio: 1),
        );
        final BytesMapBitmap rtl = asBytes(
          await createLabelMarkerBitmap(
            'A B.',
            textStyle: style,
            backgroundColor: background,
            textDirection: TextDirection.rtl,
            pixelRatio: 1,
          ),
        );

        // The text starts at x = 16 and each glyph is 10 px; the row y = 13
        // crosses the glyphs. The second slot is the space in "A B." and a
        // glyph ("A") in ".A B".
        expect(pngSize(rtl.byteData), pngSize(ltr.byteData));
        expect(await pixelAt(ltr.byteData, 30, 13), background);
        expect(await pixelAt(rtl.byteData, 30, 13), white);
      });
    });

    testWidgets('puts the arrow tip at the bottom center', (WidgetTester tester) async {
      final Color background = const Color(0xFF00FF00);
      await tester.runAsync(() async {
        final BytesMapBitmap bitmap = asBytes(
          await createLabelMarkerBitmap('ABCDEF', textStyle: style, backgroundColor: background, pixelRatio: 1),
        );
        final Size size = pngSize(bitmap.byteData);
        final int bottom = size.height.toInt() - 1;

        expect((await pixelAt(bitmap.byteData, size.width ~/ 2, bottom - 1)).a, greaterThan(0.5));
        expect((await pixelAt(bitmap.byteData, 2, bottom)).a, 0);
        expect(await pixelAt(bitmap.byteData, 2, 18), background);
      });
    });
  });

  group('createRingMarkerBitmap', () {
    testWidgets('is 2 × radius wide at any text length', (WidgetTester tester) async {
      await tester.runAsync(() async {
        for (final String text in <String>['1', '12345678']) {
          final BytesMapBitmap bitmap = asBytes(await createRingMarkerBitmap(text, radius: 15, pixelRatio: 3));
          expect(pngSize(bitmap.byteData), const Size(90, 90));
        }
      });
    });

    testWidgets('draws the colored ring and the white inner circle', (WidgetTester tester) async {
      const Color background = Color(0xFF0000FF);
      await tester.runAsync(() async {
        final BytesMapBitmap bitmap = asBytes(
          await createRingMarkerBitmap('', radius: 20, backgroundColor: background, pixelRatio: 1),
        );

        expect(await pixelAt(bitmap.byteData, 20, 3), background);
        expect(await pixelAt(bitmap.byteData, 20, 20), const Color(0xFFFFFFFF));
        expect((await pixelAt(bitmap.byteData, 0, 0)).a, 0);
      });
    });

    testWidgets('draws the text in the background color by default', (WidgetTester tester) async {
      const Color background = Color(0xFF0000FF);
      await tester.runAsync(() async {
        final BytesMapBitmap bitmap = asBytes(
          await createRingMarkerBitmap('8', radius: 20, backgroundColor: background, pixelRatio: 1),
        );

        // A single test-font glyph is a filled box around the center.
        expect(await pixelAt(bitmap.byteData, 20, 20), background);
      });
    });
  });

  group('createLocationMarkerBitmap', () {
    testWidgets('renders size × size logical pixels', (WidgetTester tester) async {
      const Color color = Color(0xFFFF00FF);
      await tester.runAsync(() async {
        final BytesMapBitmap bitmap = asBytes(await createLocationMarkerBitmap(color, size: 30, pixelRatio: 3));

        expect(pngSize(bitmap.byteData), const Size(90, 90));
        expect(bitmap.imagePixelRatio, 3);
        expect(await pixelAt(bitmap.byteData, 45, 45), color);
      });
    });

    testWidgets('fits the antennas inside the image', (WidgetTester tester) async {
      const Color color = Color(0xFFFF00FF);
      await tester.runAsync(() async {
        final BytesMapBitmap bitmap = asBytes(await createLocationMarkerBitmap(color, size: 30, pixelRatio: 3));
        final ui.Codec codec = await ui.instantiateImageCodec(bitmap.byteData);
        final ui.Image image = (await codec.getNextFrame()).image;
        final ByteData rgba = (await image.toByteData())!;
        int alphaAt(int x, int y) => rgba.getUint8((y * image.width + x) * 4 + 3);

        // Nothing touches the edges, so nothing was cut off.
        for (int i = 0; i < 90; i++) {
          expect(<int>[alphaAt(i, 0), alphaAt(i, 89), alphaAt(0, i), alphaAt(89, i)], everyElement(0), reason: 'edge $i');
        }
        // Both antennas are drawn outside the circle, towards the top corners.
        expect(alphaAt(77, 12), 255);
        expect(alphaAt(12, 12), 255);
        image.dispose();
        codec.dispose();
      });
    });

    testWidgets('waits for the screen metrics at start-up', (WidgetTester tester) async {
      addTearDown(tester.view.reset);
      // Before the platform reports the metrics the view has no size and 1.0.
      tester.view
        ..physicalSize = Size.zero
        ..devicePixelRatio = 1.0;

      final BytesMapBitmap bitmap = asBytes((await tester.runAsync(() async {
        final Future<BitmapDescriptor> pending = createLocationMarkerBitmap(Colors.red, size: 30);
        await Future<void>.delayed(const Duration(milliseconds: 20));
        tester.view
          ..devicePixelRatio = 2.5
          ..physicalSize = const Size(1000, 2000);
        return pending;
      }))!);

      expect(bitmap.imagePixelRatio, 2.5);
      expect(pngSize(bitmap.byteData), const Size(75, 75));
    });

    testWidgets('stops waiting for the metrics after the timeout', (WidgetTester tester) async {
      addTearDown(tester.view.reset);
      tester.view
        ..physicalSize = Size.zero
        ..devicePixelRatio = 1.0;

      final double? ratio = await tester.runAsync(() => waitForPixelRatio(null, const Duration(milliseconds: 50)));

      expect(ratio, 1.0);
      expect(await waitForPixelRatio(3), 3);
    });

    testWidgets('uses the device pixel ratio by default', (WidgetTester tester) async {
      final double ratio = tester.view.devicePixelRatio;
      final BytesMapBitmap bitmap = asBytes((await tester.runAsync(() => createLocationMarkerBitmap(Colors.red)))!);

      expect(resolvePixelRatio(), ratio);
      expect(bitmap.imagePixelRatio, ratio);
      expect(pngSize(bitmap.byteData), Size((30 * ratio).ceilToDouble(), (30 * ratio).ceilToDouble()));
    });
  });

  group('LocationMarkerPainter', () {
    test('repaints only when the color changes', () {
      const LocationMarkerPainter red = LocationMarkerPainter(color: Colors.red);

      expect(red.shouldRepaint(const LocationMarkerPainter(color: Colors.red)), isFalse);
      expect(red.shouldRepaint(const LocationMarkerPainter(color: Colors.blue)), isTrue);
    });
  });

  group('MarkerCrafter.toMarker', () {
    test('passes the marker options through', () {
      void onTap() {}
      final MarkerCrafter options = MarkerCrafter(
        text: 'x',
        markerId: const MarkerId('id'),
        position: const LatLng(1, 2),
        alpha: 0.5,
        consumeTapEvents: true,
        draggable: true,
        flat: true,
        infoWindow: const InfoWindow(title: 'title'),
        rotation: 90,
        visible: false,
        zIndexInt: 3,
        clusterManagerId: const ClusterManagerId('cluster'),
        onTap: onTap,
      );

      final Marker marker = options.toMarker(BitmapDescriptor.defaultMarker);

      expect(marker.markerId, const MarkerId('id'));
      expect(marker.position, const LatLng(1, 2));
      expect(marker.alpha, 0.5);
      expect(marker.anchor, const Offset(0.5, 1.0));
      expect(marker.consumeTapEvents, isTrue);
      expect(marker.draggable, isTrue);
      expect(marker.flat, isTrue);
      expect(marker.infoWindow.title, 'title');
      expect(marker.rotation, 90);
      expect(marker.visible, isFalse);
      expect(marker.zIndexInt, 3);
      expect(marker.clusterManagerId, const ClusterManagerId('cluster'));
      expect(marker.onTap, onTap);
    });

    test('does not need text', () {
      const MarkerCrafter options = MarkerCrafter(markerId: MarkerId('id'), position: LatLng(0, 0));

      expect(options.text, isEmpty);
      expect(options.toMarker(BitmapDescriptor.defaultMarker).clusterManagerId, isNull);
    });

    test('prefers an explicit anchor over the default', () {
      const MarkerCrafter options = MarkerCrafter(
        text: 'x',
        markerId: MarkerId('id'),
        position: LatLng(0, 0),
        anchor: Offset(0.1, 0.2),
      );

      expect(options.toMarker(BitmapDescriptor.defaultMarker, defaultAnchor: Offset.zero).anchor, const Offset(0.1, 0.2));
    });
  });

  group('MarkerCrafterSetExtension', () {
    testWidgets('adds markers with shape specific anchors', (WidgetTester tester) async {
      final Set<Marker> markers = <Marker>{};
      await tester.runAsync(() async {
        final Marker label = await markers.addLabelMarker(crafter, pixelRatio: 1);
        expect(label.anchor, const Offset(0.5, 1.0));
        expect(asBytes(label.icon).imagePixelRatio, 1);

        final Marker ring = await markers.addRingMarker(
          const MarkerCrafter(text: '1', markerId: MarkerId('m2'), position: LatLng(0, 0)),
          pixelRatio: 1,
        );
        expect(ring.anchor, const Offset(0.5, 0.5));

        final Marker location = await markers.addLocationMarker(
          const MarkerCrafter(text: '', markerId: MarkerId('m3'), position: LatLng(0, 0)),
          size: 20,
          pixelRatio: 2,
        );
        expect(pngSize(asBytes(location.icon).byteData), const Size(40, 40));
      });

      expect(markers.map((Marker m) => m.markerId.value), <String>['m1', 'm2', 'm3']);
    });

    testWidgets('replaces a marker with the same id', (WidgetTester tester) async {
      final Set<Marker> markers = <Marker>{};
      await tester.runAsync(() async {
        await markers.addLabelMarker(crafter, pixelRatio: 1);
        await markers.addRingMarker(crafter, pixelRatio: 1);
      });

      expect(markers, hasLength(1));
      expect(markers.single.anchor, const Offset(0.5, 0.5));
    });

    testWidgets('keeps the 1.x methods working', (WidgetTester tester) async {
      final Set<Marker> markers = <Marker>{};
      await tester.runAsync(() async {
        // ignore: deprecated_member_use_from_same_package
        expect(await markers.addTextMarker(crafter), isTrue);
        // ignore: deprecated_member_use_from_same_package
        expect(await markers.addRoundedMarker(crafter), isTrue);
      });

      expect(markers, hasLength(1));
    });
  });
}
