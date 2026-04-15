// lib/screens/students_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/student.dart';
import '../utils/theme.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showAddDialog(BuildContext ctx) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String? nameErr;
    String? emailErr;

    showDialog(
      context: ctx,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text('Add New Student',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _formField(
                    controller: nameCtrl,
                    label: 'Full Name *',
                    hint: 'e.g. Ananya Patel',
                    error: nameErr,
                    onChanged: (_) => setDialogState(() => nameErr = null),
                  ),
                  const SizedBox(height: 12),
                  _formField(
                    controller: emailCtrl,
                    label: 'Email *',
                    hint: 'student@example.com',
                    error: emailErr,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => setDialogState(() => emailErr = null),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    bool valid = true;
                    final name = nameCtrl.text.trim();
                    final email = emailCtrl.text.trim();

                    if (name.isEmpty) {
                      setDialogState(() => nameErr = 'Full name is required');
                      valid = false;
                    }
                    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                    if (!emailRegex.hasMatch(email)) {
                      setDialogState(() => emailErr = 'Enter a valid email');
                      valid = false;
                    }
                    if (!valid) return;

                    ctx.read<AppProvider>().addStudent(name, email);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text('✓ "$name" added successfully'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  child: const Text('Add Student'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext ctx, Student student) {
    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text('Delete Student', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Text(
          'Remove "${student.name}"? This will also delete all their attendance records.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              ctx.read<AppProvider>().deleteStudent(student.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text('"${student.name}" removed'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _formField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? error,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            errorText: error,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final students = app.students;
    final filtered = _search.isEmpty
        ? students
        : students
            .where((s) =>
                s.name.toLowerCase().contains(_search.toLowerCase()) ||
                s.id.toLowerCase().contains(_search.toLowerCase()) ||
                s.email.toLowerCase().contains(_search.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Students',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            Text(
              '${students.length} student${students.length != 1 ? 's' : ''} total',
              style: TextStyle(
                  fontSize: 12,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            onPressed: () => _showAddDialog(context),
            tooltip: 'Add Student',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SearchBar(
              controller: _searchCtrl,
              hintText: 'Search students...',
              leading: const Icon(Icons.search_rounded, size: 20),
              trailing: _search.isNotEmpty
                  ? [
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _search = '');
                        },
                      )
                    ]
                  : null,
              onChanged: (v) => setState(() => _search = v),
              padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 12)),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_off_rounded,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          _search.isNotEmpty
                              ? 'No students match your search.'
                              : 'No students yet.\nTap + to add your first student.',
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final student = filtered[index];
                      final globalIdx = students.indexOf(student);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: avatarColor(globalIdx),
                            child: Text(
                              student.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(student.name,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                          subtitle: Text(student.email,
                              style: const TextStyle(fontSize: 12)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: kIndigo.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  student.id,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: kIndigo,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'monospace'),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    color: Color(0xFFEF4444), size: 18),
                                onPressed: () =>
                                    _showDeleteDialog(context, student),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.person_add_rounded),
      ),
    );
  }
}
