import 'package:econoris_app/providers/domains/use_cases/auth/auth_screen_usecase_provider.dart';
import 'package:econoris_app/ui/auth/view_models/auth_screen_viewmodel.dart';
import 'package:econoris_app/ui/auth/widgets/auth_screen_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance de [AuthScreenViewModel].
final authScreenViewModelProvider = Provider<AuthScreenViewModel>((ref) {
  return AuthScreenViewModel(
    authScreenUseCase: ref.read(authScreenUseCaseProvider),
  );
});

/// Fournit l'email par défaut pour l'écran d'authentification.
final authInitialEmailProvider = FutureProvider<String?>((ref) async {
  final viewModel = ref.read(authScreenViewModelProvider);
  return viewModel.getEmail;
});

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);