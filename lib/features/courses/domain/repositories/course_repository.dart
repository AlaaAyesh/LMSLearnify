import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/course.dart';

abstract class CourseRepository {
  Future<Either<Failure, List<Course>>> getCourses({
    int? page,
    int? perPage,
    int? categoryId,
    int? specialtyId,
  });

  Future<Either<Failure, Course>> getCourseById({required int id});

  Future<Either<Failure, List<Course>>> getMyCourses();
}




