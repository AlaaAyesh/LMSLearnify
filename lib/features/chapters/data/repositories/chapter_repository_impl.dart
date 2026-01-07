import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/chapter.dart';
import '../../domain/repositories/chapter_repository.dart';
import '../datasources/chapter_remote_datasource.dart';

class ChapterRepositoryImpl implements ChapterRepository {
  final ChapterRemoteDataSource remoteDataSource;

  ChapterRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, Chapter>> getChapterById({required int id}) async {
    try {
      final chapter = await remoteDataSource.getChapterById(id);
      return Right(chapter);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }
}



