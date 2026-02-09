// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProfileDto _$ProfileDtoFromJson(Map<String, dynamic> json) => _ProfileDto(
  id: (json['id'] as num).toInt(),
  email: json['email'] as String,
  pseudo: json['pseudo'] as String,
  authMethodsId: (json['auth_methods_id'] as num).toInt(),
  isConnected: json['is_connected'] as bool,
  isVerifiedEmail: json['is_verified_email'] as bool,
  lastLogoutAt: json['last_logout_at'] as String,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$ProfileDtoToJson(_ProfileDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'pseudo': instance.pseudo,
      'auth_methods_id': instance.authMethodsId,
      'is_connected': instance.isConnected,
      'is_verified_email': instance.isVerifiedEmail,
      'last_logout_at': instance.lastLogoutAt,
      'created_at': instance.createdAt,
    };
