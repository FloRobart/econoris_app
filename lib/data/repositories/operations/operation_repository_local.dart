import 'dart:convert';
import 'package:econoris_app/config/shared_preferences_keys.dart';
import 'package:econoris_app/data/models/operations/operation_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository interface for operations data stored locally.
class OperationRepositoryLocal {
  static final String _operationsKey = SharedPreferencesKeys.operations;

  /// Fetches a list of operations from the local storage.
  Future<List<OperationDto>> getOperations() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final operationsJson = sharedPreferences.getString(_operationsKey);

    if (operationsJson == null) {
      return [];
    }

    final operationsList = (jsonDecode(operationsJson) as List<dynamic>);
    return operationsList
        .map((operationJson) => OperationDto.fromJson(operationJson))
        .toList();
  }

  /// Adds a new operation to the local storage.
  Future<OperationDto> addOperation(OperationDto body) async {
    final operationsList = await getOperations();

    /* Add the new operation to the list */
    operationsList.add(body);

    /* Save the updated list back to local storage */
    await saveOperations(operationsList);

    return body;
  }

  /// Updates an existing operation in the local storage.
  Future<OperationDto?> updateOperation(int id, OperationDto body) async {
    try {
      final operationsList = await getOperations();

      /* Remove the old operation from the list and add the updated one */
      operationsList.removeWhere((operation) => operation.id == id);
      operationsList.add(body);

      /* Save the updated list back to local storage */
      await saveOperations(operationsList);

      return body;
    } catch (_) {
      return null;
    }
  }

  /// Deletes an operation from the local storage.
  Future<OperationDto?> deleteOperation(int id) async {
    try {
      final operationsList = await getOperations();

      /* Find the operation to delete before removing it from the list */
      final operationToDelete = operationsList.firstWhere(
        (operation) => operation.id == id,
      );
      operationsList.removeWhere((operation) => operation.id == id);

      /* Save the updated list back to local storage */
      await saveOperations(operationsList);

      return operationToDelete;
    } catch (_) {
      return null;
    }
  }

  /// Saves the list of operations to local storage.
  Future<void> saveOperations(List<OperationDto> operations) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final operationsJson = jsonEncode(
      operations.map((operation) => operation.toJson()).toList(),
    );
    await sharedPreferences.setString(_operationsKey, operationsJson);
  }
}
