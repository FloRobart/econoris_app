import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/global_data_impl.dart';

import '../config/app_config.dart';
import '../routing/app_routes.dart';

/// Reusable scaffold that provides a consistent AppBar (logo + app name + Profil)
/// and BottomNavigationBar used across the app.
class AppScaffold extends StatelessWidget {
  final Widget body;
  // currentIndex may be null to indicate the profile view (no bottom tab
  // should be highlighted). When omitted, it defaults to 0.
  final int? currentIndex;

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
    if (i == 0) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.home, (r) => r.isFirst);
    }
    if (i == 1) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.operations, (r) => r.isFirst);
    }
    if (i == 2) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.subscriptions, (r) => r.isFirst);
    }
    if (i == 3) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.placeholder, (r) => r.isFirst,
          arguments: {'title': 'Prêts'});
    }
    if (i == 4) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.placeholder, (r) => r.isFirst,
          arguments: {'title': 'Horaires'});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use theme's onSurface color for foreground elements so they contrast
    // correctly with the current theme (light/dark). Keep a slightly faded
    // color for unselected bottom navigation items.
    final Color foreground = Theme.of(context).colorScheme.onSurface;
    final Color unselectedForeground =
        foreground.withAlpha((0.7 * 255).toInt());
    final bool isProfileSelected = currentIndex == null;
    // When profile is selected we want the profile name/icon to be amber
    // and no bottom navigation item should appear selected. We achieve that
    // by using the unselected color as the BottomNavigationBar selected color
    // so visually none stands out.
    final Color profileHighlightColor =
        isProfileSelected ? Colors.amber : foreground;
    final TextStyle? titleStyle =
        Theme.of(context).textTheme.titleLarge?.copyWith(color: foreground);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // Ensure AppBar icons and title use the foreground color for contrast
        iconTheme: IconThemeData(color: foreground),
        titleTextStyle: titleStyle,
        title: InkWell(
          onTap: () {
            // Navigate to root (/) when tapping the logo+app name
            Navigator.of(context)
                .pushNamedAndRemoveUntil(AppRoutes.root, (r) => r.isFirst);
          },
          // Keep the Row to the size of its children so the tappable area
          // doesn't expand to the full AppBar width.
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Image.asset('logo/econoris_logo-512.png', width: 36),
            const SizedBox(width: 8),
            Text(AppConfig.appName)
          ]),
        ),
        // Show the current user's name/email and a profile icon on the right side
        actions: [
          // Use FutureBuilder to call the API and obtain the user's name/pseudo.
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Builder(builder: (ctx) {
              // Small text style for name to avoid truncation in the AppBar.
              // Use `profileHighlightColor` when the profile is the active view.
              final TextStyle? nameStyle = Theme.of(ctx)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: profileHighlightColor, fontSize: 14);

              final Future<String?> displayFuture = (() async {
                try {
                  final sp = await SharedPreferences.getInstance();
                  final jwt = sp.getString('jwt');
                  if (jwt != null && jwt.isNotEmpty) {
                    await GlobalData.instance.ensureData(jwt);
                    final p = GlobalData.instance.profile;
                    final name = p != null ? (p['pseudo'] ?? p['name']) : null;
                    if (name != null && name is String && name.isNotEmpty) {
                      return name;
                    }
                  }
                  // fallback to saved email local-part
                  final sp2 = await SharedPreferences.getInstance();
                  final email = sp2.getString('email') ?? '';
                  if (email.isNotEmpty) return email.split('@').first;
                } catch (e) {
                  // ignore errors, fallback will be used
                }
                return null;
              })();

              void openProfile() {
                if (onProfilePressed != null) {
                  onProfilePressed!(ctx);
                  return;
                }
                Navigator.of(ctx).pushNamed(AppRoutes.profile);
              }

              return FutureBuilder<String?>(
                future: displayFuture,
                builder: (c, snap) {
                  final display = snap.hasData && snap.data != null
                      ? snap.data!.trim()
                      : '';
                  final List<Widget> children = [];
                  if (display.isNotEmpty) {
                    children.add(Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Center(
                          child: Text(display,
                              style: nameStyle,
                              overflow: TextOverflow.ellipsis)),
                    ));
                  }
                  children
                      .add(Icon(Icons.person, color: profileHighlightColor));

                  return InkWell(
                    onTap: openProfile,
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 6.0),
                      child: Row(
                          mainAxisSize: MainAxisSize.min, children: children),
                    ),
                  );
                },
              );
            }),
          )
        ],
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex ?? 0,
        onTap: (i) {
          if (onBottomNavTap != null) {
            onBottomNavTap!(context, i);
            return;
          }
          _defaultBottomTap(context, i);
        },
        // Use the theme's surface as background and explicit colors for
        // selected/unselected items so they remain readable in both themes.
        backgroundColor: Theme.of(context).colorScheme.surface,
        // If profile is selected (currentIndex == null) we don't want any
        // bottom item to appear highlighted — use the unselected color as
        // the "selected" color in that case. Otherwise highlight with amber.
        selectedItemColor:
            isProfileSelected ? unselectedForeground : Colors.amber,
        unselectedItemColor: unselectedForeground,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt), label: 'Opérations'),
          BottomNavigationBarItem(
              icon: Icon(Icons.repeat), label: 'Abonnements'),
          BottomNavigationBarItem(
              icon: Icon(Icons.monetization_on), label: 'Prêts'),
          BottomNavigationBarItem(
              icon: Icon(Icons.access_time), label: 'Horaires'),
        ],
      ),
    );
  }
}
