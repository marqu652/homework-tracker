import 'package:flutter/material.dart';
import '../presenters/assignment_presenter.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}


class _AssignmentListScreenState extends State<AssignmentListScreen> {
 
 final AssignmentPresenter _presenter = AssignmentPresenter();
final Set<int> _selectedAssignments = <int>{};

Future<void> _confirmDeleteAll() async {
  if (_presenter.assignments.isEmpty) {
    return;
  }

  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete all assignments?'),
      content: const Text('This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete all'),
        ),
      ],
    ),
  );

  if (shouldDelete == true && mounted) {
    setState(() {
      _presenter.clearAssignments();
      _selectedAssignments.clear();
    });
  }
}

Future<void> _confirmDeleteSelected() async {
  if (_selectedAssignments.isEmpty) {
    return;
  }

  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete selected assignments?'),
      content: Text(
        'Delete ${_selectedAssignments.length} selected assignment(s)?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete selected'),
        ),
      ],
    ),
  );

  if (shouldDelete == true && mounted) {
    setState(() {
      _presenter.removeAssignments(_selectedAssignments);
      _selectedAssignments.clear();
    });
  }
}

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




@override
Widget build(BuildContext context) {
  final assignments = _presenter.assignments;

  return Scaffold(
    appBar: AppBar(
      title: const Text('Assignments'),
      actions: [
        IconButton(
          onPressed: _selectedAssignments.isEmpty
              ? null
              : _confirmDeleteSelected,
          tooltip: 'Delete selected assignments',
          icon: const Icon(Icons.delete),
        ),
        IconButton(
          onPressed: assignments.isEmpty ? null : _confirmDeleteAll,
          tooltip: 'Delete all assignments',
          icon: const Icon(Icons.delete_sweep),
        ),
      ],
    ),
    body: ListView.builder(
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        return ListTile(
          onTap: () {
            setState(() {
              _presenter.toggleCompleted(index);
            });
          },
          title: Text(
            assignment.title,
            style: assignment.isCompleted
                ? const TextStyle(decoration: TextDecoration.lineThrough)
                : null,
          ),
          trailing: Checkbox(
            value: _selectedAssignments.contains(index),
            onChanged: (selected) {
              setState(() {
                if (selected == true) {
                  _selectedAssignments.add(index);
                } else {
                  _selectedAssignments.remove(index);
                }
              });
            },
          ),
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

