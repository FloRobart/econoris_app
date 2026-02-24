import 'package:econoris_app/providers/domains/use_cases/auth/login/login_usecase_provider.dart';
import 'package:econoris_app/ui/auth/view_models/login/login_body_viewmodel.dart';
import 'package:econoris_app/data/services/auth/auth_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance de [LoginBodyViewModel].
final loginBodyViewModelProvider = Provider<LoginBodyViewModel>((ref) {
  return LoginBodyViewModel(
    authScreenUseCase: ref.read(loginUseCaseProvider),
  );
});

/// Fournit l'email par défaut pour l'écran d'authentification.
final authInitialEmailProvider = FutureProvider<String?>((ref) async {
  final viewModel = ref.read(loginBodyViewModelProvider);
  return viewModel.getEmail;
});

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);