// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/attendance_record.dart';
import '../utils/theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _fromDate = '';
  String _toDate = '';
  AttendanceStatus? _statusFilter;
  String _studentFilter = '';
  final _studentCtrl = TextEditingController();

  @override
  void dispose() {
    _studentCtrl.dispose();
    super.dispose();
  }

  String _displayDate(String dateStr) {
    try {
      return DateFormat('d MMM yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  List<AttendanceRecord> _filtered(AppProvider app) {
    return app.attendanceRecords.where((r) {
      if (_fromDate.isNotEmpty && r.date.compareTo(_fromDate) < 0) return false;
      if (_toDate.isNotEmpty && r.date.compareTo(_toDate) > 0) return false;
      if (_statusFilter != null && r.status != _statusFilter) return false;
      if (_studentFilter.isNotEmpty) {
        final student = app.students.firstWhere(
          (s) => s.id == r.studentId,
          orElse: () => app.students.first,
        );
        if (!student.name.toLowerCase().contains(_studentFilter.toLowerCase())) return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate.isNotEmpty ? DateTime.parse(_fromDate) : DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _fromDate = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate.isNotEmpty ? DateTime.parse(_toDate) : DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _toDate = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  void _clearFilters() {
    setState(() {
      _fromDate = '';
      _toDate = '';
      _statusFilter = null;
      _studentFilter = '';
      _studentCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final records = _filtered(app);
    final hasFilters = _fromDate.isNotEmpty || _toDate.isNotEmpty || _statusFilter != null || _studentFilter.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            Text(
              '${records.length} record${records.length != 1 ? 's' : ''}',
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
            ),
          ],
        ),
        actions: [
          if (hasFilters)
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Clear', style: TextStyle(fontSize: 12)),
            ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Export CSV',
            onPressed: () {
              final csv = app.exportCSV();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('CSV ready (${csv.split('\n').length - 1} records)'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // From date
                _filterChip(
                  label: _fromDate.isEmpty ? 'From date' : _displayDate(_fromDate),
                  icon: Icons.calendar_today_rounded,
                  active: _fromDate.isNotEmpty,
                  onTap: _pickFromDate,
                ),
                const SizedBox(width: 8),
                // To date
                _filterChip(
                  label: _toDate.isEmpty ? 'To date' : _displayDate(_toDate),
                  icon: Icons.event_rounded,
                  active: _toDate.isNotEmpty,
                  onTap: _pickToDate,
                ),
                const SizedBox(width: 8),
                // Status filter
                PopupMenuButton<AttendanceStatus?>(
                  child: _filterChipWidget(
                    label: _statusFilter == null ? 'All status' : _statusFilter!.label,
                    icon: Icons.filter_list_rounded,
                    active: _statusFilter != null,
                  ),
                  onSelected: (v) => setState(() => _statusFilter = v),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: null, child: Text('All status')),
                    ...AttendanceStatus.values.map(
                      (s) => PopupMenuItem(value: s, child: Text(s.label)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Student search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _studentCtrl,
              decoration: InputDecoration(
                hintText: 'Search by student name...',
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                ),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 13),
              onChanged: (v) => setState(() => _studentFilter = v),
            ),
          ),

          // Records list
          Expanded(
            child: records.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.history_rounded, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          hasFilters ? 'No records match your filters.' : 'No attendance records yet.',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      final student = app.students.firstWhere(
                        (s) => s.id == record.studentId,
                        orElse: () => app.students.isNotEmpty ? app.students.first : throw Exception(),
                      );
                      // Group header
                      final isNewDay = index == 0 || records[index - 1].date != record.date;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isNewDay)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
                              child: Text(
                                _displayDate(record.date),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                ),
                              ),
                            ),
                          Card(
                            margin: const EdgeInsets.only(bottom: 6),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              child: Row(
                                children: [
                                  Icon(statusIcon(record.status), color: statusColor(record.status), size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(student.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                        Text(record.studentId, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), fontFamily: 'monospace')),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: statusBgColor(record.status),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          record.status.label,
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusTextColor(record.status)),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        record.timestamp,
                                        style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({required String label, required IconData icon, required bool active, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: _filterChipWidget(label: label, icon: icon, active: active),
    );
  }

  Widget _filterChipWidget({required String label, required IconData icon, required bool active}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? kIndigo.withOpacity(0.1) : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? kIndigo.withOpacity(0.4) : Theme.of(context).colorScheme.outline.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: active ? kIndigo : Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: active ? kIndigo : Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}
