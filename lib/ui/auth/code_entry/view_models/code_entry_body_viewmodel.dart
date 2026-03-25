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

  String code = "";

  Future<bool> verifyCode() async {
    try {
      final cleanedCode = code.trim().replaceAll(RegExp(r'\s+'), '');
      return await codeEntryUseCase.verifyCode(cleanedCode);
    } catch (e) {
      return false;
    }
  }
}
