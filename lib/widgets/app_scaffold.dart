import 'package:flutter/material.dart';

import '../config.dart';
import '../navigation/app_routes.dart';

/// Reusable scaffold that provides a consistent AppBar (logo + app name + Profil)
/// and BottomNavigationBar used across the app.
class AppScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  /// If provided, called with the BuildContext when the Profil button is tapped.
  /// Otherwise a default Navigator.pushNamed('/profile') is used.
  final void Function(BuildContext context)? onProfilePressed;
  /// If provided, called with (BuildContext, index) when a bottom nav item is tapped.
  /// Otherwise a default replacement navigation to '/placeholder' for indices 1 and 2 is used.
  final void Function(BuildContext context, int index)? onBottomNavTap;

  const AppScaffold({
    super.key,
    required this.body,
    this.currentIndex = 0,
    this.onProfilePressed,
    this.onBottomNavTap,
  });

  void _defaultProfile(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.profile);
  }

  void _defaultBottomTap(BuildContext context, int i) {
    // When switching bottom tabs we want to replace the whole navigation stack
    // so pages don't pile up on top of each other. Use pushNamedAndRemoveUntil
    // to leave only the newly selected route on the stack.
    if (i == 0) Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (r) => r.isFirst);
    if (i == 1) Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.placeholder, (r) => r.isFirst, arguments: {'title': 'Prêts'});
    if (i == 2) Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.placeholder, (r) => r.isFirst, arguments: {'title': 'Horaires'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(children: [Image.asset('assets/econoris_logo.png', width: 36), const SizedBox(width: 8), Text(Config.appName)]),
        actions: [
          TextButton(
            onPressed: () => (onProfilePressed != null ? onProfilePressed!(context) : _defaultProfile(context)),
            child: const Text('Profil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => (onBottomNavTap != null ? onBottomNavTap!(context, i) : _defaultBottomTap(context, i)),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: 'Prêts'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Horaires'),
        ],
      ),
    );
  }
}
