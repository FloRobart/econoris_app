import 'package:econoris_app/data/models/subscriptions/create/subscription_create_dto.dart';
import 'package:econoris_app/data/models/subscriptions/subscription_dto.dart';
import 'package:econoris_app/data/services/api/subscriptions/subscription_api_client.dart';

/// Repository interface for subscriptions data.
class SubscriptionRepositoryRemote {
  const SubscriptionRepositoryRemote({required this.subscriptionApiClient});

  final SubscriptionApiClient subscriptionApiClient;

  /// Fetches a list of subscriptions from the remote API.
  Future<List<SubscriptionDto>> getSubscriptions() async {
    final subscriptionsDtoList = await subscriptionApiClient.getSubscriptions();
    return subscriptionsDtoList
        .map((subscription) => SubscriptionDto.fromJson(subscription))
        .toList();
  }

  /// Adds a new subscription to the remote API.
  Future<SubscriptionDto> addSubscription(SubscriptionCreateDto body) async {
    final subscription = await subscriptionApiClient.addSubscription(
      body.toJson(),
    );
    return SubscriptionDto.fromJson(subscription);
  }

  /// Updates an existing subscription in the remote API.
  Future<SubscriptionDto> updateSubscription(
    int id,
    SubscriptionDto body,
  ) async {
    final subscription = await subscriptionApiClient.updateSubscription(
      id,
      body.toJson(),
    );
    return SubscriptionDto.fromJson(subscription);
  }

  /// Deletes an subscription from the remote API.
  Future<SubscriptionDto> deleteSubscription(int id) async {
    final subscription = await subscriptionApiClient.deleteSubscription(id);
    return SubscriptionDto.fromJson(subscription);
  }
}
