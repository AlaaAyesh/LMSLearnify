import 'package:equatable/equatable.dart';
import 'category.dart';
import 'course.dart';

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
