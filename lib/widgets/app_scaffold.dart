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
  /// Optional floating action button displayed by the Scaffold.
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.body,
    this.currentIndex = 0,
    this.onProfilePressed,
    this.onBottomNavTap,
    this.floatingActionButton,
  });

  void _defaultBottomTap(BuildContext context, int i) {
    // When switching bottom tabs we want to replace the whole navigation stack
    // so pages don't pile up on top of each other. Use pushNamedAndRemoveUntil
    // to leave only the newly selected route on the stack.
    if (i == 0) Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (r) => r.isFirst);
    if (i == 1) Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.placeholder, (r) => r.isFirst, arguments: {'title': 'Prêts'});
    if (i == 2) Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.placeholder, (r) => r.isFirst, arguments: {'title': 'Horaires'});
    if (i == 3) Navigator.of(context).pushNamed(AppRoutes.profile);
  }

  @override
  Widget build(BuildContext context) {
    // Use theme's onSurface color for foreground elements so they contrast
    // correctly with the current theme (light/dark). Keep a slightly faded
    // color for unselected bottom navigation items.
    final Color foreground = Theme.of(context).colorScheme.onSurface;
  final Color unselectedForeground = foreground.withAlpha((0.7 * 255).toInt());
    final TextStyle? titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(color: foreground);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // Ensure AppBar icons and title use the foreground color for contrast
        iconTheme: IconThemeData(color: foreground),
        titleTextStyle: titleStyle,
        title: Row(children: [Image.asset('logo/econoris_logo-512.png', width: 36), const SizedBox(width: 8), Text(Config.appName)]),
      ),
      body: body,
  floatingActionButton: floatingActionButton,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) {
          if (i == 3) {
            if (onProfilePressed != null) {
              onProfilePressed!(context);
              return;
            }
            _defaultBottomTap(context, i);
            return;
          }
          if (onBottomNavTap != null) {
            onBottomNavTap!(context, i);
            return;
          }
          _defaultBottomTap(context, i);
        },
        // Use the theme's surface as background and explicit colors for
        // selected/unselected items so they remain readable in both themes.
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: foreground,
        unselectedItemColor: unselectedForeground,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: 'Prêts'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Horaires'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
