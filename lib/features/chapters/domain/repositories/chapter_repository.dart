import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/chapter.dart';

abstract class ChapterRepository {
  Future<Either<Failure, Chapter>> getChapterById({required int id});
}



