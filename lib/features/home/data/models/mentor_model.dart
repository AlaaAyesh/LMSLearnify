import '../../domain/entities/mentor.dart';

class MentorModel extends Mentor {
  const MentorModel({
    required super.id,
    required super.name,
    super.email,
    super.avatarUrl,
    super.coursesCount,
    super.studentsCount,
    super.rating,
  });

  factory MentorModel.fromJson(Map<String, dynamic> json) {
    return MentorModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      coursesCount: _parseNullableInt(json['courses_count']),
      studentsCount: _parseNullableInt(json['students_count']),
      rating: json['rating']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'courses_count': coursesCount,
      'students_count': studentsCount,
      'rating': rating,
    };
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}

