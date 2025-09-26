import 'package:flutter/material.dart';

import '../widgets/app_scaffold.dart';

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 0,
      body: const Center(child: Text('Page en construction')),
      // keep default profile behavior and bottom nav behavior
    );
  }
}
