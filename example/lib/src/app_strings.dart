import 'package:flutter/material.dart';

/// The app language chosen in the language menu; null follows the device.
final ValueNotifier<Locale?> appLocale = ValueNotifier<Locale?>(null);

const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('tr')];

/// Turkish on Turkish devices, English everywhere else.
Locale resolveLocale(List<Locale>? deviceLocales, Iterable<Locale> supported) {
  for (final Locale locale in deviceLocales ?? const <Locale>[]) {
    if (locale.languageCode == 'tr') {
      return const Locale('tr');
    }
    if (locale.languageCode == 'en') {
      return const Locale('en');
    }
  }
  return const Locale('en');
}

/// UI texts of the example. Every language implements every getter, so a
/// missing translation is a compile error.
abstract class AppStrings {
  const AppStrings();

  static AppStrings of(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'tr' ? const _TurkishStrings() : const _EnglishStrings();

  String get navMap;
  String get navStudio;

  String get mapSubtitle;
  String markerCount(int count);

  String get kindLabel;
  String get kindRing;
  String get kindLocation;

  String get galataTower;
  String get hagiaSophia;
  String get headOffice;
  String get logisticsHub;
  String get fieldTeam;
  String get landmark;
  String openRoles(int count);
  String vehicles(int count);
  String get liveLocation;

  String get studioTitle;
  String get studioSubtitle;
  String get shape;
  String get text;
  String get textHint;
  String get color;
  String maxWidth(int value);
  String radius(int value);
  String size(int value);
  String get maxLines;
  String get noLimit;
  String get followFontSize;
  String get followFontSizeHint;
  String get code;
  String get copy;
  String get codeCopied;
  String get rendering;
  String get anchorGuides;

  String get language;
  String get systemLanguage;

  /// Upper-cases [value] with the rules of the language. Dart's
  /// [String.toUpperCase] turns the Turkish "i" into "I" instead of "İ".
  String upper(String value) => value.toUpperCase();
}

class _EnglishStrings extends AppStrings {
  const _EnglishStrings();

  @override
  String get navMap => 'Map';
  @override
  String get navStudio => 'Studio';

  @override
  String get mapSubtitle => 'Istanbul operations';
  @override
  String markerCount(int count) => count == 1 ? '1 marker' : '$count markers';

  @override
  String get kindLabel => 'Label';
  @override
  String get kindRing => 'Ring';
  @override
  String get kindLocation => 'Location';

  @override
  String get galataTower => 'Galata Tower';
  @override
  String get hagiaSophia => 'Hagia Sophia';
  @override
  String get headOffice => 'Head Office';
  @override
  String get logisticsHub => 'Logistics Hub';
  @override
  String get fieldTeam => 'Field Team';
  @override
  String get landmark => 'Landmark';
  @override
  String openRoles(int count) => count == 1 ? '1 open role' : '$count open roles';
  @override
  String vehicles(int count) => count == 1 ? '1 vehicle' : '$count vehicles';
  @override
  String get liveLocation => 'Live location';

  @override
  String get studioTitle => 'Marker Studio';
  @override
  String get studioSubtitle => 'Design a marker and copy the code';
  @override
  String get shape => 'Shape';
  @override
  String get text => 'Text';
  @override
  String get textHint => 'Marker text';
  @override
  String get color => 'Color';
  @override
  String maxWidth(int value) => 'Max width · $value pt';
  @override
  String radius(int value) => 'Radius · $value pt';
  @override
  String size(int value) => 'Size · $value pt';
  @override
  String get maxLines => 'Max lines';
  @override
  String get noLimit => 'No limit';
  @override
  String get followFontSize => 'Follow system font size';
  @override
  String get followFontSizeHint => 'Uses MediaQuery.textScalerOf(context)';
  @override
  String get code => 'Code';
  @override
  String get copy => 'Copy';
  @override
  String get codeCopied => 'Code copied';
  @override
  String get rendering => 'Rendering…';
  @override
  String get anchorGuides => 'anchor guides';

  @override
  String get language => 'Language';
  @override
  String get systemLanguage => 'Device language';
}

class _TurkishStrings extends AppStrings {
  const _TurkishStrings();

  @override
  String upper(String value) => value.replaceAll('i', 'İ').toUpperCase();

  @override
  String get navMap => 'Harita';
  @override
  String get navStudio => 'Stüdyo';

  @override
  String get mapSubtitle => 'İstanbul operasyonları';
  @override
  String markerCount(int count) => '$count işaretçi';

  @override
  String get kindLabel => 'Etiket';
  @override
  String get kindRing => 'Halka';
  @override
  String get kindLocation => 'Konum';

  @override
  String get galataTower => 'Galata Kulesi';
  @override
  String get hagiaSophia => 'Ayasofya';
  @override
  String get headOffice => 'Genel Merkez';
  @override
  String get logisticsHub => 'Lojistik Merkezi';
  @override
  String get fieldTeam => 'Saha Ekibi';
  @override
  String get landmark => 'Simge yapı';
  @override
  String openRoles(int count) => '$count açık pozisyon';
  @override
  String vehicles(int count) => '$count araç';
  @override
  String get liveLocation => 'Canlı konum';

  @override
  String get studioTitle => 'İşaretçi Stüdyosu';
  @override
  String get studioSubtitle => 'Bir işaretçi tasarla, kodunu kopyala';
  @override
  String get shape => 'Şekil';
  @override
  String get text => 'Metin';
  @override
  String get textHint => 'İşaretçi metni';
  @override
  String get color => 'Renk';
  @override
  String maxWidth(int value) => 'En fazla genişlik · $value pt';
  @override
  String radius(int value) => 'Yarıçap · $value pt';
  @override
  String size(int value) => 'Boyut · $value pt';
  @override
  String get maxLines => 'En fazla satır';
  @override
  String get noLimit => 'Sınırsız';
  @override
  String get followFontSize => 'Sistem yazı boyutunu izle';
  @override
  String get followFontSizeHint => 'MediaQuery.textScalerOf(context) kullanır';
  @override
  String get code => 'Kod';
  @override
  String get copy => 'Kopyala';
  @override
  String get codeCopied => 'Kod kopyalandı';
  @override
  String get rendering => 'Çiziliyor…';
  @override
  String get anchorGuides => 'anchor kılavuzları';

  @override
  String get language => 'Dil';
  @override
  String get systemLanguage => 'Cihaz dili';
}

/// Menu for choosing the app language: the device language, English or
/// Turkish. Language names are shown in their own language.
class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = AppStrings.of(context);
    return ValueListenableBuilder<Locale?>(
      valueListenable: appLocale,
      builder: (BuildContext context, Locale? selected, _) {
        final List<(Locale?, String)> options = <(Locale?, String)>[
          (null, strings.systemLanguage),
          (const Locale('en'), 'English'),
          (const Locale('tr'), 'Türkçe'),
        ];
        return PopupMenuButton<int>(
          tooltip: strings.language,
          icon: const Icon(Icons.translate_rounded),
          onSelected: (int index) => appLocale.value = options[index].$1,
          itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
            for (int i = 0; i < options.length; i++)
              CheckedPopupMenuItem<int>(value: i, checked: options[i].$1 == selected, child: Text(options[i].$2)),
          ],
        );
      },
    );
  }
}
