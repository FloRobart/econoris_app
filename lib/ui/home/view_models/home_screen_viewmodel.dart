import 'package:econoris_app/domain/use_cases/home/home_screen_usecase.dart';
import 'package:flutter/foundation.dart';


class HomeScreenViewModel extends ChangeNotifier {
  HomeScreenViewModel({required this.homeScreenUseCase});

  final HomeScreenUseCase homeScreenUseCase;
}