import 'package:econoris_app/data/models/subscriptions/subscription_dto.dart';
import 'package:econoris_app/data/models/subscriptions/subscription_dto_mapper.dart';
import 'package:econoris_app/data/repositories/subscriptions/subscriptions_repository.dart';
import 'package:econoris_app/data/repositories/subscriptions/subscriptions_repository_local.dart';
import 'package:econoris_app/data/repositories/subscriptions/subscriptions_repository_remote.dart';
import 'package:econoris_app/domain/models/subscriptions/subscription.dart';

/// Repository interface for subscriptions data.
class SubscriptionsRepositoryImpl implements SubscriptionsRepository {
  /// Fetches a list of subscriptions from the remote API.
  @override
  Future<List<Subscription>> getSubscriptions() async {
    List<SubscriptionDto> subscriptionsDtoList = [];
    try {
      subscriptionsDtoList = await SubscriptionsRepositoryRemote().getSubscriptions();
      SubscriptionsRepositoryLocal().saveSubscriptions(subscriptionsDtoList);
    } catch (e) {
      subscriptionsDtoList = await SubscriptionsRepositoryLocal().getSubscriptions();
    }

    return subscriptionsDtoList
        .map((subscriptionDto) => subscriptionDto.toDomain())
        .toList();
  }

  /// Adds a new subscription to the remote API.
  @override
  Future<Subscription> addSubscription(SubscriptionDto body) async {
    try {
      final subscriptionDto = await SubscriptionsRepositoryRemote().addSubscription(body);
      SubscriptionsRepositoryLocal().saveSubscriptions([subscriptionDto]);
      return subscriptionDto.toDomain();
    } catch (e) {
      print('Error adding subscription: $e');
      rethrow;
    }
  }

  /// Updates an existing subscription in the remote API.
  @override
  Future<Subscription> updateSubscription(int id, SubscriptionDto body) async {
    final subscriptionDto = await SubscriptionsRepositoryRemote().updateSubscription(
      id,
      body,
    );
    SubscriptionsRepositoryLocal().updateSubscription(id, subscriptionDto);
    return subscriptionDto.toDomain();
  }

  /// Deletes an subscription from the remote API.
  @override
  Future<Subscription> deleteSubscription(int id) async {
    final subscriptionDto = await SubscriptionsRepositoryRemote().deleteSubscription(id);
    SubscriptionsRepositoryLocal().deleteSubscription(id);
    return subscriptionDto.toDomain();
  }
}
