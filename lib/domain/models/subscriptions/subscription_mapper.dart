import 'package:econoris_app/data/models/subscriptions/subscription_dto.dart';
import 'package:econoris_app/domain/models/subscriptions/subscription.dart';

extension SubscriptionMapper on Subscription {
  SubscriptionDto toDto() {
    return SubscriptionDto(
      id: id,
      label: label,
      amount: amount,
      category: category,
      source: source,
      destination: destination,
      costs: costs,
      active: active,
      intervalValue: intervalValue,
      intervalUnit: intervalUnit,
      startDate: startDate,
      endDate: endDate,
      dayOfMonth: dayOfMonth,
      lastGeneratedAt: lastGeneratedAt,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
