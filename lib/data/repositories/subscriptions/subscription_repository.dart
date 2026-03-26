import 'package:econoris_app/data/services/api/subscriptions/subscription_api_client.dart';
import 'package:econoris_app/domain/models/subscriptions/create/subscription_create.dart';
import 'package:econoris_app/domain/models/subscriptions/subscription.dart';
import 'package:econoris_app/data/repositories/subscriptions/subscription_repository_impl.dart';
import 'package:econoris_app/data/repositories/subscriptions/subscription_repository_local.dart';
import 'package:econoris_app/data/repositories/subscriptions/subscription_repository_remote.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance asynchrone d'[SubscriptionRepository].
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final remote = SubscriptionRepositoryRemote(
    subscriptionApiClient: ref.read(subscriptionApiClientProvider),
  );
  final local = SubscriptionRepositoryLocal();

  return SubscriptionRepositoryImpl(remote: remote, local: local);
});

/// Repository interface for subscriptions data.
abstract class SubscriptionRepository {
  Future<List<Subscription>> getSubscriptions();
  Future<Subscription> addSubscription(SubscriptionCreate body);
  Future<Subscription> updateSubscription(int id, Subscription body);
  Future<Subscription> deleteSubscription(int id);
}
