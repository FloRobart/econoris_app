import 'package:econoris_app/domain/models/operations/operation.dart';
import 'package:econoris_app/domain/use_cases/operations/operation_body_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider d'etat asynchrone pour les operations de l'ecran d'accueil.
final homeBodyViewModelProvider =
    AsyncNotifierProvider<HomeBodyViewModel, List<Operation>>(
      HomeBodyViewModel.new,
    );

/// ViewModel pour l'ecran d'accueil.
class HomeBodyViewModel extends AsyncNotifier<List<Operation>> {
  late final OperationBodyUseCase _useCase;

  @override
  Future<List<Operation>> build() async {
    _useCase = ref.read(operationBodyUseCaseProvider);
    return _useCase.getOperations();
  }

  /// Recharge la liste complete depuis la source de donnees.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _useCase.getOperations());
  }

  /// Cree une operation cote serveur puis met a jour l'etat local.
  Future<void> addOperation(Operation body) async {
    final createdOperation = await _useCase.addOperation(body);
    final currentOperations = switch (state) {
      AsyncData<List<Operation>>(:final value) => value,
      _ => <Operation>[],
    };
    state = AsyncData([...currentOperations, createdOperation]);
  }
}
