import 'package:equatable/equatable.dart';
import 'banner.dart';
import 'category.dart';
import 'category_course_block.dart';
import 'course.dart';
import 'mentor.dart';
import 'partner.dart';

class HomeData extends Equatable {
  final List<HomeBanner> banners;
  final List<Course> latestCourses;
  final List<Course> freeCourses;
  final List<Course> popularCourses;
  final List<Mentor> topMentors;
  final List<Partner> partners;
  final List<CategoryCourseBlock> categoryCourseBlocks;

  const HomeData({
    this.banners = const [],
    this.latestCourses = const [],
    this.freeCourses = const [],
    this.popularCourses = const [],
    this.topMentors = const [],
    this.partners = const [],
    this.categoryCourseBlocks = const [],
  });

  /// Get unique categories from all courses
  List<Category> get categories {
    final Map<int, Category> categoriesMap = {};
    
    // Add categories from category_course_blocks
    for (final block in categoryCourseBlocks) {
      categoriesMap[block.category.id] = block.category;
    }
    
    // Add categories from individual course lists
    for (final course in [...latestCourses, ...freeCourses, ...popularCourses]) {
      for (final category in course.categories) {
        categoriesMap[category.id] = category;
      }
    }
    
    return categoriesMap.values.toList();
  }

  /// Get courses grouped by category
  Map<Category, List<Course>> get coursesByCategory {
    final Map<int, Category> categoriesMap = {};
    final Map<int, List<Course>> coursesMap = {};
    
    final allCourses = [...latestCourses, ...freeCourses, ...popularCourses];
    
    for (final course in allCourses) {
      for (final category in course.categories) {
        categoriesMap[category.id] = category;
        coursesMap.putIfAbsent(category.id, () => []);
        if (!coursesMap[category.id]!.any((c) => c.id == course.id)) {
          coursesMap[category.id]!.add(course);
        }
      }
    }
    
    final result = <Category, List<Course>>{};
    for (final entry in categoriesMap.entries) {
      result[entry.value] = coursesMap[entry.key] ?? [];
    }
    
    return result;
  }

  @override
  List<Object?> get props => [
        banners,
        latestCourses,
        freeCourses,
        popularCourses,
        topMentors,
        partners,
        categoryCourseBlocks,
      ];
}



