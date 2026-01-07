import '../../domain/entities/instructor.dart';

class InstructorModel extends Instructor {
  const InstructorModel({
    required super.id,
    required super.name,
    super.email,
    super.avatarUrl,
  });

  factory InstructorModel.fromJson(Map<String, dynamic> json) {
    return InstructorModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
    };
  }
}



