import 'package:flutter_test/flutter_test.dart';
import 'package:homework_tracker/domain/entities/assignment.dart';

void main() {
  test('fingerprint is deterministic', () {
    final first = Assignment.computeFingerprint(
      title: 'Lab 3',
      dueAtUtc: DateTime.utc(2024, 4, 10, 6),
      courseName: 'Chem 121',
      url: 'https://canvas.example.com/lab3',
    );
    final second = Assignment.computeFingerprint(
      title: 'lab 3',
      dueAtUtc: DateTime.utc(2024, 4, 10, 6),
      courseName: 'chem 121',
      url: 'https://canvas.example.com/lab3',
    );
    expect(first, equals(second));
  });
}
