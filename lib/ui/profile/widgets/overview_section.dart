import 'package:econoris_app/ui/core/ui/widgets/card_container.dart';
import 'package:flutter/material.dart';

/// Section d'aperçu du profil, affichant des informations générales sur l'utilisateur.
class OverViewSection extends StatelessWidget {
  const OverViewSection({super.key, required this.pseudo, required this.email});

  final String pseudo;
  final String email;

  String get getUserInitial {
    if (pseudo.isEmpty) return '';
    return pseudo.split(' ')
      .where((s) => s.isNotEmpty)
      .map((s) => s[0].toUpperCase())
      .take(2)
      .join();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CardContainer(
      child: Row(
        children: [
          /// User avatar with initials
          CircleAvatar(
            radius: 34,
            child: Text(
              getUserInitial,
              style: const TextStyle(fontSize: 20),
            ),
          ),

          const SizedBox(width: 12),

          /// User info (pseudo and email)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    /// Pseudo
                    Text(
                      pseudo,
                      style: theme.textTheme.titleMedium,
                    ),

                    const SizedBox(width: 8),

                    /// Edit profile button
                    Icon(Icons.edit, color: theme.iconTheme.color),
                  ],
                ),

                const SizedBox(height: 4),

                /// Email
                Text(email, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
