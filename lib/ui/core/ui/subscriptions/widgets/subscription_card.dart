import 'package:econoris_app/domain/models/subscriptions/subscription.dart';
import 'package:econoris_app/ui/core/themes/theme.dart';
import 'package:econoris_app/ui/core/ui/utils/format_amount.dart';
import 'package:econoris_app/ui/core/ui/utils/format_date.dart';
import 'package:econoris_app/ui/subscriptions/view_models/subscription_action.dart';
import 'package:flutter/material.dart';

/// Écran d'accueil de l'application.
class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({
    super.key,
    required this.subscription,
    required this.subscriptionAction,
  });

  final Subscription subscription;
  final SubscriptionAction subscriptionAction;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final String subscriptionDate =
        formatDate(
          subscription.lastGeneratedAt,
          customFormat: 'dd MMMM yyyy',
        ) ??
        'Aucune génération';

    return SizedBox(
      width: double.infinity,
      child: Card(
        child: InkWell(
          onTap: () => subscriptionAction.showDetails(subscription),
          onLongPress: () =>
              subscriptionAction.onDeleteSubscription(subscription.id),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.event_repeat),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              subscriptionDate,
                              style: TextStyle(
                                color: subscription.active
                                    ? AppTheme.successColor
                                    : AppTheme.infoColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          const SizedBox(width: 8),

                          Icon(
                            subscription.active
                                ? Icons.check_circle_outline
                                : Icons.hourglass_empty_outlined,
                            size: 16,
                            color: subscription.active
                                ? AppTheme.successColor
                                : AppTheme.infoColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  formatAmount(subscription.amount),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: subscription.amount >= 0
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
