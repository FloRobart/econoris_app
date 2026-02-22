import 'package:econoris_app/data/repositories/subscriptions/subscription_repository.dart';
import 'package:econoris_app/data/repositories/subscriptions/subscription_repository_impl.dart';
import 'package:econoris_app/data/repositories/subscriptions/subscription_repository_local.dart';
import 'package:econoris_app/data/repositories/subscriptions/subscription_repository_remote.dart';
import 'package:econoris_app/providers/data/services/api/subscriptions/subscription_api_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance asynchrone d'[SubscriptionRepository].
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final remote = SubscriptionRepositoryRemote(subscriptionApiClient: ref.read(subscriptionApiClientProvider));
  final local = SubscriptionRepositoryLocal();

  return SubscriptionRepositoryImpl(remote: remote, local: local);
});
