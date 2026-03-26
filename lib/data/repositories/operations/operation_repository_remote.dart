import 'package:econoris_app/data/models/operations/create/operation_create_dto.dart';
import 'package:econoris_app/data/models/operations/operation_dto.dart';
import 'package:econoris_app/data/services/api/operations/operation_api_client.dart';

/// Repository interface for operations data.
class OperationRepositoryRemote {
  const OperationRepositoryRemote({required this.operationApiClient});

  final OperationApiClient operationApiClient;

  /// Fetches a list of operations from the remote API.
  Future<List<OperationDto>> getOperations() async {
    final operationsDtoList = await operationApiClient.getOperations();
    return operationsDtoList
        .map((operation) => OperationDto.fromJson(operation))
        .toList();
  }

  /// Adds a new operation to the remote API.
  Future<OperationDto> addOperation(OperationCreateDto body) async {
    final operation = await operationApiClient.addOperation(body.toJson());
    return OperationDto.fromJson(operation);
  }

  /// Updates an existing operation in the remote API.
  Future<OperationDto> updateOperation(int id, OperationDto body) async {
    final operation = await operationApiClient.updateOperation(
      id,
      body.toJson(),
    );
    return OperationDto.fromJson(operation);
  }

  /// Deletes an operation from the remote API.
  Future<OperationDto> deleteOperation(int id) async {
    final operation = await operationApiClient.deleteOperation(id);
    return OperationDto.fromJson(operation);
  }
}
