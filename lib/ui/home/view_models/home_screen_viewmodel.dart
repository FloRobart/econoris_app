import 'package:econoris_app/domain/use_cases/home/home_screen_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// Fournit une instance de [HomeScreenViewModel].
final homeScreenViewModelProvider = Provider<HomeScreenViewModel>((ref) {
  final homeScreenUseCase = ref.read(homeScreenUseCaseProvider);
  return HomeScreenViewModel(homeScreenUseCase: homeScreenUseCase);
});

/// ViewModel pour l'écran d'accueil, gérant la logique métier et les interactions avec les cas d'utilisation.
class HomeScreenViewModel extends ChangeNotifier {
  HomeScreenViewModel({required this.homeScreenUseCase});

  final HomeScreenUseCase homeScreenUseCase;
}