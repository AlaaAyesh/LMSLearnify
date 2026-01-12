import 'package:equatable/equatable.dart';
import 'category.dart';
import 'course.dart';

/// Represents a category with its associated courses
/// This matches the API structure: category_course_blocks
class CategoryCourseBlock extends Equatable {
  final Category category;
  final List<Course> courses;

  const CategoryCourseBlock({
    required this.category,
    required this.courses,
  });

  @override
  List<Object?> get props => [category, courses];
}
