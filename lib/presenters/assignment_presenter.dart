import '../models/assignment_model.dart';

class AssignmentPresenter {
  final List<Assignment> _assignment = [];

  List<Assignment> get assignments => _assignment;
  void addAssignment(String title) {
    _assignment.add(Assignment(title: title));
  }
  void toggleAssignmentCompletion(int index) {
    _assignment[index].isCompleted = !_assignment[index].isCompleted;
  }
}

