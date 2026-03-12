import 'package:econoris_app/data/repositories/operations/operation_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// Fournit une instance de [OperationBodyUseCase].
final operationBodyUseCaseProvider = Provider<OperationBodyUseCase>((ref) {
  final operationRepository = ref.read(operationRepositoryProvider);
  return OperationBodyUseCase(operationRepository: operationRepository);
});

/// Use case class for the operation screen
class OperationBodyUseCase {
  OperationBodyUseCase({required this.operationRepository});

  final OperationRepository operationRepository;
}
