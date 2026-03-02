import 'package:econoris_app/domain/use_cases/operations/operation_screen_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// Fournit une instance de [OperationScreenViewModel].
final operationScreenViewModelProvider = Provider<OperationScreenViewModel>((ref) {
  final operationScreenUseCase = ref.read(operationScreenUseCaseProvider);
  return OperationScreenViewModel(operationScreenUseCase: operationScreenUseCase);
});

/// ViewModel pour l'écran d'opérations, gérant la logique métier et les interactions avec les cas d'utilisation.
class OperationScreenViewModel extends ChangeNotifier {
  OperationScreenViewModel({required this.operationScreenUseCase});

  final OperationScreenUseCase operationScreenUseCase;
}
