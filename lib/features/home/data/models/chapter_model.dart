import '../../domain/entities/chapter.dart';
import 'lesson_model.dart';

/// Model for course info embedded in chapter response
class ChapterCourseInfoModel extends ChapterCourseInfo {
  const ChapterCourseInfoModel({
    required super.id,
    required super.nameAr,
    required super.nameEn,
  });

  factory ChapterCourseInfoModel.fromJson(Map<String, dynamic> json) {
    return ChapterCourseInfoModel(
      id: _parseInt(json['id']),
      nameAr: json['name_ar']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
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
      'name_ar': nameAr,
      'name_en': nameEn,
    };
  }
}

class ChapterModel extends Chapter {
  const ChapterModel({
    required super.id,
    required super.courseId,
    required super.nameAr,
    required super.nameEn,
    super.lessons,
    super.course,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: _parseInt(json['id']),
      courseId: _parseInt(json['course_id']),
      nameAr: json['name_ar']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      lessons: json['lessons'] != null
          ? (json['lessons'] as List)
          .map((l) => LessonModel.fromJson(l))
          .toList()
          : [],
      course: json['course'] != null && json['course'] is Map
          ? ChapterCourseInfoModel.fromJson(json['course'])
          : null,
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
      'course_id': courseId,
      'name_ar': nameAr,
      'name_en': nameEn,
      'lessons': lessons.map((l) => (l as LessonModel).toJson()).toList(),
      'course': course != null ? (course as ChapterCourseInfoModel).toJson() : null,
    };
  }
}



