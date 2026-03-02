import 'package:econoris_app/data/services/auth/auth_manager.dart';
import 'package:econoris_app/domain/models/users/user.dart';
import 'package:econoris_app/ui/core/ui/widgets/header.dart';
import 'package:econoris_app/ui/core/ui/widgets/app_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget d'en-tête pour les écrans de l'application.
class BaseApp extends ConsumerWidget {
  final Widget body;

  const BaseApp({super.key, required this.body});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final User user = ref.watch(authManagerProvider).currentUser ?? User(
      email: 'email',
      pseudo: 'Profile',
      isConnected: false,
      isVerifiedEmail: false,
      createdAt: DateTime.now(),
    );

    return Scaffold(
      /* En-tête */
      appBar: Header(userName: user.pseudo),

      /* Contenu principal */
      body: body,

      /* Navigation */
      bottomNavigationBar: const AppNavigationBar(),
    );
  }
}
