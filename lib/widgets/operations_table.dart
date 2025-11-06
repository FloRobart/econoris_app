// Reusable operations table widget
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/operation.dart';

/// A configurable DataTable for a list of [Operation].
///
/// Parameters:
/// - operations: the full list of operations to display (caller may already slice/paginate)
/// - maxItems: optional maximum number of rows to show (if provided, takes first N)
/// - columns: ordered list of column ids to show. Supported ids: 'date','name','amount','validated','category','source','destination','id'
/// - onRowTap: optional callback when a row is tapped
class OperationsTable extends StatelessWidget {
  final List<Operation> operations;
  final int? maxItems;
  final List<String> columns;
  final void Function(Operation)? onRowTap;

  const OperationsTable({
    super.key,
    required this.operations,
    this.maxItems,
    this.columns = const ['date', 'name', 'amount', 'validated'],
    this.onRowTap,
  });

  List<DataColumn> _buildColumns(BuildContext context) {
    return columns.map((c) {
      switch (c) {
        case 'date':
          return const DataColumn(label: Text('Date'));
        case 'name':
          return const DataColumn(label: Text('Nom'));
        case 'amount':
          return const DataColumn(label: Text('Montant'), numeric: true);
        case 'validated':
          return const DataColumn(label: Text('Validé'));
        case 'category':
          return const DataColumn(label: Text('Catégorie'));
        case 'source':
          return const DataColumn(label: Text('Source'));
        case 'destination':
          return const DataColumn(label: Text('Destination'));
        case 'id':
          return const DataColumn(label: Text('ID'));
        default:
          return DataColumn(label: Text(c));
      }
    }).toList();
  }

  List<DataCell> _buildCells(Operation o) {
    final df = DateFormat('yyyy-MM-dd');
    return columns.map((c) {
      switch (c) {
        case 'date':
          return DataCell(Text(df.format(o.levyDate)), onTap: () => onRowTap?.call(o));
        case 'name':
          return DataCell(Text(o.label), onTap: () => onRowTap?.call(o));
        case 'amount':
          return DataCell(Text(o.amount.toStringAsFixed(2)), onTap: () => onRowTap?.call(o));
        case 'validated':
          return DataCell(Icon(o.isValidate ? Icons.check_circle : Icons.remove_circle), onTap: () => onRowTap?.call(o));
        case 'category':
          return DataCell(Text(o.category), onTap: () => onRowTap?.call(o));
        case 'source':
          return DataCell(Text(o.source ?? ''), onTap: () => onRowTap?.call(o));
        case 'destination':
          return DataCell(Text(o.destination ?? ''), onTap: () => onRowTap?.call(o));
        case 'id':
          return DataCell(Text(o.id.toString()), onTap: () => onRowTap?.call(o));
        default:
          return DataCell(Text(''), onTap: () => onRowTap?.call(o));
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = (maxItems != null) ? operations.take(maxItems!).toList() : operations;

    return DataTable(
      columns: _buildColumns(context),
      rows: items.map((o) => DataRow(cells: _buildCells(o))).toList(),
    );
  }
}
