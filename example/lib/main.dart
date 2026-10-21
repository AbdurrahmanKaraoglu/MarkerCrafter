import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'src/app_strings.dart';
import 'src/app_theme.dart';
import 'src/map_page.dart';
import 'src/studio_page.dart';

void main() {
  runApp(const MarkerCrafterExampleApp());
}

class MarkerCrafterExampleApp extends StatelessWidget {
  const MarkerCrafterExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: appLocale,
      builder: (BuildContext context, Locale? locale, _) => MaterialApp(
        title: 'Marker Crafter',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        // Null follows the device language (Turkish or English).
        locale: locale,
        supportedLocales: supportedLocales,
        localeListResolutionCallback: resolveLocale,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: const HomeShell(),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = AppStrings.of(context);
    return Scaffold(
      // Keeps both pages alive so the map is not recreated on every switch.
      body: IndexedStack(index: _index, children: const <Widget>[MapPage(), StudioPage()]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int index) => setState(() => _index = index),
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            label: strings.navMap,
          ),
          NavigationDestination(
            icon: const Icon(Icons.tune_outlined),
            selectedIcon: const Icon(Icons.tune),
            label: strings.navStudio,
          ),
        ],
      ),
    );
  }
}
