import 'package:econoris_app/data/services/api/subscriptions/subscription_api_client.dart';
import 'package:econoris_app/providers/data/services/api/api_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance asynchrone d'[SubscriptionApiClient].
final subscriptionApiClientProvider = Provider<SubscriptionApiClient>((ref) {
  return SubscriptionApiClient(apiClient: ref.read(apiClientProvider));
});
