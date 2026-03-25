import 'package:econoris_app/data/repositories/operations/operation_repository.dart';
import 'package:econoris_app/domain/models/operations/create/operation_create.dart';
import 'package:econoris_app/domain/models/operations/operation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance de [OperationUseCase].
final operationUseCaseProvider = Provider<OperationUseCase>((ref) {
  final operationRepository = ref.read(operationRepositoryProvider);

  return OperationUseCase(
    operationRepository: operationRepository,
  );
});

/// Use case class for the home screen
class OperationUseCase {
  OperationUseCase({
    required this.operationRepository,
  });

  final OperationRepository operationRepository;

  /*=====*/
  /* GET */
  /*=====*/
  /// Fetches a list of operations from the repository.
  Future<List<Operation>> getOperations() {
    return operationRepository.getOperations();
  }

  /*======*/
  /* POST */
  /*======*/
  Future<Operation> addOperation(OperationCreate body) {
    return operationRepository.addOperation(body);
  }

  /*=====*/
  /* PUT */
  /*=====*/
  // Future<Operation> updateOperation(int id, Operation body) {
  //   return operationRepository.updateOperation(id, body);
  // }

  /*========*/
  /* DELETE */
  /*========*/
}
