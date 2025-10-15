import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/assignment.dart';
import '../providers/assignment_provider.dart';

class AssignmentTile extends StatelessWidget {
  const AssignmentTile({required this.assignment, super.key});

  final Assignment assignment;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMEd().add_jm();
    final color = switch (assignment.status) {
      AssignmentStatus.done => Colors.green,
      AssignmentStatus.snoozed => Colors.orange,
      _ => Theme.of(context).colorScheme.primary,
    };

    return ListTile(
      title: Text(assignment.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Due ${dateFormat.format(assignment.dueAt.toLocal())}'),
          if (assignment.description != null && assignment.description!.isNotEmpty)
            Text(assignment.description!),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          final provider = context.read<AssignmentProvider>();
          switch (value) {
            case 'done':
              await provider.markDone(assignment.id);
              break;
            case 'snooze':
              await provider.snooze(assignment.id, const Duration(hours: 24));
              break;
            case 'remind':
              await provider.scheduleDefaultReminders();
              break;
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'done', child: Text('Mark as done')),
          PopupMenuItem(value: 'snooze', child: Text('Snooze 24h')),
          PopupMenuItem(value: 'remind', child: Text('Schedule reminders')),
        ],
      ),
      leading: CircleAvatar(
        backgroundColor: color,
        child: Text(assignment.title.isNotEmpty ? assignment.title.characters.first : '?'),
      ),
      onTap: assignment.url == null
          ? null
          : () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(title: Text(assignment.title)),
                    body: Padding(
                      padding: const EdgeInsets.all(24),
                      child: SelectableText('Open ${assignment.url} in your browser.'),
                    ),
                  ),
                ),
              );
            },
    );
  }
}
