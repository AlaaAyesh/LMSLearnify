import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/chapter.dart';

abstract class ChapterRepository {
  /// Get chapter details by ID (including course info and lessons)
  Future<Either<Failure, Chapter>> getChapterById({required int id});
}



