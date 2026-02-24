import 'package:econoris_app/domain/use_cases/auth/login/login_usecase.dart';
import 'package:econoris_app/providers/data/repositories/auth/auth_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance de [LoginUseCase].
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return LoginUseCase(authRepository: authRepository);
});
