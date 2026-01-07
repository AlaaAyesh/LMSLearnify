import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/lesson.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../datasources/lesson_remote_datasource.dart';

class LessonRepositoryImpl implements LessonRepository {
  final LessonRemoteDataSource remoteDataSource;

  LessonRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, Lesson>> getLessonById({required int id}) async {
    try {
      final lesson = await remoteDataSource.getLessonById(id);
      return Right(lesson);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markLessonAsViewed({required int id}) async {
    try {
      await remoteDataSource.markLessonAsViewed(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }
}



