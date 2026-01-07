import 'package:equatable/equatable.dart';
import 'lesson.dart';

/// Lightweight course info embedded in chapter response
class ChapterCourseInfo extends Equatable {
  final int id;
  final String nameAr;
  final String nameEn;

  const ChapterCourseInfo({
    required this.id,
    required this.nameAr,
    required this.nameEn,
  });

  String getName(String locale) => locale == 'ar' ? nameAr : nameEn;

  @override
  List<Object?> get props => [id, nameAr, nameEn];
}

class Chapter extends Equatable {
  final int id;
  final int courseId;
  final String nameAr;
  final String nameEn;
  final List<Lesson> lessons;
  final ChapterCourseInfo? course;

  const Chapter({
    required this.id,
    required this.courseId,
    required this.nameAr,
    required this.nameEn,
    this.lessons = const [],
    this.course,
  });

  String getName(String locale) => locale == 'ar' ? nameAr : nameEn;
  
  /// Get the course name (from embedded course info if available)
  String? getCourseName(String locale) => course?.getName(locale);

  @override
  List<Object?> get props => [id, courseId, nameAr, nameEn, lessons, course];
}



