import 'package:flutter_test/flutter_test.dart';
import 'package:homework_tracker/domain/entities/source.dart';
import 'package:homework_tracker/services/import_service.dart';

void main() {
  test('imports simple ICS event', () async {
    const content = 'BEGIN:VCALENDAR\nBEGIN:VEVENT\nSUMMARY:Test\nDTSTART:20240412T235900Z\nEND:VEVENT\nEND:VCALENDAR';
    final service = ImportService(timezone: 'America/Denver');
    final source = SourceConnection(id: '1', userId: 'user', kind: SourceKind.ics, label: 'ICS', metadata: const {});
    final payload = await service.fromIcs(content, source);
    expect(payload.items, hasLength(1));
    expect(payload.items.first.title, equals('Test'));
  });
}
