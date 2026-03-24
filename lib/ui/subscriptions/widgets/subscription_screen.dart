import 'package:econoris_app/ui/core/ui/widgets/base_app.dart';
import 'package:econoris_app/ui/subscriptions/view_models/subscription_viewmodel.dart';
import 'package:econoris_app/ui/subscriptions/widgets/subscription_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Écran d'accueil de l'application.
class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseApp(
      onRefresh: () async {
        await ref.read(subscriptionViewModelProvider.notifier).refresh();
      },
      body: SubscriptionBody(),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Ajouter un abonnement',
        child: const Icon(Icons.add),
      ),
    );
  }
}
