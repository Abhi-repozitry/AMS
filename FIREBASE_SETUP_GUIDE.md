# 🚀 Firebase Complete Setup Guide for AMS Flutter App

---

## ✅ Step 1: Install Dependencies
Run this command to install Firebase packages:
```bash
cd ams_flutter/ams_flutter
flutter pub get
```

---

## ✅ Step 2: Setup Firebase Console Project

1.  Go to https://console.firebase.google.com
2.  Click **Add Project**
3.  Enter project name: `AMS Attendance System`
4.  Disable Google Analytics (not required)
5.  Click **Create Project**

### Add Android App:
1.  Click **Android** icon
2.  Enter Android package name: `com.example.ams_flutter`
3.  Enter App nickname: `AMS Flutter`
4.  Click **Register App**
5.  Download `google-services.json` file
6.  Place file in: `ams_flutter/ams_flutter/android/app/`

---

## ✅ Step 3: Android Configuration

### Update `android/build.gradle`:
```gradle
buildscript {
  dependencies {
    // Add this line
    classpath 'com.google.gms:google-services:4.4.2'
  }
}
```

### Update `android/app/build.gradle`:
Add at the **bottom** of the file:
```gradle
apply plugin: 'com.google.gms.google-services'
```

---

## ✅ Step 4: Enable Firestore Database

1.  In Firebase Console go to **Build > Firestore Database**
2.  Click **Create Database**
3.  Select location
4.  Select **Start in test mode** (for development)
5.  Click **Enable**

---

## ✅ Step 5: Usage Examples

### 🔹 Write Data (Add Student)
```dart
String newStudentId = await FirebaseDatabaseService().addStudent({
  'name': 'John Doe',
  'rollNumber': '101',
  'className': 'Class 10',
  'email': 'john@example.com',
  'phone': '1234567890',
});
```

### 🔹 Read Data (Get All Students)
```dart
List<Map<String, dynamic>> students = await FirebaseDatabaseService().getAllStudents();
```

### 🔹 Real-Time Updates
```dart
StreamBuilder(
  stream: FirebaseDatabaseService().studentsStream(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      List students = snapshot.data;
      // Build your UI
    }
  }
)
```

### 🔹 Mark Attendance
```dart
await FirebaseDatabaseService().markAttendance(
  'student_id_here',
  true, // present
  DateTime.now(),
);
```

### 🔹 Update Student
```dart
await FirebaseDatabaseService().updateStudent('student_id', {
  'name': 'Updated Name',
  'phone': '9876543210',
});
```

### 🔹 Delete Student
```dart
await FirebaseDatabaseService().deleteStudent('student_id');
```

---

## ✅ Step 6: Run the App
```bash
flutter run
```

---

## 📂 Files Modified:
✅ `pubspec.yaml` - Added Firebase dependencies
✅ `lib/main.dart` - Added Firebase initialization
✅ Created `lib/services/firebase_database.dart` - Complete database service

All basic CRUD operations are ready for your attendance system. The service uses singleton pattern for optimal performance.