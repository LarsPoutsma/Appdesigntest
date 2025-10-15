import 'package:flutter/foundation.dart';

import '../../domain/entities/assignment.dart';
import '../../domain/usecases/normalized_assignment.dart';
import '../providers/assignment_provider.dart';

class ReviewItem {
  ReviewItem({required this.assignment, required this.conflict});

  final Assignment assignment;
  final Assignment? conflict;
}

class ReviewProvider extends ChangeNotifier {
  ReviewProvider(this._assignmentProvider);

  final AssignmentProvider _assignmentProvider;
  List<ReviewItem> items = [];

  void queue(List<Assignment> assignments, {Assignment? conflict}) {
    items = assignments.map((e) => ReviewItem(assignment: e, conflict: conflict)).toList();
    notifyListeners();
  }

  Future<void> approveAll() async {
    for (final item in items) {
      await _assignmentProvider.addFromNormalized(
        [
          NormalizedAssignment(
            tempId: item.assignment.id,
            title: item.assignment.title,
            dueAt: item.assignment.dueAt,
            allDay: item.assignment.allDay,
            courseName: '',
          )
        ],
        item.assignment.courseId,
        item.assignment.sourceId,
      );
    }
    items = [];
    notifyListeners();
  }
}
