import 'package:econoris_app/data/models/subscriptions/subscription_dto.dart';
import 'package:econoris_app/domain/models/subscriptions/subscription.dart';

extension SubscriptionDtoMapper on SubscriptionDto {
  Subscription toDomain() {
    return Subscription(
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
      startDate: DateTime.parse(startDate),
      endDate: endDate != null ? DateTime.parse(endDate!) : null,
      dayOfMonth: dayOfMonth,
      lastGeneratedAt: lastGeneratedAt != null ? DateTime.parse(lastGeneratedAt!) : null,
      userId: userId,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}
