import 'package:econoris_app/data/models/subscriptions/subscription_dto.dart';
import 'package:econoris_app/data/models/subscriptions/subscription_dto_mapper.dart';
import 'package:econoris_app/data/repositories/subscriptions/subscription_repository.dart';
import 'package:econoris_app/data/repositories/subscriptions/subscription_repository_local.dart';
import 'package:econoris_app/data/repositories/subscriptions/subscription_repository_remote.dart';
import 'package:econoris_app/domain/models/subscriptions/subscription.dart';

/// Repository interface for subscriptions data.
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRepositoryRemote remote;
  final SubscriptionRepositoryLocal local;

  SubscriptionRepositoryImpl({required this.remote, required this.local});

  /// Fetches a list of subscriptions from the remote API.
  @override
  Future<List<Subscription>> getSubscriptions() async {
    List<SubscriptionDto> subscriptionsDtoList = [];
    try {
      subscriptionsDtoList = await remote.getSubscriptions();
      local.saveSubscriptions(subscriptionsDtoList);
    } catch (e) {
      subscriptionsDtoList = await local.getSubscriptions();
    }

    return subscriptionsDtoList
        .map((subscriptionDto) => subscriptionDto.toDomain())
        .toList();
  }

  /// Adds a new subscription to the remote API.
  @override
  Future<Subscription> addSubscription(SubscriptionDto body) async {
    try {
      final subscriptionDto = await remote.addSubscription(body);
      local.saveSubscriptions([subscriptionDto]);
      return subscriptionDto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  /// Updates an existing subscription in the remote API.
  @override
  Future<Subscription> updateSubscription(int id, SubscriptionDto body) async {
    final subscriptionDto = await remote.updateSubscription(
      id,
      body,
    );
    local.updateSubscription(id, subscriptionDto);
    return subscriptionDto.toDomain();
  }

  /// Deletes an subscription from the remote API.
  @override
  Future<Subscription> deleteSubscription(int id) async {
    final subscriptionDto = await remote.deleteSubscription(id);
    local.deleteSubscription(id);
    return subscriptionDto.toDomain();
  }
}
