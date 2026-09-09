import 'package:flutter/material.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
 
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
                  _assignments.add({'title': newAssignmentTitle.trim(), 'completed': false});
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


void _toggleCompleted(int index, bool? value) {
  setState(() {
    _assignments[index]['completed'] = value ?? false;
  });
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
  return Scaffold(
    appBar: AppBar(title: const Text('Assignments')),
    body: ListView.builder(
      itemCount: _assignments.length,
      itemBuilder: (context, index) {
        return CheckboxListTile(
          title: Text(_assignments[index]['title']),
          value: _assignments[index]['completed'],
          onChanged: (value) => _toggleCompleted(index, value),
          secondary: IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit assignment',
            onPressed: () => _showEditAssignmentDialog(index),
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