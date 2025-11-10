import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
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
    // Group operations by calendar date (yyyy-MM-dd) and sum amounts per date.
    final dateFmt = DateFormat('yyyy-MM-dd');
    final grouped = <String, double>{};
    for (final op in operations) {
      final key = dateFmt.format(op.levyDate);
      grouped[key] = (grouped[key] ?? 0) + op.amount;
    }

    // Convert grouped map to sorted list of DateTime and daily sum.
    var entries = grouped.entries.map((e) => MapEntry(DateTime.parse(e.key), e.value)).toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // If there are too many points, aggregate by week or month to keep chart readable.
    List<MapEntry<DateTime, double>> aggregate(List<MapEntry<DateTime, double>> src, String unit) {
      final map = <String, double>{};
      if (unit == 'week') {
        for (final e in src) {
          // find week start (Monday)
          final dt = e.key;
          final weekStart = dt.subtract(Duration(days: dt.weekday - 1));
          final key = DateFormat('yyyy-MM-dd').format(DateTime(weekStart.year, weekStart.month, weekStart.day));
          map[key] = (map[key] ?? 0) + e.value;
        }
      } else if (unit == 'month') {
        for (final e in src) {
          final dt = e.key;
          final key = DateFormat('yyyy-MM').format(dt);
          map[key] = (map[key] ?? 0) + e.value;
        }
      } else {
        for (final e in src) {
          final key = DateFormat('yyyy-MM-dd').format(e.key);
          map[key] = (map[key] ?? 0) + e.value;
        }
      }
      // convert back to DateTime keys (for month keys use first day of month)
      final list = <MapEntry<DateTime, double>>[];
      map.forEach((k, v) {
        if (k.length == 7) {
          // yyyy-MM
          final parts = k.split('-');
          final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
          list.add(MapEntry(dt, v));
        } else {
          list.add(MapEntry(DateTime.parse(k), v));
        }
      });
      list.sort((a, b) => a.key.compareTo(b.key));
      return list;
    }

    if (entries.length > 360) {
      entries = aggregate(entries, 'month');
    } else if (entries.length > 120) {
      entries = aggregate(entries, 'week');
    }

    // Build cumulative sums and x labels (one point per date/period).
    final spots = <FlSpot>[];
    final labels = <String>[];
    double cumulative = 0.0;
    for (int i = 0; i < entries.length; i++) {
      cumulative += entries[i].value;
      spots.add(FlSpot(i.toDouble(), cumulative));
      // label depending on aggregation
      if (entries.length > 360) {
        labels.add(DateFormat('MM/yyyy').format(entries[i].key));
      } else if (entries.length > 120) {
        // week: show start date
        labels.add(DateFormat('dd/MM').format(entries[i].key));
      } else {
        labels.add(DateFormat('dd/MM').format(entries[i].key));
      }
    }

    final currencyFmt = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

    // Axis title builder: show a few date labels to avoid crowding.
    Widget bottomTitleWidgets(double value, TitleMeta meta) {
      final intIndex = value.round();
      if (intIndex < 0 || intIndex >= labels.length) return const SizedBox.shrink();

      // Show at most 5 labels (first, last and intermediates) depending on length.
      if (labels.length <= 5) {
        return Padding(padding: const EdgeInsets.only(top: 4), child: Text(labels[intIndex], style: const TextStyle(fontSize: 10)));
      }

      final step = (labels.length / 4).ceil();
      if (intIndex % step == 0 || intIndex == labels.length - 1 || intIndex == 0) {
        return Padding(padding: const EdgeInsets.only(top: 4), child: Text(labels[intIndex], style: const TextStyle(fontSize: 10)));
      }
      return const SizedBox.shrink();
    }

    Widget leftTitleWidgets(double value, TitleMeta meta) {
      // Show labels formatted as currency
      const style = TextStyle(fontSize: 10);
      return Padding(padding: const EdgeInsets.only(right: 6), child: Text(currencyFmt.format(value), style: style, textAlign: TextAlign.right));
    }

    final lineChart = LineChart(LineChartData(
      gridData: const FlGridData(show: true),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36, getTitlesWidget: bottomTitleWidgets, interval: 1)),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 56, getTitlesWidget: leftTitleWidgets)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: [LineChartBarData(isCurved: false, spots: spots, dotData: const FlDotData(show: true), belowBarData: BarAreaData(show: false))],
      minX: 0,
      maxX: spots.isNotEmpty ? (spots.last.x) : 0,
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              final idx = spot.x.round();
              // guard index
              final safeIdx = idx.clamp(0, entries.length - 1);
              final dt = entries[safeIdx].key;
              final y = spot.y;
              final dateStr = entries.length > 360 ? DateFormat('MM/yyyy').format(dt) : DateFormat('yyyy-MM-dd').format(dt);
              return LineTooltipItem('$dateStr\n${currencyFmt.format(y)}', const TextStyle(color: Colors.white));
            }).toList();
          },
        ),
      ),
    ));

    // Wrap in InteractiveViewer to allow pan only (zoom disabled) and add vertical padding
    return InteractiveViewer(
      scaleEnabled: false, // disable zoom
      panEnabled: false, // disable pan to prevent moving the chart
      boundaryMargin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4, left: 4, right: 32),
        child: SizedBox(
          // ensure chart keeps its intrinsic height
          height: 220,
          child: lineChart,
        ),
      ),
    );
  }

  Widget _buildBar() {
  final sorted = List<Operation>.from(operations)..sort((a, b) => a.levyDate.compareTo(b.levyDate));
    final groups = <BarChartGroupData>[];
    for (int i = 0; i < sorted.length; i++) {
      groups.add(BarChartGroupData(x: i, barRods: [BarChartRodData(toY: sorted[i].amount)]));
    }
    return BarChart(BarChartData(barGroups: groups, titlesData: const FlTitlesData(show: false)));
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