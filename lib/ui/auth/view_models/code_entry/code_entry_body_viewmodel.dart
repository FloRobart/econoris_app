import 'package:econoris_app/domain/use_cases/auth/login/login_usecase.dart';

class CodeEntryBodyViewModel {
  CodeEntryBodyViewModel({required this.authScreenUseCase});

  final LoginUseCase authScreenUseCase;

  String code = "0";

  Future<bool> verifyCode() async {
    try {
      // await authScreenUseCase.verifyCode(email, code);
      return true;
    } catch (e) {
      return false;
    }
  }
}
