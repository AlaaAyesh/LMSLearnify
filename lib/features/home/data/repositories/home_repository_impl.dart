import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/home_data.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, HomeData>> getHomeData() async {
    try {
      final homeData = await remoteDataSource.getHomeData();
      return Right(homeData);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }
}



