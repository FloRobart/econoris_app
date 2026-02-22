import 'package:econoris_app/data/models/operations/operation_dto.dart';
import 'package:econoris_app/domain/models/operations/operation.dart';

/// Repository interface for operations data.
abstract class OperationRepository {
  Future<List<Operation>> getOperations();
  Future<Operation> addOperation(OperationDto body);
  Future<Operation> updateOperation(int id, OperationDto body);
  Future<Operation> deleteOperation(int id);
}
