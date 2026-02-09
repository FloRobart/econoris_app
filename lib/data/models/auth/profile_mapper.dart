// data/models/auth/profile_mapper.dart
import 'package:econoris_app/data/models/auth/profile_dto.dart';
import 'package:econoris_app/domain/models/auth/profile.dart';

extension ProfileDtoMapper on ProfileDto {
  Profile toDomain() {
    return Profile(
      email: email,
      pseudo: pseudo,
      isConnected: isConnected,
      isVerifiedEmail: isVerifiedEmail,
      createdAt: createdAt,
    );
  }
}
