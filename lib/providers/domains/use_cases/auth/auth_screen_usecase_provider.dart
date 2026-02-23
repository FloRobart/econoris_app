import 'package:econoris_app/domain/use_cases/auth/auth_screen_usecase.dart';
import 'package:econoris_app/providers/data/repositories/auth/auth_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance de [AuthScreenUseCase].
final authScreenUseCaseProvider = Provider<AuthScreenUseCase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return AuthScreenUseCase(authRepository: authRepository);
});
