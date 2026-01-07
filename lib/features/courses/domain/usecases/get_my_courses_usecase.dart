import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/course.dart';
import '../repositories/course_repository.dart';

class GetMyCoursesUseCase {
  final CourseRepository repository;

  GetMyCoursesUseCase(this.repository);

  Future<Either<Failure, List<Course>>> call() async {
    return await repository.getMyCourses();
  }
}




