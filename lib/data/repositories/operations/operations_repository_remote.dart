import 'package:econoris_app/data/models/operations/operation_dto.dart';
import 'package:econoris_app/data/services/api/operations_api_client.dart';

/// Repository interface for operations data.
class OperationsRepositoryRemote {
  /// Fetches a list of operations from the remote API.
  Future<List<OperationDto>> getOperations() async {
    final operationsDtoList = await OperationsApiClient.getOperations();
    return operationsDtoList.map((operation) => OperationDto.fromJson(operation)).toList();
  }

  /// Adds a new operation to the remote API.
  Future<OperationDto> addOperation(OperationDto body) async {
    final operation = await OperationsApiClient.addOperation(body.toJson());
    return OperationDto.fromJson(operation);
  }

  /// Updates an existing operation in the remote API.
  Future<OperationDto> updateOperation(int id, OperationDto body) async {
    final operation = await OperationsApiClient.updateOperation(id, body.toJson());
    return OperationDto.fromJson(operation);
  }

  /// Deletes an operation from the remote API.
  Future<OperationDto> deleteOperation(int id) async {
    final operation = await OperationsApiClient.deleteOperation(id);
    return OperationDto.fromJson(operation);
  }
}
