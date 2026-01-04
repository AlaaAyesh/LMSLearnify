import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/lesson.dart';

abstract class LessonRepository {
  /// Get lesson details by ID
  Future<Either<Failure, Lesson>> getLessonById({required int id});

  /// Mark lesson as viewed
  Future<Either<Failure, void>> markLessonAsViewed({required int id});
}

