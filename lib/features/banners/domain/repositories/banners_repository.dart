import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/banner.dart';
import '../../data/models/banners_response_model.dart';

abstract class BannersRepository {
  /// Get site banners with optional filters
  Future<Either<Failure, BannersResponseModel>> getSiteBanners({
    int perPage = 10,
    int page = 1,
    String? fromDate,
    String? toDate,
    String? search,
  });

  /// Record a click on a banner
  Future<Either<Failure, void>> recordBannerClick(int bannerId);
}
