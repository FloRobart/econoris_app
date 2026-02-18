import 'package:econoris_app/data/models/operations/operation_dto.dart';
import 'package:econoris_app/data/models/operations/operation_dto_mapper.dart';
import 'package:econoris_app/data/repositories/operations/operations_repository.dart';
import 'package:econoris_app/data/repositories/operations/operations_repository_local.dart';
import 'package:econoris_app/data/repositories/operations/operations_repository_remote.dart';
import 'package:econoris_app/domain/models/operations/operation.dart';

/// Repository interface for operations data.
class OperationsRepositoryImpl implements OperationsRepository {
  /// Fetches a list of operations from the remote API.
  @override
  Future<List<Operation>> getOperations() async {
    List<OperationDto> operationsDtoList = [];
    try {
      operationsDtoList = await OperationsRepositoryRemote().getOperations();
      OperationsRepositoryLocal().saveOperations(operationsDtoList);
    } catch (e) {
      operationsDtoList = await OperationsRepositoryLocal().getOperations();
    }

    return operationsDtoList
        .map((operationDto) => operationDto.toDomain())
        .toList();
  }

  /// Adds a new operation to the remote API.
  @override
  Future<Operation> addOperation(OperationDto body) async {
    try {
      final operationDto = await OperationsRepositoryRemote().addOperation(body);
      OperationsRepositoryLocal().saveOperations([operationDto]);
      return operationDto.toDomain();
    } catch (e) {
      print('Error adding operation: $e');
      rethrow;
    }
  }

  /// Updates an existing operation in the remote API.
  @override
  Future<Operation> updateOperation(int id, OperationDto body) async {
    final operationDto = await OperationsRepositoryRemote().updateOperation(
      id,
      body,
    );
    OperationsRepositoryLocal().updateOperation(id, operationDto);
    return operationDto.toDomain();
  }

  /// Deletes an operation from the remote API.
  @override
  Future<Operation> deleteOperation(int id) async {
    final operationDto = await OperationsRepositoryRemote().deleteOperation(id);
    OperationsRepositoryLocal().deleteOperation(id);
    return operationDto.toDomain();
  }
}
