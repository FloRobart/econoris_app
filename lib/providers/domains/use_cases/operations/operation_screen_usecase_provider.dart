import 'package:econoris_app/domain/use_cases/operations/operation_screen_usecase.dart';
import 'package:econoris_app/providers/data/repositories/operations/operation_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance de [OperationScreenUseCase].
final operationScreenUseCaseProvider = Provider<OperationScreenUseCase>((ref) {
  final operationRepository = ref.read(operationRepositoryProvider);
  return OperationScreenUseCase(operationRepository: operationRepository);
});
