import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/lesson.dart';
import '../repositories/lesson_repository.dart';

class GetLessonByIdUseCase {
  final LessonRepository repository;

  GetLessonByIdUseCase(this.repository);

  Future<Either<Failure, Lesson>> call({required int id}) async {
    return await repository.getLessonById(id: id);
  }
}



