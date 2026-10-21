import 'package:flutter/material.dart';

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
    return MaterialApp(
      title: 'Marker Crafter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const HomeShell(),
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
    return Scaffold(
      // Keeps both pages alive so the map is not recreated on every switch.
      body: IndexedStack(
        index: _index,
        children: const <Widget>[MapPage(), StudioPage()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int index) => setState(() => _index = index),
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.tune_outlined), selectedIcon: Icon(Icons.tune), label: 'Studio'),
        ],
      ),
    );
  }
}
