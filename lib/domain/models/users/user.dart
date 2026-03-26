import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String email,
    required String pseudo,
    required bool isConnected,
    required bool isVerifiedEmail,
    required DateTime createdAt,
  }) = _User;
}
