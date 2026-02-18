import 'package:econoris_app/data/models/subscriptions/subscription_dto.dart';
import 'package:econoris_app/data/services/api/subscriptions/subscriptions_api_client.dart';

/// Repository interface for subscriptions data.
class SubscriptionsRepositoryRemote {
  /// Fetches a list of subscriptions from the remote API.
  Future<List<SubscriptionDto>> getSubscriptions() async {
    final subscriptionsDtoList = await SubscriptionsApiClient.getSubscriptions();
    return subscriptionsDtoList.map((subscription) => SubscriptionDto.fromJson(subscription)).toList();
  }

  /// Adds a new subscription to the remote API.
  Future<SubscriptionDto> addSubscription(SubscriptionDto body) async {
    final subscription = await SubscriptionsApiClient.addSubscription(body.toJson());
    return SubscriptionDto.fromJson(subscription);
  }

  /// Updates an existing subscription in the remote API.
  Future<SubscriptionDto> updateSubscription(int id, SubscriptionDto body) async {
    final subscription = await SubscriptionsApiClient.updateSubscription(id, body.toJson());
    return SubscriptionDto.fromJson(subscription);
  }

  /// Deletes an subscription from the remote API.
  Future<SubscriptionDto> deleteSubscription(int id) async {
    final subscription = await SubscriptionsApiClient.deleteSubscription(id);
    return SubscriptionDto.fromJson(subscription);
  }
}
