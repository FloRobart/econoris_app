import 'package:econoris_app/domain/models/users/user.dart';

class UserRepositoryLocal {
  UserRepositoryLocal();

  Future<User> getCurrentUser() async {
    return User(
      email: 'john.doe@example.com',
      pseudo: 'John Doe',
      isConnected: true,
      isVerifiedEmail: true,
      createdAt: DateTime.now(),
    );
  }

  Future<void> logout() async {
    // Simulate local logout (e.g., clearing local storage)
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
