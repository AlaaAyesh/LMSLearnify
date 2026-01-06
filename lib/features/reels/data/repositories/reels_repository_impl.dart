import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/reels_repository.dart';
import '../datasources/reels_remote_datasource.dart';
import '../models/reels_feed_response_model.dart';

class ReelsRepositoryImpl implements ReelsRepository {
  final ReelsRemoteDataSource remoteDataSource;

  ReelsRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, ReelsFeedResponseModel>> getReelsFeed({
    int perPage = 10,
    String? cursor,
  }) async {
    try {
      final response = await remoteDataSource.getReelsFeed(
        perPage: perPage,
        cursor: cursor,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> recordReelView(int reelId) async {
    try {
      await remoteDataSource.recordReelView(reelId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> likeReel(int reelId) async {
    try {
      await remoteDataSource.likeReel(reelId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> unlikeReel(int reelId) async {
    try {
      await remoteDataSource.unlikeReel(reelId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }
}

