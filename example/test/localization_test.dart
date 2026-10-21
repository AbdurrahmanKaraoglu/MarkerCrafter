import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marker_crafter_example/src/app_strings.dart';
import 'package:marker_crafter_example/src/studio_page.dart';

Widget _app(Locale locale) => MaterialApp(
  locale: locale,
  supportedLocales: supportedLocales,
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  home: const StudioPage(),
);

void main() {
  test('follows Turkish devices and falls back to English', () {
    expect(resolveLocale(const <Locale>[Locale('tr', 'TR')], supportedLocales), const Locale('tr'));
    expect(resolveLocale(const <Locale>[Locale('de'), Locale('en', 'GB')], supportedLocales), const Locale('en'));
    expect(resolveLocale(const <Locale>[Locale('de')], supportedLocales), const Locale('en'));
    expect(resolveLocale(null, supportedLocales), const Locale('en'));
  });

  testWidgets('upper-cases with Turkish rules', (WidgetTester tester) async {
    late AppStrings turkish;
    late AppStrings english;
    await tester.pumpWidget(
      Localizations(
        locale: const Locale('tr'),
        delegates: GlobalMaterialLocalizations.delegates,
        child: Builder(
          builder: (BuildContext context) {
            turkish = AppStrings.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.pumpWidget(
      Localizations(
        locale: const Locale('en'),
        delegates: GlobalMaterialLocalizations.delegates,
        child: Builder(
          builder: (BuildContext context) {
            english = AppStrings.of(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(turkish.upper('Şekil · genişlik'), 'ŞEKİL · GENİŞLİK');
    expect(turkish.upper('satır'), 'SATIR');
    expect(english.upper('Shape'), 'SHAPE');
  });

  testWidgets('shows the studio in Turkish and English', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(_app(const Locale('tr')));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();
    expect(find.text('İşaretçi Stüdyosu'), findsOneWidget);
    expect(find.text('Galata Kulesi'), findsOneWidget);

    await tester.runAsync(() async {
      await tester.pumpWidget(_app(const Locale('en')));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();
    expect(find.text('Marker Studio'), findsOneWidget);
    // The untouched sample text follows the language.
    expect(find.text('Galata Tower'), findsOneWidget);
  });
}
