import 'package:econoris_app/domain/models/subscriptions/subscription.dart';

class SubscriptionBodyViewmodel {
  SubscriptionBodyViewmodel(List<Subscription> subscriptions)
    : _subscriptions = subscriptions;

  /* Attributes */
  final List<Subscription> _subscriptions;

  /* Variables */
  List<Subscription>? _sortedSubscriptions;

  /* Getters */
  List<Subscription> get sortedSubscriptions =>
      _sortedSubscriptions ??= _subscriptions
        ..sort((a, b) => b.startDate.compareTo(a.startDate));
}
