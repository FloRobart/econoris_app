import 'package:econoris_app/providers/domains/use_cases/home/home_screen_usecase_provider.dart';
import 'package:econoris_app/ui/home/view_models/home_screen_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance de [HomeScreenViewModel].
final homeScreenViewModelProvider = Provider<HomeScreenViewModel>((ref) {
  final homeScreenUseCase = ref.read(homeScreenUseCaseProvider);
  return HomeScreenViewModel(homeScreenUseCase: homeScreenUseCase);
});
