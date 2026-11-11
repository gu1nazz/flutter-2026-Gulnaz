import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';

/// Level 2 + Level 5: four states by hand, and a Save that does not lie.
class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Student>? _students; // null = not loaded yet
  Object? _error; // non-null = failed
  final _api = FakeApi(); // FakeApi(empty: true) -> the empty state
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // initState is synchronous: we start the load and do not await it.
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _students = null;
      _error = null;
    });
    try {
      final list = await _api.fetchStudents();
      if (!mounted) return;
      setState(() => _students = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  Widget _body() {
    if (_error != null) return ErrorView(onRetry: _load);
    final students = _students;
    if (students == null) return const LoadingView();
    if (students.isEmpty) return const EmptyView();
    return StudentList(students);
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _students != null && _error == null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students — by hand'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _body(),
      floatingActionButton: !canSave
          ? null
          : FloatingActionButton(
              onPressed: _saving
                  ? null
                  : () async {
                      final n = _students!.length;
                      setState(() => _saving = true);
                      try {
                        await _api.save(n);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      } on StateError catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(e.message)));
                      } finally {
                        if (mounted) setState(() => _saving = false);
                      }
                    },
              child: _saving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
            ),
    );
  }
}
