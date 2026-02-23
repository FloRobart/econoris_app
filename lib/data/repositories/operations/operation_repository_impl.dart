import 'package:econoris_app/data/models/operations/operation_dto.dart';
import 'package:econoris_app/data/models/operations/operation_dto_mapper.dart';
import 'package:econoris_app/data/repositories/operations/operation_repository.dart';
import 'package:econoris_app/data/repositories/operations/operation_repository_local.dart';
import 'package:econoris_app/data/repositories/operations/operation_repository_remote.dart';
import 'package:econoris_app/domain/models/operations/operation.dart';

/// Repository interface for operations data.
class OperationRepositoryImpl implements OperationRepository {
  final OperationRepositoryRemote remote;
  final OperationRepositoryLocal local;

  OperationRepositoryImpl({required this.remote, required this.local});

  /// Fetches a list of operations from the remote API.
  @override
  Future<List<Operation>> getOperations() async {
    List<OperationDto> operationsDtoList = [];
    try {
      operationsDtoList = await remote.getOperations();
      local.saveOperations(operationsDtoList);
    } catch (e) {
      operationsDtoList = await local.getOperations();
    }

    return operationsDtoList
        .map((operationDto) => operationDto.toDomain())
        .toList();
  }

  /// Adds a new operation to the remote API.
  @override
  Future<Operation> addOperation(OperationDto body) async {
    try {
      final operationDto = await remote.addOperation(body);
      local.saveOperations([operationDto]);
      return operationDto.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  /// Updates an existing operation in the remote API.
  @override
  Future<Operation> updateOperation(int id, OperationDto body) async {
    final operationDto = await remote.updateOperation(
      id,
      body,
    );
    local.updateOperation(id, operationDto);
    return operationDto.toDomain();
  }

  /// Deletes an operation from the remote API.
  @override
  Future<Operation> deleteOperation(int id) async {
    final operationDto = await remote.deleteOperation(id);
    local.deleteOperation(id);
    return operationDto.toDomain();
  }
}
