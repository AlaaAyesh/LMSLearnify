import '../../domain/entities/category_course_block.dart';
import 'category_model.dart';
import 'course_model.dart';

class CategoryCourseBlockModel extends CategoryCourseBlock {
  const CategoryCourseBlockModel({
    required super.category,
    required super.courses,
  });

  factory CategoryCourseBlockModel.fromJson(Map<String, dynamic> json) {
    final category = CategoryModel.fromJson(json);

    final courses = json['courses'] != null && json['courses'] is List
        ? (json['courses'] as List)
        .map((c) => CourseModel.fromJson(c as Map<String, dynamic>))
        .toList()
        : <CourseModel>[];

    return CategoryCourseBlockModel(
      category: category,
      courses: courses,
    );
  }

  Map<String, dynamic> toJson() {
    final categoryJson = (category as CategoryModel).toJson();
    return {
      ...categoryJson,
      'courses': courses.map((c) => (c as CourseModel).toJson()).toList(),
      'courses_count': courses.length,
    };
  }
}
