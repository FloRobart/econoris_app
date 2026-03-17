import 'package:econoris_app/domain/models/operations/operation.dart';
import 'package:econoris_app/domain/use_cases/home/home_body_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider d'etat asynchrone pour les operations de l'ecran d'accueil.
final homeOperationsProvider =
    AsyncNotifierProvider<HomeOperationsViewModel, List<Operation>>(
      HomeOperationsViewModel.new,
    );

/// ViewModel pour l'ecran d'accueil.
class HomeOperationsViewModel extends AsyncNotifier<List<Operation>> {
  late final HomeBodyUseCase _useCase;

  @override
  Future<List<Operation>> build() async {
    _useCase = ref.read(homeBodyUseCaseProvider);
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
