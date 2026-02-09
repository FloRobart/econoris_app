import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

@freezed
sealed class LoginState with _$LoginState {
  const factory LoginState.loading() = LoginLoading;

  const factory LoginState.enterEmail({
    String? email,
  }) = LoginEnterEmail;

  const factory LoginState.enterEmailAndName({
    String? email,
  }) = LoginEnterEmailAndName;

  const factory LoginState.submitting({
    required bool requireName,
    String? email,
  }) = LoginSubmitting;

  const factory LoginState.enterOtp({
    required String email,
  }) = LoginEnterOtp;

  const factory LoginState.error({
    required String message,
  }) = LoginError;
}
