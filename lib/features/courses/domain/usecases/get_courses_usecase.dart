import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/course.dart';
import '../repositories/course_repository.dart';

class GetCoursesUseCase {
  final CourseRepository repository;

  GetCoursesUseCase(this.repository);

  Future<Either<Failure, List<Course>>> call({
    int? page,
    int? perPage,
    int? categoryId,
    int? specialtyId,
  }) async {
    return await repository.getCourses(
      page: page,
      perPage: perPage,
      categoryId: categoryId,
      specialtyId: specialtyId,
    );
  }
}




