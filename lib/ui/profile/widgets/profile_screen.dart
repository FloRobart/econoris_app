import 'package:econoris_app/ui/core/ui/widgets/base_app.dart';
import 'package:flutter/material.dart';

/// Écran de profil de l'application.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseApp(
      body: const Center(child: Text('Profile Screen')),
    );
  }
}
