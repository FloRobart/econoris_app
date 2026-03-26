import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_create.freezed.dart';

@freezed
abstract class SubscriptionCreate with _$SubscriptionCreate {
  const factory SubscriptionCreate({
    @JsonKey(name: 'start_date') required DateTime startDate,
    required String label,
    required double amount,
    required String category,
    required String recurrence,
    @Default(true) bool active,
  }) = _SubscriptionCreate;
}
