import 'package:econoris_app/data/repositories/subscriptions/subscription_repository.dart';
import 'package:econoris_app/domain/models/subscriptions/subscription.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// Fournit une instance de [SubscriptionUseCase].
final subscriptionUseCaseProvider = Provider<SubscriptionUseCase>((ref) {
  final subscriptionRepository = ref.read(subscriptionRepositoryProvider);
  return SubscriptionUseCase(repository: subscriptionRepository);
});

/// Use case class for the subscription screen
class SubscriptionUseCase {
  SubscriptionUseCase({required this.repository});

  final SubscriptionRepository repository;

  /*=====*/
  /* GET */
  /*=====*/
  /// Fetches a list of subscriptions from the repository.
  Future<List<Subscription>> getSubscriptions() {
    return repository.getSubscriptions();
  }

  /*======*/
  /* POST */
  /*======*/
  Future<Subscription> addSubscription(Subscription body) {
    return repository.addSubscription(body);
  }

  /*=====*/
  /* PUT */
  /*=====*/
  // Future<Subscription> updateSubscription(int id, Subscription body) {
  //   return repository.updateSubscription(id, body);
  // }

  /*========*/
  /* DELETE */
  /*========*/
  Future<void> deleteSubscription(int id) {
    return repository.deleteSubscription(id);
  }
}