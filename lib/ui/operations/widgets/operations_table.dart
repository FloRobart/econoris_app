import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/operations/operation.dart';

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
          return const DataColumn(
            label: Tooltip(message: 'Prélevé', child: Text('P')),
          );
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

  List<DataCell> _buildCells(Operation o, double colMaxWidth) {
    final df = DateFormat('dd-MM-yyyy');
    Widget truncated(String text, {TextStyle? style}) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: colMaxWidth),
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          softWrap: false,
          style: style,
        ),
      );
    }

    return columns.map((c) {
      switch (c) {
        case 'date':
          return DataCell(
            truncated(df.format(o.levyDate)),
            onTap: () => onRowTap?.call(o),
          );
        case 'name':
          return DataCell(truncated(o.label), onTap: () => onRowTap?.call(o));
        case 'amount':
          Color? amountColor = o.amount > 0
              ? Colors.green
              : (o.amount < 0 ? Colors.red : null);
          return DataCell(
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: colMaxWidth),
              child: Text(
                o.amount.toStringAsFixed(2),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: false,
                style: amountColor != null
                    ? TextStyle(color: amountColor)
                    : null,
              ),
            ),
            onTap: () => onRowTap?.call(o),
          );
        case 'validated':
          return DataCell(
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: colMaxWidth),
              child: Icon(
                o.isValidate ? Icons.check_circle : Icons.remove_circle,
                color: o.isValidate ? Colors.green : Colors.blue,
              ),
            ),
            onTap: () => onRowTap?.call(o),
          );
        case 'category':
          return DataCell(
            truncated(o.category),
            onTap: () => onRowTap?.call(o),
          );
        case 'source':
          return DataCell(
            truncated(o.source ?? ''),
            onTap: () => onRowTap?.call(o),
          );
        case 'destination':
          return DataCell(
            truncated(o.destination ?? ''),
            onTap: () => onRowTap?.call(o),
          );
        case 'id':
          return DataCell(
            truncated(o.id.toString()),
            onTap: () => onRowTap?.call(o),
          );
        default:
          return DataCell(const Text(''), onTap: () => onRowTap?.call(o));
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = (maxItems != null)
        ? operations.take(maxItems!).toList()
        : operations;

    return LayoutBuilder(
      builder: (context, constraints) {
        // If inside a horizontal scroll view, constraints.maxWidth can be infinite.
        final double availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        // Reserve some space for margins and column spacing, then divide among columns.
        final double reserved = 40.0 + (columns.length - 1) * 20.0;
        final double rawColWidth = (availableWidth - reserved) / columns.length;
        final double colMaxWidth = rawColWidth.clamp(120, 1800);

        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: availableWidth),
          child: DataTable(
            columns: _buildColumns(context),
            rows: items
                .map((o) => DataRow(cells: _buildCells(o, colMaxWidth)))
                .toList(),
            columnSpacing: 20,
            horizontalMargin: 10,
          ),
        );
      },
    );
  }
}
