import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';

@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required String email,
    required String pseudo,
    required bool isConnected,
    required bool isVerifiedEmail,
    required String createdAt,
  }) = _Profile;
}
