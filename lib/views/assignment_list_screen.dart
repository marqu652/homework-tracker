import 'package:flutter/material.dart';

import '../presenters/assignment_presenter.dart';
import '../presenters/course_presenter.dart';
import '../widgets/add_fab.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  final AssignmentPresenter _assignmentPresenter = AssignmentPresenter();
  final CoursePresenter _coursePresenter = CoursePresenter();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _selectedCourseFilter;
  String? _newAssignmentCourse;
  List<String> _courseNames = [];
  String _searchQuery = '';
  bool _completedFirst = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _coursePresenter.loadCourses();
    await _assignmentPresenter.loadAssignments();
    setState(() {
      _isLoading = false;
      _courseNames = _coursePresenter.courses.map((c) => c.name).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final Set<int> _selectedAssignments = <int>{};

  Future<void> _confirmDeleteAll() async {
    if (_assignmentPresenter.assignments.isEmpty) {
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
        _assignmentPresenter.clearAssignments();
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
        _assignmentPresenter.removeAssignments(_selectedAssignments);
        _selectedAssignments.clear();
      });
    }
  }

  // Sort displayed indexes by completion without rearranging the assignments.
  List<int> _sortAssignmentsByCompletion(Iterable<int> indexes) {
    final sortedIndexes = indexes.toList();
    sortedIndexes.sort((a, b) {
      final aCompleted = _assignmentPresenter.assignments[a].isCompleted;
      final bCompleted = _assignmentPresenter.assignments[b].isCompleted;
      if (aCompleted == bCompleted) {
        return a.compareTo(b);
      }
      return _completedFirst ? (aCompleted ? -1 : 1) : (aCompleted ? 1 : -1);
    });
    return sortedIndexes;
  }

  void _showAddAssignmentDialog() {
    String newAssignmentTitle = '';
    _newAssignmentCourse = _courseNames.isNotEmpty ? _courseNames.first : null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Assignment'),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Enter assignment title',
                ),
                onChanged: (value) => newAssignmentTitle = value,
              ),
              const SizedBox(height: 12),
              DropdownButton<String>(
                value: _newAssignmentCourse,
                items: _courseNames.map((name) {
                  return DropdownMenuItem(value: name, child: Text(name));
                }).toList(),
                onChanged: (value) =>
                    setState(() => _newAssignmentCourse = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (newAssignmentTitle.trim().isNotEmpty &&
                    _newAssignmentCourse != null) {
                  await _assignmentPresenter.addAssignment(
                    newAssignmentTitle.trim(),
                    _newAssignmentCourse!,
                  );
                  setState(() {});

                  Navigator.pop(context);
                }
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
    final assignments = _assignmentPresenter.assignments;
    final displayedAssignmentIndexes = _sortAssignmentsByCompletion(
      List<int>.generate(assignments.length, (index) => index).where(
        (index) =>
            _selectedCourseFilter == null ||
            assignments[index].courseName == _selectedCourseFilter,
      ),
    );
    // final filteredAssignments = assignments
    //     .asMap()
    //     .entries
    //     .where(
    //       (entry) =>
    //           entry.value.title.toLowerCase().contains(_searchQuery.toLowerCase()),
    //     )
    //     .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        actions: [
          if (_courseNames.isNotEmpty)
            DropdownButton<String>(
              hint: const Text(
                'Filter by course',
                style: TextStyle(color: Colors.white),
              ),
              dropdownColor: Colors.blue[100],
              value: _selectedCourseFilter,
              onChanged: (value) {
                setState(() {
                  _selectedCourseFilter = value;
                });
              },
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All courses'),
                ),
                ..._courseNames.map(
                  (name) => DropdownMenuItem(value: name, child: Text(name)),
                ),
              ],
            ),
          PopupMenuButton<bool>(
            tooltip: 'Sort by completion',
            icon: const Icon(Icons.sort),
            onSelected: (completedFirst) {
              setState(() {
                _completedFirst = completedFirst;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: false,
                child: Text('Incomplete first'),
              ),
              const PopupMenuItem(value: true, child: Text('Completed first')),
            ],
          ),
        ],
      ),

      /* [
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
      ], */
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
                  child: displayedAssignmentIndexes.isEmpty
                      ? Center(
                          child: Text(
                            _searchQuery.isEmpty
                                ? 'No assignments'
                                : 'No assignments found',
                          ),
                        )
                      : ListView.builder(
                          itemCount: displayedAssignmentIndexes.length,
                          itemBuilder: (context, index) {
                            final assignmentIndex =
                                displayedAssignmentIndexes[index];
                            final assignment = assignments[assignmentIndex];
                            return CheckboxListTile(
                              title: Text(assignment.title),
                              subtitle: Text(
                                'Course: ${assignment.courseName}',
                              ),
                              value: assignment.isCompleted,
                              onChanged: (_) async {
                                await _assignmentPresenter.toggleCompleted(
                                  assignmentIndex,
                                );
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
      floatingActionButton: AddFAB(onPressed: _showAddAssignmentDialog),
    );
  }
}
