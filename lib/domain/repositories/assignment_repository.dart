import '../entities/assignment.dart';

abstract class AssignmentRepository {
  Stream<List<Assignment>> watchAssignments();

  Future<List<Assignment>> fetchAssignments();

  Future<void> upsertAssignments(List<Assignment> assignments);

  Future<void> deleteAssignments(Iterable<String> ids);

  Future<void> markStatus(String id, AssignmentStatus status);

  Future<void> updateDueDate(String id, DateTime newDueDate);

  Future<void> syncFromRemote();

  Future<void> syncToRemote();
}
