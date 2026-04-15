// lib/models/student.dart
class Student {
  final String id;
  final String name;
  final String email;

  Student({required this.id, required this.name, required this.email});

  Student copyWith({String? id, String? name, String? email}) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json['id'],
        name: json['name'],
        email: json['email'],
      );
}
