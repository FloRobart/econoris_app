import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_dto.freezed.dart';
part 'profile_dto.g.dart';

@freezed
abstract class ProfileDto with _$ProfileDto {
  const factory ProfileDto({
    required int id,
    required String email,
    required String pseudo,
    @JsonKey(name: 'auth_methods_id') required int authMethodsId,
    @JsonKey(name: 'is_connected') required bool isConnected,
    @JsonKey(name: 'is_verified_email') required bool isVerifiedEmail,
    @JsonKey(name: 'last_logout_at') required String lastLogoutAt,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _ProfileDto;

  factory ProfileDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileDtoFromJson(json);
}
