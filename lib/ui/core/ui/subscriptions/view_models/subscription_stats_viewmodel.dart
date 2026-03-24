import 'package:econoris_app/domain/models/subscriptions/subscription.dart';
import 'package:econoris_app/ui/subscriptions/view_models/subscription_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider derive unique qui calcule les statistiques de la home.
final subscriptionStatsProvider =
    Provider<AsyncValue<SubscriptionStatsViewModel>>((ref) {
      final asyncSubscriptions = ref.watch(subscriptionViewModelProvider);
      return asyncSubscriptions.whenData(
        (subscriptions) =>
            SubscriptionStatsViewModel.fromSubscriptions(subscriptions),
      );
    });

/// Statistiques de synthese calculees en un seul parcours de la liste.
class SubscriptionStatsViewModel {
  const SubscriptionStatsViewModel({
    required this.subscriptionsCount,
    required this.subscriptionsAmount,

    required this.positiveSubscriptionsCount,
    required this.positiveSubscriptionsAmount,

    required this.negativeSubscriptionsCount,
    required this.negativeSubscriptionsAmount,
  });

  final int subscriptionsCount;
  final double subscriptionsAmount;

  final int positiveSubscriptionsCount;
  final double positiveSubscriptionsAmount;

  final int negativeSubscriptionsCount;
  final double negativeSubscriptionsAmount;

  /// Calcule les statistiques à partir de la liste de subscriptions en un seul parcours.
  factory SubscriptionStatsViewModel.fromSubscriptions(
    List<Subscription> subscriptions,
  ) {
    int subscriptionsCount = 0;
    double subscriptionsAmount = 0;

    int positiveSubscriptionsCount = 0;
    double positiveSubscriptionsAmount = 0;

    int negativeSubscriptionsCount = 0;
    double negativeSubscriptionsAmount = 0;

    for (final subscription in subscriptions) {
      subscriptionsCount++;
      subscriptionsAmount += subscription.amount;

      if (subscription.amount > 0) {
        positiveSubscriptionsCount++;
        positiveSubscriptionsAmount += subscription.amount;
      } else if (subscription.amount < 0) {
        negativeSubscriptionsCount++;
        negativeSubscriptionsAmount += subscription.amount;
      }
    }

    /// On retourne un objet de stats avec tous les calculs déjà faits pour éviter de les refaire dans le widget.
    return SubscriptionStatsViewModel(
      subscriptionsCount: subscriptionsCount,
      subscriptionsAmount: subscriptionsAmount,
      positiveSubscriptionsCount: positiveSubscriptionsCount,
      positiveSubscriptionsAmount: positiveSubscriptionsAmount,
      negativeSubscriptionsCount: negativeSubscriptionsCount,
      negativeSubscriptionsAmount: negativeSubscriptionsAmount,
    );
  }
}
