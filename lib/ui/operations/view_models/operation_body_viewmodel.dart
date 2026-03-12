import 'package:econoris_app/domain/use_cases/operations/operation_screen_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// Fournit une instance de [OperationBodyViewModel].
final operationBodyViewModelProvider = Provider<OperationBodyViewModel>((ref) {
  final operationScreenUseCase = ref.read(operationBodyUseCaseProvider);
  return OperationBodyViewModel(operationScreenUseCase: operationScreenUseCase);
});

/// ViewModel pour l'écran d'opérations, gérant la logique métier et les interactions avec les cas d'utilisation.
class OperationBodyViewModel extends ChangeNotifier {
  OperationBodyViewModel({required this.operationScreenUseCase});

  final OperationBodyUseCase operationScreenUseCase;
}
