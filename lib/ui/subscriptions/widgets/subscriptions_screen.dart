import 'package:econoris_app/domain/models/auth/user/user.dart';
import 'package:econoris_app/ui/core/ui/widgets/base_app.dart';
import 'package:flutter/material.dart';

/// Écran d'accueil de l'application.
class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseApp(
      user: User(
        email: 'email',
        pseudo: 'pseudo',
        isConnected: true,
        isVerifiedEmail: true,
        createdAt: DateTime.now(),
      ),
      body: const Center(child: Text('Subscriptions Screen')),
    );
  }
}
