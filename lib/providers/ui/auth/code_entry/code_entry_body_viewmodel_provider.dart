import 'package:econoris_app/providers/domains/use_cases/auth/login/login_usecase_provider.dart';
import 'package:econoris_app/ui/auth/view_models/code_entry/code_entry_body_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance de [CodeEntryBodyViewModel].
final codeEntryBodyViewModelProvider = Provider<CodeEntryBodyViewModel>((ref) {
  return CodeEntryBodyViewModel(
    authScreenUseCase: ref.read(loginUseCaseProvider),
  );
});