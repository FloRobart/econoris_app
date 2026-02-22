import 'package:econoris_app/domain/use_cases/home/home_screen_usecase.dart';
import 'package:econoris_app/providers/data/repositories/operations/operation_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance de [HomeScreenUseCase].
final homeScreenUseCaseProvider = Provider<HomeScreenUseCase>((ref) {
  final operationRepository = ref.read(operationRepositoryProvider);
  return HomeScreenUseCase(operationRepository: operationRepository);
});
