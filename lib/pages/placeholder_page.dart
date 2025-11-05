import 'package:flutter/material.dart';

import '../widgets/app_scaffold.dart';

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  int _indexForTitle() {
    if (title.toLowerCase().contains('opération') || title.toLowerCase().contains('opérations')) return 1;
    if (title.toLowerCase().contains('prêt') || title.toLowerCase().contains('prêts')) return 2;
    if (title.toLowerCase().contains('horaire') || title.toLowerCase().contains('horaires')) return 3;
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
