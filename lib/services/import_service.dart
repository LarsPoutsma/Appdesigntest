import 'package:csv/csv.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:icalendar_parser/icalendar_parser.dart';

import '../domain/entities/source.dart';
import '../domain/usecases/normalized_assignment.dart';

class ImportPayload {
  ImportPayload({required this.source, required this.items});

  final SourceConnection source;
  final List<NormalizedAssignment> items;
}

class ImportService {
  ImportService({required this.timezone});

  final String timezone;

  Future<ImportPayload> fromIcs(String content, SourceConnection source) async {
    final calendar = ICalendar.fromStrings([content]);
    final items = <NormalizedAssignment>[];
    for (final event in calendar.data) {
      final vevent = event['data'] as Map<String, dynamic>;
      final title = vevent['summary'] as String? ?? 'Untitled';
      final description = vevent['description'] as String?;
      final due = vevent['dtstart'] as String?;
      final url = vevent['url'] as String?;
      final location = vevent['location'] as String?;
      final normalized = NormalizationUtils.fromMap({
        'title': title,
        'description': description,
        'dueAt': due,
        'url': url,
        'location': location,
        'courseName': source.label,
        'raw': vevent,
      }, timezone: timezone);
      items.add(normalized);
    }
    return ImportPayload(source: source, items: items);
  }

  Future<ImportPayload> fromCsv(String content, SourceConnection source, Map<String, String> mapping) async {
    final rows = const CsvToListConverter().convert(content, shouldParseNumbers: false);
    if (rows.isEmpty) {
      return ImportPayload(source: source, items: []);
    }
    final headers = rows.first.map((e) => e.toString()).toList();
    final items = <NormalizedAssignment>[];
    for (final row in rows.skip(1)) {
      final map = <String, String>{};
      for (var i = 0; i < headers.length && i < row.length; i++) {
        map[headers[i]] = row[i].toString();
      }
      final normalized = NormalizationUtils.fromMap({
        'title': map[mapping['title']] ?? 'Untitled',
        'description': map[mapping['notes'] ?? ''] ?? '',
        'dueAt': map[mapping['dueAt']],
        'url': map[mapping['url'] ?? ''],
        'courseName': map[mapping['course'] ?? ''] ?? source.label,
        'raw': map,
      }, timezone: timezone);
      items.add(normalized);
    }
    return ImportPayload(source: source, items: items);
  }

  Future<ImportPayload> fromHtml(String content, SourceConnection source) async {
    final document = html_parser.parse(content);
    final rows = document.querySelectorAll('table tr');
    final items = <NormalizedAssignment>[];
    if (rows.isEmpty) {
      for (final li in document.querySelectorAll('li')) {
        final text = li.text.trim();
        final normalized = NormalizationUtils.fromMap(
          {
            'title': text,
            'dueAt': _extractDate(text),
            'courseName': source.label,
            'raw': {'text': text},
          },
          timezone: timezone,
        );
        items.add(normalized);
      }
      return ImportPayload(source: source, items: items);
    }

    for (final row in rows.skip(1)) {
      final cells = row.querySelectorAll('td');
      if (cells.length < 2) {
        continue;
      }
      final title = cells[0].text.trim();
      final dueText = cells[1].text.trim();
      final courseName = cells.length > 2 ? cells[2].text.trim() : source.label;
      final normalized = NormalizationUtils.fromMap(
        {
          'title': title,
          'dueAt': _extractDate(dueText),
          'courseName': courseName.isEmpty ? source.label : courseName,
          'raw': {'title': title, 'dueAt': dueText, 'course': courseName},
        },
        timezone: timezone,
      );
      items.add(normalized);
    }
    return ImportPayload(source: source, items: items);
  }

  String? _extractDate(String text) {
    final match = RegExp(r'(\d{1,2}/\d{1,2}/\d{2,4})').firstMatch(text);
    return match?.group(1);
  }
}
