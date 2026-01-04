import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/lesson_repository.dart';

class MarkLessonViewedUseCase {
  final LessonRepository repository;

  MarkLessonViewedUseCase(this.repository);

  Future<Either<Failure, void>> call({required int id}) async {
    return await repository.markLessonAsViewed(id: id);
  }
}

