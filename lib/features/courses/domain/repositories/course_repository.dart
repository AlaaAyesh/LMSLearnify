import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/course.dart';

abstract class CourseRepository {
  /// Get all available courses with optional filters
  Future<Either<Failure, List<Course>>> getCourses({
    int? page,
    int? perPage,
    int? categoryId,
    int? specialtyId,
  });

  /// Get a specific course by its ID
  Future<Either<Failure, Course>> getCourseById({required int id});

  /// Get user's enrolled courses
  Future<Either<Failure, List<Course>>> getMyCourses();
}




