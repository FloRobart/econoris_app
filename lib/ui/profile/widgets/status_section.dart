import 'package:econoris_app/ui/core/themes/theme.dart';
import 'package:econoris_app/ui/core/ui/utils/format_date.dart';
import 'package:econoris_app/ui/core/ui/widgets/card_container.dart';
import 'package:flutter/material.dart';

class StatusSection extends StatelessWidget {
  const StatusSection({
    super.key,
    required this.isConnected,
    required this.isEmailVerified,
    required this.createdAt,
  });

  final bool isConnected;
  final bool isEmailVerified;
  final DateTime createdAt;

  String get getDateDiff {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays >= 365) {
      final years = (difference.inDays / 365).floor();
      return '$years an${years > 1 ? 's' : ''}';
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return '$months mois';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'moins d\'une minute';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(
              'Statut du compte',
              style: Theme.of(context).textTheme.titleMedium,
            ),

          const SizedBox(height: 12),

          /// Connection status
          Row(
            children: [
              Icon(
                Icons.link,
                color: isConnected ? AppTheme.success : AppTheme.error,
              ),
              const SizedBox(width: 8),
              Flexible(child: Text('${!isConnected ? 'Non ' : ''}Connecté')),
            ],
          ),

          const SizedBox(height: 8),

          /// Email verification status
          Row(
            children: [
              Icon(
                Icons.email,
                color: isEmailVerified ? AppTheme.success : AppTheme.warning,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text('Email ${!isEmailVerified ? 'non ' : ''}vérifié'),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// Account creation date
          Row(
            children: [
              const Icon(Icons.calendar_today),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Créé le : ${formatDate(createdAt, customFormat: 'EEEE dd MMMM yyyy') ?? 'Inconnu'} (Il y a $getDateDiff)',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
