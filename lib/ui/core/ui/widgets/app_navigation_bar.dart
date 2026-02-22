import 'dart:math';

import 'package:econoris_app/routing/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

/// Widget de barre de navigation pour les écrans de l'application.
class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({super.key});

  /* Ordre des routes dans la barre de navigation */
  static const List<String> orderedRoutes = [
    AppRoutes.home,
    AppRoutes.login,
    AppRoutes.operations,
  ];

  /* Détermine l'index de la route actuelle dans la barre de navigation */
  int _currentIndex(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name;
    final indexOfCurrentRoute = orderedRoutes
        .indexOf(routeName ?? AppRoutes.home)
        .clamp(0, orderedRoutes.length - 1);
    return max(0, indexOfCurrentRoute);
  }

  /* Gére la navigation lors du tap sur un item de la barre de navigation */
  void _onTap(BuildContext context, int index) {
    if (index < 0 || index >= orderedRoutes.length) { return; }

    final nextRoute = orderedRoutes[index];

    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == nextRoute) {
      return;
    }

    GoRouter.of(context).pushNamed(nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex(context),
      onTap: (index) => _onTap(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.login_outlined),
          activeIcon: Icon(Icons.login),
          label: 'Connexion',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_outlined),
          activeIcon: Icon(Icons.list),
          label: 'Opérations',
        ),
      ],
    );
  }
}
