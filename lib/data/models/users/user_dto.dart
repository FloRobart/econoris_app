import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

@freezed
abstract class UserDto with _$UserDto {
  const factory UserDto({
    required int id,
    required String email,
    required String pseudo,
    @JsonKey(name: 'auth_methods_id') required int authMethodsId,
    @JsonKey(name: 'is_connected') required bool isConnected,
    @JsonKey(name: 'is_verified_email') required bool isVerifiedEmail,
    @JsonKey(name: 'last_logout_at') required String lastLogoutAt,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
}