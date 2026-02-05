import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/reel_category_model.dart';
import '../../data/models/reels_feed_response_model.dart';

abstract class ReelsRepository {
  Future<Either<Failure, ReelsFeedResponseModel>> getReelsFeed({
    int perPage = 10,
    String? cursor,
    String? nextPageUrl,
    int? categoryId,
  });

  Future<Either<Failure, void>> recordReelView(int reelId);

  Future<Either<Failure, void>> likeReel(int reelId);

  Future<Either<Failure, void>> unlikeReel(int reelId);

  Future<Either<Failure, List<ReelCategoryModel>>> getReelCategoriesWithReels();

  Future<Either<Failure, ReelsFeedResponseModel>> getUserReels({
    required int userId,
    int perPage = 10,
    int page = 1,
  });

  Future<Either<Failure, ReelsFeedResponseModel>> getUserLikedReels({
    required int userId,
    int perPage = 10,
    int page = 1,
  });
}



