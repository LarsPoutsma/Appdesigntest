import 'package:intl/intl.dart';

import '../domain/entities/assignment.dart';

class ExportService {
  String generateIcsFeed(List<Assignment> assignments) {
    final buffer = StringBuffer()
      ..writeln('BEGIN:VCALENDAR')
      ..writeln('VERSION:2.0')
      ..writeln('PRODID:-//Homework Tracker//EN');

    final format = DateFormat("yyyyMMdd'T'HHmmss'Z'");
    for (final assignment in assignments) {
      buffer
        ..writeln('BEGIN:VEVENT')
        ..writeln('UID:${assignment.id}@homeworktracker')
        ..writeln('SUMMARY:${assignment.title}')
        ..writeln('DTSTART:${format.format(assignment.dueAt.toUtc())}')
        ..writeln('DTEND:${format.format(assignment.dueAt.toUtc().add(const Duration(hours: 1)))}')
        ..writeln('DESCRIPTION:${assignment.description ?? ''}')
        ..writeln('URL:${assignment.url ?? ''}')
        ..writeln('STATUS:${assignment.status == AssignmentStatus.done ? 'COMPLETED' : 'CONFIRMED'}')
        ..writeln('END:VEVENT');
    }

    buffer.writeln('END:VCALENDAR');
    return buffer.toString();
  }
}
