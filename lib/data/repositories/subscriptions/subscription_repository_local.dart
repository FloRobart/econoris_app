import 'dart:convert';
import 'package:econoris_app/config/shared_preferences_keys.dart';
import 'package:econoris_app/data/models/subscriptions/subscription_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository interface for subscriptions data stored locally.
class SubscriptionRepositoryLocal {
  static final String _subscriptionsKey = SharedPreferencesKeys.subscriptions;

  /// Fetches a list of subscriptions from the local storage.
  Future<List<SubscriptionDto>> getSubscriptions() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final subscriptionsJson = sharedPreferences.getString(_subscriptionsKey);

    if (subscriptionsJson == null) {
      return [];
    }

    final subscriptionsList = (jsonDecode(subscriptionsJson) as List<dynamic>);
    return subscriptionsList.map((subscriptionJson) => SubscriptionDto.fromJson(subscriptionJson)).toList();
  }

  /// Adds a new subscription to the local storage.
  Future<SubscriptionDto> addSubscription(SubscriptionDto body) async {
    final subscriptionsList = await getSubscriptions();

    /* Add the new subscription to the list */
    subscriptionsList.add(body);

    /* Save the updated list back to local storage */
    await saveSubscriptions(subscriptionsList);

    return body;
  }

  /// Updates an existing subscription in the local storage.
  Future<SubscriptionDto> updateSubscription(int id, SubscriptionDto body) async {
    final subscriptionsList = await getSubscriptions();

    /* Remove the old subscription from the list and add the updated one */
    subscriptionsList.removeWhere((subscription) => subscription.id == id);
    subscriptionsList.add(body);

    /* Save the updated list back to local storage */
    await saveSubscriptions(subscriptionsList);

    return body;
  }

  /// Deletes an subscription from the local storage.
  Future<SubscriptionDto> deleteSubscription(int id) async {
    final subscriptionsList = await getSubscriptions();

    /* Find the subscription to delete before removing it from the list */
    final subscriptionToDelete = subscriptionsList.firstWhere((subscription) => subscription.id == id);
    subscriptionsList.removeWhere((subscription) => subscription.id == id);

    /* Save the updated list back to local storage */
    await saveSubscriptions(subscriptionsList);

    return subscriptionToDelete;
  }

  /// Saves the list of subscriptions to local storage.
  Future<void> saveSubscriptions(List<SubscriptionDto> subscriptions) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final subscriptionsJson = jsonEncode(subscriptions.map((subscription) => subscription.toJson()).toList());
    await sharedPreferences.setString(_subscriptionsKey, subscriptionsJson);
  }
}
