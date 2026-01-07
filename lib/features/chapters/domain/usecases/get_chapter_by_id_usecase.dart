import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/chapter.dart';
import '../repositories/chapter_repository.dart';

class GetChapterByIdUseCase {
  final ChapterRepository repository;

  GetChapterByIdUseCase(this.repository);

  Future<Either<Failure, Chapter>> call({required int id}) async {
    return await repository.getChapterById(id: id);
  }
}



