import 'package:econoris_app/ui/core/themes/theme.dart';
import 'package:econoris_app/ui/core/ui/widgets/card_container.dart';
import 'package:flutter/material.dart';

class LogoutSection extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onLogoutAll;

  const LogoutSection({super.key, required this.onLogout, required this.onLogoutAll});

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Déconnexion', style: Theme.of(context).textTheme.titleMedium),

          const SizedBox(height: 12),

          /// Logout button
          Row(
            children: [
              Icon(Icons.logout, color: AppTheme.errorColor),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onLogout,
                child: const Text('Déconnexion de cet appareil'),
              ),
            ],
          ),

          /// Logout all button
          Row(
            children: [
              Icon(Icons.exit_to_app, color: AppTheme.errorColor),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onLogoutAll,
                child: const Text('Déconnexion de tous les appareils'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
