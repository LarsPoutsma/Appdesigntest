import 'package:flutter_test/flutter_test.dart';
import 'package:homework_tracker/domain/usecases/normalized_assignment.dart';

void main() {
  test('parses csv date formats', () {
    final normalized = NormalizationUtils.fromMap({
      'title': 'Reading Quiz',
      'dueAt': '04/12/2024 11:59',
    });
    expect(normalized.dueAt.year, equals(2024));
    expect(normalized.dueAt.month, equals(4));
    expect(normalized.dueAt.day, equals(12));
  });
}
