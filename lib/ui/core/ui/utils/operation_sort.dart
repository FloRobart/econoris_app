import 'package:econoris_app/domain/models/operations/operation.dart';

int operationSort(Operation a, Operation b) {
  int compare = b.levyDate.compareTo(a.levyDate);
  if (compare == 0) {
    compare = b.id.compareTo(a.id);
  }

  return compare;
}