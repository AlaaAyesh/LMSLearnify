import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/lesson.dart';

abstract class LessonRepository {
  Future<Either<Failure, Lesson>> getLessonById({required int id});

  Future<Either<Failure, void>> markLessonAsViewed({required int id});
}



