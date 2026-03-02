import 'package:econoris_app/data/repositories/operations/operation_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// Fournit une instance de [OperationScreenUseCase].
final operationScreenUseCaseProvider = Provider<OperationScreenUseCase>((ref) {
  final operationRepository = ref.read(operationRepositoryProvider);
  return OperationScreenUseCase(operationRepository: operationRepository);
});

/// Use case class for the operation screen
class OperationScreenUseCase {
  OperationScreenUseCase({required this.operationRepository});

  final OperationRepository operationRepository;
}
