import 'package:econoris_app/data/models/auth/user/user_dto.dart';
import 'package:econoris_app/domain/models/auth/user/user.dart';

extension UserDtoMapper on UserDto {
  User toDomain() {
    return User(
      email: email,
      pseudo: pseudo,
      isConnected: isConnected,
      isVerifiedEmail: isVerifiedEmail,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
