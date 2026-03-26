// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_create_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubscriptionCreateDto _$SubscriptionCreateDtoFromJson(
  Map<String, dynamic> json,
) => _SubscriptionCreateDto(
  startDate: json['start_date'] as String,
  label: json['label'] as String,
  amount: (json['amount'] as num).toDouble(),
  category: json['category'] as String,
  active: json['active'] as bool,
  intervalValue: (json['interval_value'] as num).toInt(),
  intervalUnit: json['interval_unit'] as String,
  dayOfMonth: (json['day_of_month'] as num).toInt(),
);

Map<String, dynamic> _$SubscriptionCreateDtoToJson(
  _SubscriptionCreateDto instance,
) => <String, dynamic>{
  'start_date': instance.startDate,
  'label': instance.label,
  'amount': instance.amount,
  'category': instance.category,
  'active': instance.active,
  'interval_value': instance.intervalValue,
  'interval_unit': instance.intervalUnit,
  'day_of_month': instance.dayOfMonth,
};
