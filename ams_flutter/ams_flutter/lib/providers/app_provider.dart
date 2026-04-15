// lib/providers/app_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student.dart';
import '../models/attendance_record.dart';

const _initialStudents = [
  {'id': 'STU001', 'name': 'Aarav Sharma', 'email': 'aarav@example.com'},
  {'id': 'STU002', 'name': 'Priya Nair', 'email': 'priya@example.com'},
  {'id': 'STU003', 'name': 'Rohan Mehta', 'email': 'rohan@example.com'},
  {'id': 'STU004', 'name': 'Sneha Iyer', 'email': 'sneha@example.com'},
  {'id': 'STU005', 'name': 'Kiran Das', 'email': 'kiran@example.com'},
];

final _initialRecords = [
  // Apr 9
  {'date': '2026-04-09', 'studentId': 'STU001', 'status': 'present', 'timestamp': '09:00:00 AM'},
  {'date': '2026-04-09', 'studentId': 'STU002', 'status': 'present', 'timestamp': '09:00:00 AM'},
  {'date': '2026-04-09', 'studentId': 'STU003', 'status': 'present', 'timestamp': '09:00:00 AM'},
  {'date': '2026-04-09', 'studentId': 'STU004', 'status': 'absent', 'timestamp': '09:00:00 AM'},
  {'date': '2026-04-09', 'studentId': 'STU005', 'status': 'present', 'timestamp': '09:00:00 AM'},
  // Apr 10
  {'date': '2026-04-10', 'studentId': 'STU001', 'status': 'present', 'timestamp': '09:02:00 AM'},
  {'date': '2026-04-10', 'studentId': 'STU002', 'status': 'late', 'timestamp': '09:18:00 AM'},
  {'date': '2026-04-10', 'studentId': 'STU003', 'status': 'present', 'timestamp': '09:02:00 AM'},
  {'date': '2026-04-10', 'studentId': 'STU004', 'status': 'present', 'timestamp': '09:02:00 AM'},
  {'date': '2026-04-10', 'studentId': 'STU005', 'status': 'absent', 'timestamp': '09:02:00 AM'},
  // Apr 11
  {'date': '2026-04-11', 'studentId': 'STU001', 'status': 'present', 'timestamp': '08:58:00 AM'},
  {'date': '2026-04-11', 'studentId': 'STU002', 'status': 'present', 'timestamp': '08:58:00 AM'},
  {'date': '2026-04-11', 'studentId': 'STU003', 'status': 'late', 'timestamp': '09:15:00 AM'},
  {'date': '2026-04-11', 'studentId': 'STU004', 'status': 'present', 'timestamp': '08:58:00 AM'},
  {'date': '2026-04-11', 'studentId': 'STU005', 'status': 'leave', 'timestamp': '08:58:00 AM'},
  // Apr 12
  {'date': '2026-04-12', 'studentId': 'STU001', 'status': 'present', 'timestamp': '09:00:00 AM'},
  {'date': '2026-04-12', 'studentId': 'STU002', 'status': 'absent', 'timestamp': '09:00:00 AM'},
  {'date': '2026-04-12', 'studentId': 'STU003', 'status': 'present', 'timestamp': '09:00:00 AM'},
  {'date': '2026-04-12', 'studentId': 'STU004', 'status': 'present', 'timestamp': '09:00:00 AM'},
  {'date': '2026-04-12', 'studentId': 'STU005', 'status': 'late', 'timestamp': '09:20:00 AM'},
  // Apr 13
  {'date': '2026-04-13', 'studentId': 'STU001', 'status': 'present', 'timestamp': '09:00:00 AM'},
  {'date': '2026-04-13', 'studentId': 'STU002', 'status': 'present', 'timestamp': '09:00:00 AM'},
  {'date': '2026-04-13', 'studentId': 'STU003', 'status': 'absent', 'timestamp': '09:00:00 AM'},
  {'date': '2026-04-13', 'studentId': 'STU004', 'status': 'leave', 'timestamp': '09:00:00 AM'},
  {'date': '2026-04-13', 'studentId': 'STU005', 'status': 'present', 'timestamp': '09:00:00 AM'},
  // Apr 14
  {'date': '2026-04-14', 'studentId': 'STU001', 'status': 'late', 'timestamp': '09:25:00 AM'},
  {'date': '2026-04-14', 'studentId': 'STU002', 'status': 'present', 'timestamp': '09:00:00 AM'},
  {'date': '2026-04-14', 'studentId': 'STU003', 'status': 'present', 'timestamp': '09:00:00 AM'},
  {'date': '2026-04-14', 'studentId': 'STU004', 'status': 'present', 'timestamp': '09:00:00 AM'},
  {'date': '2026-04-14', 'studentId': 'STU005', 'status': 'present', 'timestamp': '09:00:00 AM'},
  // Apr 15
  {'date': '2026-04-15', 'studentId': 'STU001', 'status': 'present', 'timestamp': '09:00:00 AM'},
  {'date': '2026-04-15', 'studentId': 'STU002', 'status': 'present', 'timestamp': '09:00:00 AM'},
  {'date': '2026-04-15', 'studentId': 'STU003', 'status': 'absent', 'timestamp': '09:00:00 AM'},
  {'date': '2026-04-15', 'studentId': 'STU004', 'status': 'late', 'timestamp': '09:18:00 AM'},
  {'date': '2026-04-15', 'studentId': 'STU005', 'status': 'present', 'timestamp': '09:00:00 AM'},
];

class AppProvider extends ChangeNotifier {
  List<Student> _students = [];
  List<AttendanceRecord> _records = [];
  bool _darkMode = false;
  bool _initialized = false;

  List<Student> get students => List.unmodifiable(_students);
  List<AttendanceRecord> get attendanceRecords => List.unmodifiable(_records);
  bool get darkMode => _darkMode;

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();

    // Load dark mode
    _darkMode = prefs.getBool('darkMode') ?? false;

    // Load students
    final stuJson = prefs.getString('students');
    if (stuJson != null) {
      final list = jsonDecode(stuJson) as List;
      _students = list.map((e) => Student.fromJson(e)).toList();
    } else {
      _students = _initialStudents.map((e) => Student.fromJson(e)).toList();
    }

    // Load records
    final recJson = prefs.getString('records');
    if (recJson != null) {
      final list = jsonDecode(recJson) as List;
      _records = list.map((e) => AttendanceRecord.fromJson(e)).toList();
    } else {
      _records = _initialRecords.map((e) => AttendanceRecord.fromJson(e)).toList();
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> _saveStudents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('students', jsonEncode(_students.map((e) => e.toJson()).toList()));
  }

  Future<void> _saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('records', jsonEncode(_records.map((e) => e.toJson()).toList()));
  }

  // ─── Students ────────────────────────────────────────────────────────────────

  void addStudent(String name, String email) {
    final maxNum = _students.fold<int>(0, (max, s) {
      final n = int.tryParse(s.id.replaceAll('STU', '')) ?? 0;
      return n > max ? n : max;
    });
    final newId = 'STU${(maxNum + 1).toString().padLeft(3, '0')}';
    _students = [..._students, Student(id: newId, name: name, email: email)];
    _saveStudents();
    notifyListeners();
  }

  void deleteStudent(String id) {
    _students = _students.where((s) => s.id != id).toList();
    _records = _records.where((r) => r.studentId != id).toList();
    _saveStudents();
    _saveRecords();
    notifyListeners();
  }

  // ─── Attendance ──────────────────────────────────────────────────────────────

  void saveAttendanceForDate(String date, Map<String, AttendanceStatus> statusMap) {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    final second = now.second;
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final timestamp =
        '${h.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')} $period';

    final newRecords = statusMap.entries.map((e) => AttendanceRecord(
          date: date,
          studentId: e.key,
          status: e.value,
          timestamp: timestamp,
        ));

    _records = [
      ..._records.where((r) => r.date != date),
      ...newRecords,
    ];
    _saveRecords();
    notifyListeners();
  }

  // ─── Settings ────────────────────────────────────────────────────────────────

  Future<void> toggleDarkMode() async {
    _darkMode = !_darkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _darkMode);
    notifyListeners();
  }

  Future<void> factoryReset() async {
    _students = _initialStudents.map((e) => Student.fromJson(e)).toList();
    _records = _initialRecords.map((e) => AttendanceRecord.fromJson(e)).toList();
    await _saveStudents();
    await _saveRecords();
    notifyListeners();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  Map<AttendanceStatus, int> statsForDate(String date) {
    final dayRecords = _records.where((r) => r.date == date).toList();
    return {
      AttendanceStatus.present: dayRecords.where((r) => r.status == AttendanceStatus.present).length,
      AttendanceStatus.absent: dayRecords.where((r) => r.status == AttendanceStatus.absent).length,
      AttendanceStatus.late: dayRecords.where((r) => r.status == AttendanceStatus.late).length,
      AttendanceStatus.leave: dayRecords.where((r) => r.status == AttendanceStatus.leave).length,
    };
  }

  List<Student> studentsWithStatus(String date, AttendanceStatus status) {
    final ids = _records
        .where((r) => r.date == date && r.status == status)
        .map((r) => r.studentId)
        .toSet();
    return _students.where((s) => ids.contains(s.id)).toList();
  }

  String exportCSV() {
    final headers = ['Date', 'Student ID', 'Name', 'Status', 'Timestamp'];
    final rows = _records.map((r) {
      final student = _students.firstWhere(
        (s) => s.id == r.studentId,
        orElse: () => Student(id: r.studentId, name: 'Unknown', email: ''),
      );
      return [r.date, r.studentId, student.name, r.status.label, r.timestamp].join(',');
    });
    return [headers.join(','), ...rows].join('\n');
  }
}
