import 'package:econoris_app/providers/domains/use_cases/operations/operation_screen_usecase_provider.dart';
import 'package:econoris_app/ui/operations/view_models/operation_screen_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance de [OperationScreenViewModel].
final operationScreenViewModelProvider = Provider<OperationScreenViewModel>((ref) {
  final operationScreenUseCase = ref.read(operationScreenUseCaseProvider);
  return OperationScreenViewModel(operationScreenUseCase: operationScreenUseCase);
});
