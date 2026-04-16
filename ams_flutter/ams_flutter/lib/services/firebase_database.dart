// lib/services/firebase_database.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDatabaseService {
  // Singleton pattern
  static final FirebaseDatabaseService _instance =
      FirebaseDatabaseService._internal();
  factory FirebaseDatabaseService() => _instance;
  FirebaseDatabaseService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==============================================
  // BASIC WRITE OPERATIONS
  // ==============================================

  /// Add a new student
  Future<String> addStudent(Map<String, dynamic> studentData) async {
    try {
      DocumentReference doc = await _db.collection('students').add(studentData);
      return doc.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Record attendance entry
  Future<void> markAttendance(
      String studentId, bool isPresent, DateTime date) async {
    try {
      await _db.collection('attendance').add({
        'studentId': studentId,
        'isPresent': isPresent,
        'date': date,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // ==============================================
  // BASIC READ OPERATIONS
  // ==============================================

  /// Get all students once
  Future<List<Map<String, dynamic>>> getAllStudents() async {
    try {
      QuerySnapshot snapshot = await _db.collection('students').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        if (data == null || data is! Map<String, dynamic>) {
          return {
            'id': doc.id,
            'error': 'Invalid data format: ${data.runtimeType}'
          };
        }
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get realtime stream of students
  Stream<List<Map<String, dynamic>>> studentsStream() {
    return _db.collection('students').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    });
  }

  /// Get attendance history for specific student
  Future<List<Map<String, dynamic>>> getStudentAttendance(
      String studentId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('attendance')
          .where('studentId', isEqualTo: studentId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        if (data == null || data is! Map<String, dynamic>) {
          return {
            'id': doc.id,
            'error': 'Invalid data format: ${data.runtimeType}'
          };
        }
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // ==============================================
  // UPDATE OPERATION
  // ==============================================

  /// Update existing student
  Future<void> updateStudent(
      String studentId, Map<String, dynamic> updatedData) async {
    try {
      await _db.collection('students').doc(studentId).update(updatedData);
    } catch (e) {
      rethrow;
    }
  }

  // ==============================================
  // DELETE OPERATION
  // ==============================================

  /// Delete student
  Future<void> deleteStudent(String studentId) async {
    try {
      await _db.collection('students').doc(studentId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // ==============================================
  // EXAMPLE QUERY OPERATIONS
  // ==============================================

  /// Get students by class
  Future<List<Map<String, dynamic>>> getStudentsByClass(
      String className) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('students')
          .where('className', isEqualTo: className)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        if (data == null || data is! Map<String, dynamic>) {
          return {
            'id': doc.id,
            'error': 'Invalid data format: ${data.runtimeType}'
          };
        }
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get attendance for specific date
  Future<List<Map<String, dynamic>>> getAttendanceForDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59);

    try {
      QuerySnapshot snapshot = await _db
          .collection('attendance')
          .where('date', isGreaterThanOrEqualTo: start)
          .where('date', isLessThanOrEqualTo: end)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        if (data == null || data is! Map<String, dynamic>) {
          return {
            'id': doc.id,
            'error': 'Invalid data format: ${data.runtimeType}'
          };
        }
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}
