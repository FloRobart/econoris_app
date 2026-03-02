import 'package:econoris_app/data/repositories/operations/operation_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance de [HomeScreenUseCase].
final homeScreenUseCaseProvider = Provider<HomeScreenUseCase>((ref) {
  final operationRepository = ref.read(operationRepositoryProvider);
  return HomeScreenUseCase(operationRepository: operationRepository);
});

/// Use case class for the home screen
class HomeScreenUseCase {
  HomeScreenUseCase({required this.operationRepository});

  final OperationRepository operationRepository;
}
