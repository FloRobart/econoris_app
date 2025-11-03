import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/operation.dart';

class CalendarPage extends StatefulWidget {
  final List<Operation> operations;
  final ValueChanged<Operation> onOperationTap;

  const CalendarPage({super.key, required this.operations, required this.onOperationTap});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late Map<DateTime, List<Operation>> events;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    events = {};
    for (final op in widget.operations) {
      final day = DateTime(op.levyDate.year, op.levyDate.month, op.levyDate.day);
      events.putIfAbsent(day, () => []).add(op);
    }
  }

  List<Operation> _getEventsForDay(DateTime day) => events[DateTime(day.year, day.month, day.day)] ?? [];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TableCalendar(
        firstDay: DateTime.utc(2000, 1, 1),
        lastDay: DateTime.utc(2100, 12, 31),
        focusedDay: _focusedDay,
        eventLoader: _getEventsForDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selected, focused) {
          setState(() {
            _selectedDay = selected;
            _focusedDay = focused;
          });
        },
        calendarStyle: const CalendarStyle(markerDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
      ),
      const SizedBox(height: 8),
      Expanded(
        child: ListView(
      children: _getEventsForDay(_selectedDay ?? _focusedDay).map((op) => ListTile(title: Text(op.label), subtitle: Text(op.levyDate.toIso8601String()), trailing: Text(op.amount.toStringAsFixed(2)), onTap: () => widget.onOperationTap(op))).toList(),
        ),
      )
    ]);
  }
}