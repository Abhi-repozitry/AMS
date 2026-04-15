// lib/screens/mark_attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/attendance_record.dart';
import '../utils/theme.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  late DateTime _selectedDate;
  Map<String, AttendanceStatus> _markingState = {};
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
  }

  String get _dateStr => DateFormat('yyyy-MM-dd').format(_selectedDate);

  void _loadExisting() {
    final app = context.read<AppProvider>();
    final existing = app.attendanceRecords.where((r) => r.date == _dateStr);
    final state = <String, AttendanceStatus>{};
    for (final r in existing) {
      state[r.studentId] = r.status;
    }
    setState(() {
      _markingState = state;
      _saved = state.isNotEmpty;
    });
  }

  void _cycleStatus(String studentId) {
    const cycle = AttendanceStatus.values;
    final current = _markingState[studentId];
    AttendanceStatus next;
    if (current == null) {
      next = AttendanceStatus.present;
    } else {
      final idx = cycle.indexOf(current);
      next = cycle[(idx + 1) % cycle.length];
    }
    setState(() {
      _markingState[studentId] = next;
      _saved = false;
    });
  }

  void _markAllPresent() {
    final app = context.read<AppProvider>();
    final state = <String, AttendanceStatus>{};
    for (final s in app.students) {
      state[s.id] = AttendanceStatus.present;
    }
    setState(() {
      _markingState = state;
      _saved = false;
    });
  }

  void _saveRecords() {
    context.read<AppProvider>().saveAttendanceForDate(_dateStr, _markingState);
    setState(() => _saved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '✓ Attendance saved for ${DateFormat('d MMM yyyy').format(_selectedDate)}'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF16A34A),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _markingState = {};
        _saved = false;
      });
      _loadExisting();
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final students = app.students;
    final markedCount = _markingState.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          TextButton.icon(
            onPressed: _markAllPresent,
            icon: const Icon(Icons.people_alt_rounded, size: 16),
            label: const Text('All Present', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Date picker strip
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: kIndigo.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kIndigo.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      color: kIndigo, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    DateFormat('EEEE, d MMMM yyyy').format(_selectedDate),
                    style: const TextStyle(
                        color: kIndigo,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_drop_down_rounded, color: kIndigo),
                ],
              ),
            ),
          ),

          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '$markedCount / ${students.length} marked',
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value:
                          students.isEmpty ? 0 : markedCount / students.length,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.2),
                      color: kIndigo,
                      minHeight: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tap hint
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Tap a student to cycle: Present → Absent → Late → Leave',
              style: TextStyle(
                  fontSize: 11,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
            ),
          ),
          const SizedBox(height: 8),

          // Student list
          Expanded(
            child: students.isEmpty
                ? const Center(
                    child: Text('No students. Add some in the Students tab.',
                        style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final status = _markingState[student.id];
                      return _StudentMarkCard(
                        student: student,
                        index: index,
                        status: status,
                        onTap: () => _cycleStatus(student.id),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton.icon(
            onPressed: _markingState.isEmpty ? null : _saveRecords,
            icon: Icon(_saved ? Icons.check_rounded : Icons.save_rounded),
            label: Text(_saved ? 'Saved ✓' : 'Save Attendance'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: _saved ? const Color(0xFF16A34A) : null,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ),
    );
  }
}

class _StudentMarkCard extends StatelessWidget {
  final dynamic student;
  final int index;
  final AttendanceStatus? status;
  final VoidCallback onTap;

  const _StudentMarkCard({
    required this.student,
    required this.index,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasStatus = status != null;
    final borderColor = hasStatus
        ? statusColor(status!)
        : Theme.of(context).colorScheme.outline.withOpacity(0.3);
    final bgColor = hasStatus
        ? statusBgColor(status!).withOpacity(
            Theme.of(context).brightness == Brightness.dark ? 0.15 : 1.0)
        : null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor ?? Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: hasStatus ? 1.5 : 1),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor:
                  hasStatus ? statusColor(status!) : avatarColor(index),
              child: Text(
                student.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                  Text(student.id,
                      style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                          fontFamily: 'monospace')),
                ],
              ),
            ),
            if (hasStatus)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor(status!).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon(status!),
                        size: 13, color: statusTextColor(status!)),
                    const SizedBox(width: 4),
                    Text(
                      status!.label.toUpperCase(),
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusTextColor(status!)),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'TAP',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.4)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
