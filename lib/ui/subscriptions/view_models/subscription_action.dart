import 'package:econoris_app/domain/models/subscriptions/subscription.dart';
import 'package:econoris_app/ui/subscriptions/widgets/subscription_details.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SubscriptionAction {
  SubscriptionAction(this.deleteSubscription, this.context);

  final Future<void> Function(int id) deleteSubscription;
  final BuildContext context;

  /// Affiche les détails d'une subscription dans une bottom sheet.
  Future<void> showDetails(Subscription subscription) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SubscriptionDetails(
        subscription: subscription,
        onDeleteSubscription: onDeleteSubscription,
      ),
    );
  }

  /// Affiche une boîte de dialogue de confirmation avant de supprimer une subscription.
  Future<void> onDeleteSubscription(int id) async {
    try {
      final bool? shouldDelete = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          ThemeData theme = Theme.of(dialogContext);

          return AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: const Text(
              'Cette abonnement sera supprimée définitivement.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  GoRouter.of(dialogContext).pop(false);
                },
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () {
                  GoRouter.of(dialogContext).pop(true);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
                child: const Text('Supprimer'),
              ),
            ],
          );
        },
      );

      if (shouldDelete != true) {
        return;
      }

      await deleteSubscription(id);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Opération supprimée.')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Une erreur est survenue lors de la suppression de l\'opération.',
            ),
          ),
        );
      }
    }
  }
}
