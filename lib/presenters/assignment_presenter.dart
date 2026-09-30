import '../models/assignment_model.dart';

class AssignmentPresenter {
  final List<Assignment> _assignments = [];
  List<Assignment> get assignments => _assignments;
  
  Future<void> loadAssignments() async {
    final fetched = await Assignment.fetchAssignments();
    _assignments
      ..clear()
      ..addAll(fetched);
  }

  Future<void> addAssignment(String title) async {
    await Assignment.addAssignment(title);
    _assignments.add(Assignment(title: title));
  }

  Future<void> toggleCompleted(int index) async {
    await Assignment.updateCompletionStatus(index, _assignments);
    _assignments[index].isCompleted = !_assignments[index].isCompleted;
  }

  void clearAssignments() {
    _assignments.clear();
  }

  void removeAssignments(Set<int> indexes) {
    final sortedIndexes = indexes.toList()..sort((a, b) => b.compareTo(a));
    for (final index in sortedIndexes) {
      _assignments.removeAt(index);
    }
  }
}

