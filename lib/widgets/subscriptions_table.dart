// Reusable subscriptions table widget
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/subscription.dart';

class SubscriptionsTable extends StatelessWidget {
  final List<Subscription> subscriptions;
  final int? maxItems;
  final List<String> columns;
  final void Function(Subscription)? onRowTap;

  const SubscriptionsTable({super.key, required this.subscriptions, this.maxItems, this.columns = const ['start_date', 'name', 'amount', 'active'], this.onRowTap});

  List<DataColumn> _buildColumns(BuildContext context) {
    return columns.map((c) {
      switch (c) {
        case 'start_date':
          return const DataColumn(label: Text('Début'));
        case 'name':
          return const DataColumn(label: Text('Nom'));
        case 'amount':
          return const DataColumn(label: Text('Montant'), numeric: true);
        case 'active':
          return const DataColumn(label: Text('Actif'));
        case 'category':
          return const DataColumn(label: Text('Catégorie'));
        case 'interval':
          return const DataColumn(label: Text('Fréquence'));
        case 'id':
          return const DataColumn(label: Text('ID'));
        default:
          return DataColumn(label: Text(c));
      }
    }).toList();
  }

  List<DataCell> _buildCells(Subscription s) {
    final df = DateFormat('yyyy-MM-dd');
    return columns.map((c) {
      switch (c) {
        case 'start_date':
          return DataCell(Text(df.format(s.startDate)), onTap: () => onRowTap?.call(s));
        case 'name':
          return DataCell(Text(s.label), onTap: () => onRowTap?.call(s));
        case 'amount':
          return DataCell(Text(s.amount.toStringAsFixed(2)), onTap: () => onRowTap?.call(s));
        case 'active':
          return DataCell(Icon(s.active ? Icons.check_circle : Icons.remove_circle), onTap: () => onRowTap?.call(s));
        case 'category':
          return DataCell(Text(s.category), onTap: () => onRowTap?.call(s));
        case 'interval':
          return DataCell(Text('${s.intervalValue} ${s.intervalUnit}'), onTap: () => onRowTap?.call(s));
        case 'id':
          return DataCell(Text(s.id.toString()), onTap: () => onRowTap?.call(s));
        default:
          return DataCell(const Text(''), onTap: () => onRowTap?.call(s));
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = (maxItems != null) ? subscriptions.take(maxItems!).toList() : subscriptions;
    return DataTable(columns: _buildColumns(context), rows: items.map((s) => DataRow(cells: _buildCells(s))).toList());
  }
}
