// lib/models/attendance_record.dart
enum AttendanceStatus { present, absent, late, leave }

extension StatusLabel on AttendanceStatus {
  String get label {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.leave:
        return 'Leave';
    }
  }

  String get value => name; // 'present', 'absent', etc.
}

class AttendanceRecord {
  final String date; // YYYY-MM-DD
  final String studentId;
  final AttendanceStatus status;
  final String timestamp; // HH:MM:SS AM/PM

  AttendanceRecord({
    required this.date,
    required this.studentId,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'studentId': studentId,
        'status': status.name,
        'timestamp': timestamp,
      };

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
        date: json['date'],
        studentId: json['studentId'],
        status: AttendanceStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => AttendanceStatus.present,
        ),
        timestamp: json['timestamp'],
      );
}
