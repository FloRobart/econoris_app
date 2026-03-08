import 'package:econoris_app/data/models/users/user_dto.dart';
import 'package:econoris_app/data/services/api/users/user_api_client.dart';

class UserRepositoryRemote {
  UserRepositoryRemote({required this.userApiClient});

  final UserApiClient userApiClient;

  Future<UserDto> getCurrentUser() async {
    final userData = await userApiClient.getCurrentUser();
    return UserDto.fromJson(userData);
  }

  Future<void> logoutAll() async {
    return await userApiClient.logoutAll();
  }
}
