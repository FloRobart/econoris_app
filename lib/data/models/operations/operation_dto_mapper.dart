import 'package:econoris_app/data/models/operations/operation_dto.dart';
import 'package:econoris_app/domain/models/operations/operation.dart';

extension OperationDtoMapper on OperationDto {
  Operation toDomain() {
    return Operation(
      id: id,
      levyDate: levyDate,
      label: label,
      amount: amount,
      category: category,
      source: source,
      destination: destination,
      costs: costs,
      isValidate: isValidate,
      userId: userId,
      subscriptionId: subscriptionId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
