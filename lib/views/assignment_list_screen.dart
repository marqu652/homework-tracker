import 'package:flutter/material.dart';
import '../presenters/assignment_presenter.dart';
import '../models/assignment_model.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}


class _AssignmentListScreenState extends State<AssignmentListScreen> {
 
 final AssignmentPresenter _presenter = AssignmentPresenter();
final List<Map<String, dynamic>> _assignments = [];

void _showAddAssignmentDialog() {
  String newAssignmentTitle = '';

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add Assignment'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter assignment title'),
          onChanged: (value) {
            newAssignmentTitle = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (newAssignmentTitle.trim().isNotEmpty) {
                setState(() {
                  _presenter.addAssignment(newAssignmentTitle.trim());
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}




Future<void> _showEditAssignmentDialog(int index) async {
  final controller = TextEditingController(
    text: _assignments[index]['title'] as String,
  );

  final updatedTitle = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit Assignment'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter assignment title',
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => Navigator.pop(context, controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
  controller.dispose();

  final title = updatedTitle?.trim();
  if (!mounted || title == null || title.isEmpty) {
    return;
  }

  setState(() {
    _assignments[index]['title'] = title;
  });
}

@override
Widget build(BuildContext context) {
  final assignments = _presenter.assignments;

  return Scaffold(
    appBar: AppBar(title: const Text('Assignments')),
    body: ListView.builder(
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        return CheckboxListTile(
          title: Text(assignment.title),
          value: assignment.isCompleted,
          onChanged: (value) {
            setState(() {
              _presenter.toggleCompleted(index);
            });
          },
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _showAddAssignmentDialog,
      child: const Icon(Icons.add),
    ),
  );
}
}

