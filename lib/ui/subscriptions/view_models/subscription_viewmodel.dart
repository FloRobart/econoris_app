import 'package:econoris_app/domain/models/subscriptions/create/subscription_create.dart';
import 'package:econoris_app/domain/models/subscriptions/subscription.dart';
import 'package:econoris_app/domain/use_cases/subscriptions/subscription_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider d'etat asynchrone pour les Subscriptions.
final subscriptionViewModelProvider =
    AsyncNotifierProvider<SubscriptionViewModel, List<Subscription>>(
      SubscriptionViewModel.new,
    );

/// ViewModel pour la gestion de l'etat des Subscriptions.
class SubscriptionViewModel extends AsyncNotifier<List<Subscription>> {
  late final SubscriptionUseCase _useCase;

  @override
  Future<List<Subscription>> build() async {
    _useCase = ref.read(subscriptionUseCaseProvider);
    return _useCase.getSubscriptions();
  }

  /// Recharge la liste complete depuis la source de donnees.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _useCase.getSubscriptions());
  }

  /// Cree une Subscription cote serveur puis met a jour l'etat local.
  Future<void> addSubscription(SubscriptionCreate body) async {
    final createdSubscription = await _useCase.addSubscription(body);
    final currentSubscriptions = switch (state) {
      AsyncData<List<Subscription>>(:final value) => value,
      _ => <Subscription>[],
    };
    state = AsyncData([...currentSubscriptions, createdSubscription]);
  }

  /// Met a jour une subscription cote serveur puis met a jour l'etat local.
  Future<void> editSubscription(Subscription subscription) async {
    final updatedSubscription = await _useCase.updateSubscription(
      subscription.id,
      subscription,
    );
    final currentSubscriptions = switch (state) {
      AsyncData<List<Subscription>>(:final value) => value,
      _ => <Subscription>[],
    };

    state = AsyncData(
      currentSubscriptions
          .map(
            (sub) =>
                sub.id == updatedSubscription.id ? updatedSubscription : sub,
          )
          .toList(),
    );
  }

  /// Supprime une Subscription cote serveur puis met a jour l'etat local.
  Future<void> deleteSubscription(int id) async {
    await _useCase.deleteSubscription(id);
    final currentSubscriptions = switch (state) {
      AsyncData<List<Subscription>>(:final value) => value,
      _ => <Subscription>[],
    };

    state = AsyncData(
      currentSubscriptions
          .where((subscription) => subscription.id != id)
          .toList(),
    );
  }
}
