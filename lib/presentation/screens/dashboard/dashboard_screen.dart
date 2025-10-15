import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/assignment.dart';
import '../../../domain/usecases/parse_quick_add.dart';
import '../../providers/assignment_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/assignment_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  AssignmentStatus? filterStatus;
  String? filterCourse;

  @override
  Widget build(BuildContext context) {
    final assignments = context.watch<AssignmentProvider>().assignments;
    final courses = context.watch<CourseProvider>().courses;

    final filtered = assignments.where((assignment) {
      final statusMatches = filterStatus == null || assignment.status == filterStatus;
      final courseMatches = filterCourse == null || assignment.courseId == filterCourse;
      return statusMatches && courseMatches;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Homework Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AssignmentProvider>().refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                DropdownButton<AssignmentStatus?>(
                  value: filterStatus,
                  hint: const Text('Status'),
                  onChanged: (value) => setState(() => filterStatus = value),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All statuses')),
                    DropdownMenuItem(value: AssignmentStatus.pending, child: Text('Pending')),
                    DropdownMenuItem(value: AssignmentStatus.done, child: Text('Done')),
                    DropdownMenuItem(value: AssignmentStatus.snoozed, child: Text('Snoozed')),
                  ],
                ),
                DropdownButton<String?>(
                  value: filterCourse,
                  hint: const Text('Course'),
                  onChanged: (value) => setState(() => filterCourse = value),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All courses')),
                    for (final course in courses)
                      DropdownMenuItem(value: course.id, child: Text(course.name)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No assignments yet. Import from your LMS or add manually.'))
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 0),
                    itemBuilder: (context, index) => AssignmentTile(assignment: filtered[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final text = await showDialog<String>(
            context: context,
            builder: (context) => const _QuickAddDialog(),
          );
          if (!context.mounted || text == null) {
            return;
          }
          final parser = QuickAddParser(
            defaultTimezone: context.read<SettingsProvider>().timezone,
          );
          final normalized = parser.parse(text);
          final courseProvider = context.read<CourseProvider>();
          if (courseProvider.courses.isEmpty) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create a course before adding assignments.')),
              );
            }
            return;
          }
          final course = courseProvider.courses.firstWhere(
            (element) => element.name.toLowerCase() == normalized.courseName?.toLowerCase(),
            orElse: () => courseProvider.courses.first,
          );
          final sourceId = 'quick-add';
          await context.read<AssignmentProvider>().addFromNormalized([normalized], course.id, sourceId);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Assignment created and scheduled reminders.')),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Quick Add'),
      ),
    );
  }
}

class _QuickAddDialog extends StatefulWidget {
  const _QuickAddDialog();

  @override
  State<_QuickAddDialog> createState() => _QuickAddDialogState();
}

class _QuickAddDialogState extends State<_QuickAddDialog> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Quick Add'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Lab 3 due Fri 11:59pm for Chem 121',
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.of(context).pop(controller.text.trim()), child: const Text('Add')),
      ],
    );
  }
}
