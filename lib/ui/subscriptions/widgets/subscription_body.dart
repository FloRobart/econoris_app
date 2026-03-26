import 'package:econoris_app/domain/models/subscriptions/subscription.dart';
import 'package:econoris_app/ui/core/ui/subscriptions/widgets/subscription_monthly_stats.dart';
import 'package:econoris_app/ui/core/ui/subscriptions/widgets/subscriptions_list.dart';
import 'package:econoris_app/ui/subscriptions/view_models/subscription_action.dart';
import 'package:econoris_app/ui/subscriptions/view_models/subscription_body_viewmodel.dart';
import 'package:econoris_app/ui/subscriptions/view_models/subscription_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionBody extends ConsumerWidget {
  const SubscriptionBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final AsyncValue<List<Subscription>> asyncSubscriptions = ref.watch(
      subscriptionViewModelProvider,
    );

    SubscriptionAction subscriptionAction = SubscriptionAction(
      ref.read(subscriptionViewModelProvider.notifier).deleteSubscription,
      ref.read(subscriptionViewModelProvider.notifier).editSubscription,
      context,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// Affiche des statistiques mensuelles sur les abonnements
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: const SubscriptionMonthlyStats(),
        ),

        const SizedBox(height: 32),

        /// Affiche un titre pour la liste des abonnements
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.history_rounded,
                  color: theme.colorScheme.primary,
                  size: (theme.textTheme.titleLarge?.fontSize ?? 22) + 2,
                ),
                const SizedBox(width: 8),
                Text(
                  'Abonnements',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 22),

        /// Affiche la liste des abonnements
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: asyncSubscriptions.when(
            data: (subscriptions) {
              SubscriptionBodyViewmodel viewModel = SubscriptionBodyViewmodel(
                subscriptions,
              );
              return SubscriptionsList(
                subscriptions: viewModel.sortedSubscriptions,
                subscriptionAction: subscriptionAction,
              );
            },
            error: (error, stackTrace) =>
                const Center(child: Text('Error de chargement des abonnements, Rechargez la page')),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),

        const SizedBox(height: 96),
      ],
    );
  }
}
