import 'package:flutter/material.dart';

import 'app_scaffold.dart';

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  int _indexForTitle() {
    if (title.toLowerCase().contains('opération') ||
        title.toLowerCase().contains('opérations')) {
      return 1;
    }
    // Map titles to the BottomNavigationBar indices:
    // 0: Accueil, 1: Opérations, 2: Abonnements, 3: Prêts, 4: Horaires
    if (title.toLowerCase().contains('prêt') ||
        title.toLowerCase().contains('prêts')) {
      return 3;
    }
    if (title.toLowerCase().contains('horaire') ||
        title.toLowerCase().contains('horaires')) {
      return 4;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: _indexForTitle(),
      body: Center(child: Text('$title - Page en construction')),
      // keep default profile behavior and bottom nav behavior
    );
  }
}
