import 'package:econoris_app/data/models/subscriptions/subscription_dto.dart';
import 'package:econoris_app/data/models/subscriptions/subscription_dto_mapper.dart';
import 'package:econoris_app/data/repositories/subscriptions/subscription_repository.dart';
import 'package:econoris_app/data/repositories/subscriptions/subscription_repository_local.dart';
import 'package:econoris_app/data/repositories/subscriptions/subscription_repository_remote.dart';
import 'package:econoris_app/domain/models/subscriptions/create/subscription_create.dart';
import 'package:econoris_app/domain/models/subscriptions/create/subscription_create_mapper.dart';
import 'package:econoris_app/domain/models/subscriptions/subscription.dart';
import 'package:econoris_app/domain/models/subscriptions/subscription_mapper.dart';

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
      // local.saveSubscriptions(subscriptionsDtoList);
    } catch (e) {
      // subscriptionsDtoList = await local.getSubscriptions();
      rethrow;
    }

    return subscriptionsDtoList
        .map((subscriptionDto) => subscriptionDto.toDomain())
        .toList();
  }

  /// Adds a new subscription to the remote API.
  @override
  Future<Subscription> addSubscription(SubscriptionCreate body) async {
    try {
      final bodyDto = body.toDto();
      final subscriptionDto = await remote.addSubscription(bodyDto);
      // local.addSubscription(subscriptionDto);
      return subscriptionDto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  /// Updates an existing subscription in the remote API.
  @override
  Future<Subscription> updateSubscription(int id, Subscription body) async {
    try {
      final bodyDto = body.toDto();
      final subscriptionDto = await remote.updateSubscription(id, bodyDto);
      // local.updateSubscription(id, subscriptionDto);
      return subscriptionDto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes an subscription from the remote API.
  @override
  Future<Subscription> deleteSubscription(int id) async {
    try {
      final subscriptionDto = await remote.deleteSubscription(id);
      // local.deleteSubscription(id);
      return subscriptionDto.toDomain();
    } catch (e) {
      rethrow;
    }
  }
}
