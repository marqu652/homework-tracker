import 'package:flutter/material.dart';
import '../presenters/course_presenter.dart';
import '../widgets/add_fab.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final CoursePresenter presenter = CoursePresenter();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    await presenter.loadCourses();
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddCourseDialog() {
    String name = '';
    String description = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Course'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Course Name'),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
                onChanged: (value) => description = value,
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
                if (name.trim().isNotEmpty) {
                  await presenter.addCourse(name.trim(), description);
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
    final filteredCourses = presenter.courses
        .where(
          (course) =>
              course.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
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
                      hintText: 'Search courses',
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
                  child: filteredCourses.isEmpty
                      ? Center(
                          child: Text(
                            _searchQuery.isEmpty
                                ? 'No courses'
                                : 'No courses found',
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredCourses.length,
                          itemBuilder: (context, index) {
                            final course = filteredCourses[index];
                            return ListTile(
                              title: Text(course.name),
                              subtitle: course.description != null
                                  ? Text(course.description!)
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            ),

      /* ListView.builder(
           itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return ListTile(
              title: Text(course.name),
              subtitle: course.description != null ? Text(course.description!) : null,
            );
          },
        ), */
      floatingActionButton: AddFAB(
        onPressed: _showAddCourseDialog),
    );
  }
}
