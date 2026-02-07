import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/subscriptions/subscription.dart';

class SubscriptionsChart extends StatelessWidget {
  final List<Subscription> subscriptions;
  final String chartType; // 'line','bar','pie'

  const SubscriptionsChart({
    super.key,
    required this.subscriptions,
    required this.chartType,
  });

  @override
  Widget build(BuildContext context) {
    if (subscriptions.isEmpty)
      return const Center(child: Text('Pas d\'abonnements'));
    if (chartType == 'line') return _buildLine();
    if (chartType == 'bar') return _buildBar();
    return _buildPie();
  }

  Widget _buildLine() {
    final dateFmt = DateFormat('yyyy-MM-dd');
    final grouped = <String, double>{};
    for (final s in subscriptions) {
      final key = dateFmt.format(s.startDate);
      grouped[key] = (grouped[key] ?? 0) + s.amount;
    }

    var entries =
        grouped.entries
            .map((e) => MapEntry(DateTime.parse(e.key), e.value))
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    final spots = <FlSpot>[];
    final labels = <String>[];
    double cumulative = 0.0;
    for (int i = 0; i < entries.length; i++) {
      cumulative += entries[i].value;
      spots.add(FlSpot(i.toDouble(), cumulative));
      labels.add(DateFormat('dd/MM').format(entries[i].key));
    }

    final currencyFmt = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

    Widget bottomTitleWidgets(double value, TitleMeta meta) {
      final idx = value.round();
      if (idx < 0 || idx >= labels.length) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(labels[idx], style: const TextStyle(fontSize: 10)),
      );
    }

    Widget leftTitleWidgets(double value, TitleMeta meta) {
      const style = TextStyle(fontSize: 10);
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: Text(
          currencyFmt.format(value),
          style: style,
          textAlign: TextAlign.right,
        ),
      );
    }

    final lineChart = LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: bottomTitleWidgets,
              interval: 1,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 56,
              getTitlesWidget: leftTitleWidgets,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: false,
            spots: spots,
            dotData: const FlDotData(show: true),
          ),
        ],
        minX: 0,
        maxX: spots.isNotEmpty ? spots.last.x : 0,
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4, left: 4, right: 32),
      child: SizedBox(height: 220, child: lineChart),
    );
  }

  Widget _buildBar() {
    final sorted = List<Subscription>.from(subscriptions)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    final groups = <BarChartGroupData>[];
    for (int i = 0; i < sorted.length; i++) {
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [BarChartRodData(toY: sorted[i].amount)],
        ),
      );
    }
    return BarChart(
      BarChartData(
        barGroups: groups,
        titlesData: const FlTitlesData(show: false),
      ),
    );
  }

  Widget _buildPie() {
    final map = <String, double>{};
    for (final s in subscriptions) {
      map[s.category] = (map[s.category] ?? 0) + s.amount;
    }
    final sections = <PieChartSectionData>[];
    int i = 0;
    map.forEach((k, v) {
      sections.add(
        PieChartSectionData(value: v, title: k, radius: 40 + (i * 2)),
      );
      i++;
    });
    return PieChart(PieChartData(sections: sections));
  }
}
