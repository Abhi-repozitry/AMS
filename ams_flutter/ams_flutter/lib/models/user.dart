// lib/models/user.dart

enum UserRole {
  admin,
  teacher,
  student,
}

class User {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String? department;
  final bool isAnonymous;

  const User({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.department,
    this.isAnonymous = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'],
      email: json['email'],
      name: json['name'],
      role: UserRole.values.byName(json['role']),
      department: json['department'],
      isAnonymous: json['isAnonymous'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role.name,
      'department': department,
      'isAnonymous': isAnonymous,
    };
  }
}
