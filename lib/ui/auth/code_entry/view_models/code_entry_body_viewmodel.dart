import 'package:econoris_app/domain/use_cases/auth/code_entry/code_entry_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance de [CodeEntryBodyViewModel].
final codeEntryBodyViewModelProvider = Provider<CodeEntryBodyViewModel>((ref) {
  return CodeEntryBodyViewModel(
    codeEntryUseCase: ref.read(codeEntryUseCaseProvider),
  );
});

class CodeEntryBodyViewModel {
  CodeEntryBodyViewModel({
    required this.codeEntryUseCase,
  });

  final CodeEntryUseCase codeEntryUseCase;

  String code = "0";

  Future<bool> verifyCode() async {
    try {
      return await codeEntryUseCase.verifyCode(code);
    } catch (e) {
      return false;
    }
  }
}
