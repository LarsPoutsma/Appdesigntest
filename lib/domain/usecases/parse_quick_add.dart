import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../entities/assignment.dart';
import 'normalized_assignment.dart';

class QuickAddParser {
  const QuickAddParser({this.defaultTimezone = 'America/Denver'});

  final String defaultTimezone;

  NormalizedAssignment parse(String input) {
    final now = DateTime.now().toUtc();
    final match = RegExp(r'due (?<date>[^for]+)( for (?<course>.+))?', caseSensitive: false).firstMatch(input);
    final dueAt = _parseDate(match?.namedGroup('date'), now) ?? now.add(const Duration(days: 1));
    final courseName = match?.namedGroup('course')?.trim();

    return NormalizedAssignment(
      tempId: now.microsecondsSinceEpoch.toString(),
      title: input.split(' due ').first.trim(),
      dueAt: dueAt,
      courseName: courseName?.isEmpty ?? true ? 'General' : courseName,
      allDay: false,
      raw: {'source': 'quick_add', 'input': input},
    );
  }

  DateTime? _parseDate(String? token, DateTime now) {
    if (token == null) {
      return null;
    }
    final trimmed = token.trim();
    if (trimmed.toLowerCase().startsWith('tomorrow')) {
      return now.add(const Duration(days: 1));
    }
    final weekdays = {
      'mon': DateTime.monday,
      'tue': DateTime.tuesday,
      'wed': DateTime.wednesday,
      'thu': DateTime.thursday,
      'fri': DateTime.friday,
      'sat': DateTime.saturday,
      'sun': DateTime.sunday,
    };
    final lower = trimmed.toLowerCase();
    for (final entry in weekdays.entries) {
      if (lower.startsWith(entry.key)) {
        final daysAhead = (entry.value - now.weekday + 7) % 7;
        return now.add(Duration(days: daysAhead == 0 ? 7 : daysAhead));
      }
    }
    final location = tz.getLocation(defaultTimezone);
    final formats = [
      DateFormat('MMM d h:mma'),
      DateFormat('MMM d'),
      DateFormat('M/d h:mma'),
      DateFormat('M/d'),
    ];
    for (final format in formats) {
      try {
        final localDate = format.parse(trimmed);
        final year = now.year;
        final withYear = DateTime(year, localDate.month, localDate.day, localDate.hour, localDate.minute);
        final zoned = tz.TZDateTime.from(withYear, location);
        return zoned.toUtc();
      } catch (_) {
        continue;
      }
    }
    return DateTime.tryParse(trimmed)?.toUtc();
  }
}
