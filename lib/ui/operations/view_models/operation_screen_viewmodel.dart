import 'package:econoris_app/domain/use_cases/operations/operation_screen_usecase.dart';
import 'package:flutter/foundation.dart';


class OperationScreenViewModel extends ChangeNotifier {
  OperationScreenViewModel({required this.operationScreenUseCase});

  final OperationScreenUseCase operationScreenUseCase;
}
