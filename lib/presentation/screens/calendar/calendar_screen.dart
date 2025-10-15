import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../domain/entities/assignment.dart';
import '../../providers/assignment_provider.dart';
import '../../widgets/assignment_tile.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  @override
  Widget build(BuildContext context) {
    final assignments = context.watch<AssignmentProvider>().assignments;
    final grouped = <DateTime, List<Assignment>>{};
    for (final assignment in assignments) {
      final key = DateTime.utc(assignment.dueAt.year, assignment.dueAt.month, assignment.dueAt.day);
      grouped.putIfAbsent(key, () => []).add(assignment);
    }

    final events = grouped.map((key, value) => MapEntry(key, value.length));

    final selectedAssignments = grouped[selectedDay] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          TableCalendar<Assignment>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2035, 12, 31),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, selectedDay),
            eventLoader: (day) => grouped[DateTime.utc(day.year, day.month, day.day)] ?? [],
            calendarStyle: const CalendarStyle(markerDecoration: BoxDecoration(color: Colors.indigo, shape: BoxShape.circle)),
            onDaySelected: (selected, focused) => setState(() {
              selectedDay = selected;
              focusedDay = focused;
            }),
          ),
          const Divider(height: 1),
          Expanded(
            child: selectedAssignments.isEmpty
                ? const Center(child: Text('No assignments on this day.'))
                : ListView.separated(
                    itemCount: selectedAssignments.length,
                    separatorBuilder: (_, __) => const Divider(height: 0),
                    itemBuilder: (context, index) => AssignmentTile(assignment: selectedAssignments[index]),
                  ),
          ),
        ],
      ),
    );
  }
}
