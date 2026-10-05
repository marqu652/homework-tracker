import 'package:flutter/material.dart';
import '../presenters/assignment_presenter.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}


class _AssignmentListScreenState extends State<AssignmentListScreen> {
 
  final AssignmentPresenter _presenter = AssignmentPresenter();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    await _presenter.loadAssignments();
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
            onPressed: () async {
              if (newAssignmentTitle.trim().isNotEmpty) {
                await _presenter.addAssignment(newAssignmentTitle.trim());
                setState(() {});
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
  final filteredAssignments = assignments
      .asMap()
      .entries
      .where(
        (entry) =>
            entry.value.title.toLowerCase().contains(_searchQuery.toLowerCase()),
      )
      .toList();

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
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search assignments',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.clear),
                            onPressed: _searchController.clear,
                          ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: filteredAssignments.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'No assignments'
                              : 'No assignments found',
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredAssignments.length,
                        itemBuilder: (context, index) {
                          final entry = filteredAssignments[index];
                          final assignment = entry.value;
                          return CheckboxListTile(
                            title: Text(assignment.title),
                            value: assignment.isCompleted,
                            onChanged: (_) async {
                              await _presenter.toggleCompleted(entry.key);
                              setState(() {});
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
    
     
     /* ListView.builder(
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
    ), */

    floatingActionButton: FloatingActionButton(
      onPressed: _showAddAssignmentDialog,
      child: const Icon(Icons.add),
    ),
  );
}
}
