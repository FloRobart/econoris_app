import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/operation.dart';

class OperationsChart extends StatelessWidget {
  final List<Operation> operations;
  final String chartType; // 'line', 'bar', 'pie'

  const OperationsChart({super.key, required this.operations, required this.chartType});

  @override
  Widget build(BuildContext context) {
    if (operations.isEmpty) return const Center(child: Text('Pas d\'opérations'));

    if (chartType == 'line') return _buildLine();
    if (chartType == 'bar') return _buildBar();
    return _buildPie();
  }

  Widget _buildLine() {
    final spots = <FlSpot>[];
    final sorted = List<Operation>.from(operations)..sort((a, b) => a.date.compareTo(b.date));
    for (int i = 0; i < sorted.length; i++) {
      spots.add(FlSpot(i.toDouble(), sorted[i].amount));
    }
    return LineChart(LineChartData(
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(show: true, bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
      lineBarsData: [LineChartBarData(isCurved: false, spots: spots, dotData: FlDotData(show: true))],
    ));
  }

  Widget _buildBar() {
    final sorted = List<Operation>.from(operations)..sort((a, b) => a.date.compareTo(b.date));
    final groups = <BarChartGroupData>[];
    for (int i = 0; i < sorted.length; i++) {
      groups.add(BarChartGroupData(x: i, barRods: [BarChartRodData(toY: sorted[i].amount)]));
    }
    return BarChart(BarChartData(barGroups: groups, titlesData: FlTitlesData(show: false)));
  }

  Widget _buildPie() {
    final map = <String, double>{};
    for (final op in operations) {
      map[op.category] = (map[op.category] ?? 0) + op.amount;
    }
    final sections = <PieChartSectionData>[];
    int i = 0;
    map.forEach((k, v) {
      sections.add(PieChartSectionData(value: v, title: k, radius: 40 + (i * 2)));
      i++;
    });
    return PieChart(PieChartData(sections: sections));
  }
}