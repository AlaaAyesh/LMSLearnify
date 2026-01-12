import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/banners_repository.dart';
import '../../data/models/banners_response_model.dart';

class GetSiteBannersUseCase {
  final BannersRepository repository;

  GetSiteBannersUseCase(this.repository);

  Future<Either<Failure, BannersResponseModel>> call({
    int perPage = 10,
    int page = 1,
    String? fromDate,
    String? toDate,
    String? search,
  }) async {
    return await repository.getSiteBanners(
      perPage: perPage,
      page: page,
      fromDate: fromDate,
      toDate: toDate,
      search: search,
    );
  }
}
