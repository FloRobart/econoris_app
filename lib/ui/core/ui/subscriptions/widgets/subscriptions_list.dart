import 'package:econoris_app/domain/models/subscriptions/subscription.dart';
import 'package:econoris_app/ui/core/ui/subscriptions/widgets/subscription_card.dart';
import 'package:econoris_app/ui/core/ui/utils/format_date.dart';
import 'package:econoris_app/ui/subscriptions/view_models/subscription_action.dart';
import 'package:flutter/material.dart';

/// Écran d'accueil de l'application.
class SubscriptionsList extends StatelessWidget {
  const SubscriptionsList({
    super.key,
    required this.subscriptions,
    required this.subscriptionAction,
  });

  final List<Subscription> subscriptions;
  final SubscriptionAction subscriptionAction;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    if (subscriptions.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<Subscription> displayedSubscriptions =
        List<Subscription>.generate(
          subscriptions.length,
          (index) => subscriptions[index],
        );

    final Map<DateTime, int> subscriptionCountByDate = <DateTime, int>{};
    for (final Subscription subscription in displayedSubscriptions) {
      final DateTime dateKey = DateUtils.dateOnly(subscription.startDate);
      subscriptionCountByDate[dateKey] =
          (subscriptionCountByDate[dateKey] ?? 0) + 1;
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayedSubscriptions.length,
      itemBuilder: (context, index) {
        final Subscription subscription = displayedSubscriptions[index];
        final bool showDateSeparator =
            index == 0 ||
            !DateUtils.isSameDay(
              displayedSubscriptions[index - 1].startDate,
              subscription.startDate,
            );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateSeparator) ...[
              if (index != 0) const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    DateUtils.isSameDay(subscription.startDate, DateTime.now())
                        ? ' Aujourd\'hui'
                        : formatDate(
                                subscription.startDate,
                                customFormat: ' EEEE dd MMMM yyyy',
                              ) ??
                              ' Date Inconnu',
                    style: theme.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Text(
                    '${subscriptionCountByDate[DateUtils.dateOnly(subscription.startDate)] ?? 0} ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 1),
              const SizedBox(height: 4),
            ],
            SubscriptionCard(
              subscription: subscription,
              subscriptionAction: subscriptionAction,
            ),
          ],
        );
      },
    );
  }
}
