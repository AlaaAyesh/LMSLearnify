import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/banners_repository.dart';
import '../datasources/banners_remote_datasource.dart';
import '../models/banners_response_model.dart';

class BannersRepositoryImpl implements BannersRepository {
  final BannersRemoteDataSource remoteDataSource;

  BannersRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, BannersResponseModel>> getSiteBanners({
    int perPage = 10,
    int page = 1,
    String? fromDate,
    String? toDate,
    String? search,
  }) async {
    try {
      final response = await remoteDataSource.getSiteBanners(
        perPage: perPage,
        page: page,
        fromDate: fromDate,
        toDate: toDate,
        search: search,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> recordBannerClick(int bannerId) async {
    try {
      await remoteDataSource.recordBannerClick(bannerId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }
}
