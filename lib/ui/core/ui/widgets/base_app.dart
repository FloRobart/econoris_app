import 'package:econoris_app/ui/core/ui/widgets/header.dart';
import 'package:econoris_app/ui/core/ui/widgets/app_navigation_bar.dart';
import 'package:flutter/material.dart';

/// Widget d'en-tête pour les écrans de l'application.
class BaseApp extends StatelessWidget {
  final Widget body;

  const BaseApp({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /* En-tête */
      appBar: Header(),

      /* Contenu principal */
      body: body,

      /* Navigation */
      bottomNavigationBar: const AppNavigationBar(),
    );
  }
}
