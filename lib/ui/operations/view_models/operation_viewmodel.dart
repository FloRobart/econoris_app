import 'package:econoris_app/domain/models/operations/create/operation_create.dart';
import 'package:econoris_app/domain/models/operations/operation.dart';
import 'package:econoris_app/domain/use_cases/operations/operation_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider d'etat asynchrone pour les operations de l'ecran d'accueil.
final operationViewModelProvider =
    AsyncNotifierProvider<OperationViewModel, List<Operation>>(
      OperationViewModel.new,
    );

/// ViewModel pour l'ecran d'accueil.
class OperationViewModel extends AsyncNotifier<List<Operation>> {
  late final OperationUseCase _useCase;

  @override
  Future<List<Operation>> build() async {
    _useCase = ref.read(operationUseCaseProvider);
    return _useCase.getOperations();
  }

  /// Recharge la liste complete depuis la source de donnees.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _useCase.getOperations());
  }

  /// Cree une operation cote serveur puis met a jour l'etat local.
  Future<void> addOperation(OperationCreate body) async {
    final createdOperation = await _useCase.addOperation(body);
    final currentOperations = switch (state) {
      AsyncData<List<Operation>>(:final value) => value,
      _ => <Operation>[],
    };
    state = AsyncData([...currentOperations, createdOperation]);
  }

  /// Supprime une operation cote serveur puis met a jour l'etat local.
  Future<void> deleteOperation(int id) async {
    await _useCase.deleteOperation(id);
    final currentOperations = switch (state) {
      AsyncData<List<Operation>>(:final value) => value,
      _ => <Operation>[],
    };

    state = AsyncData(
      currentOperations.where((operation) => operation.id != id).toList(),
    );
  }
}
