import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/course.dart';
import '../repositories/course_repository.dart';

class GetCourseByIdUseCase {
  final CourseRepository repository;

  GetCourseByIdUseCase(this.repository);

  Future<Either<Failure, Course>> call({required int id}) async {
    return await repository.getCourseById(id: id);
  }
}


