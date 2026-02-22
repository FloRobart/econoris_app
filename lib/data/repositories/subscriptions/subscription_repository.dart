import 'package:econoris_app/data/models/subscriptions/subscription_dto.dart';
import 'package:econoris_app/domain/models/subscriptions/subscription.dart';

/// Repository interface for subscriptions data.
abstract class SubscriptionRepository {
  Future<List<Subscription>> getSubscriptions();
  Future<Subscription> addSubscription(SubscriptionDto body);
  Future<Subscription> updateSubscription(int id, SubscriptionDto body);
  Future<Subscription> deleteSubscription(int id);
}
