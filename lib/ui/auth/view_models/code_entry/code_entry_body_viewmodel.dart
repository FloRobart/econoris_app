import 'package:econoris_app/domain/use_cases/auth/login/login_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance de [CodeEntryBodyViewModel].
final codeEntryBodyViewModelProvider = Provider<CodeEntryBodyViewModel>((ref) {
  return CodeEntryBodyViewModel(
    authScreenUseCase: ref.read(loginUseCaseProvider),
  );
});

class CodeEntryBodyViewModel {
  CodeEntryBodyViewModel({required this.authScreenUseCase});

  final LoginUseCase authScreenUseCase;

  String code = "0";

  Future<bool> verifyCode() async {
    try {
      await authScreenUseCase.verifyCode(code);
      return true;
    } catch (e) {
      return false;
    }
  }
}
