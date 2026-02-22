import 'package:econoris_app/data/repositories/operations/operation_repository.dart';

class HomeScreenUseCase {
  HomeScreenUseCase({required this.operationRepository});

  final OperationRepository operationRepository;
}