import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/reel_category_model.dart';
import '../../data/models/reels_feed_response_model.dart';

abstract class ReelsRepository {
  /// Get reels feed with pagination
  /// [perPage] - Number of reels per page
  /// [cursor] - Cursor for pagination (null for first page) - deprecated, use nextPageUrl instead
  /// [nextPageUrl] - Full URL for next page from meta.next_page_url
  /// [categoryId] - Filter reels by category ID (optional)
  Future<Either<Failure, ReelsFeedResponseModel>> getReelsFeed({
    int perPage = 10,
    String? cursor,
    String? nextPageUrl,
    int? categoryId,
  });

  /// Record a view for a reel
  /// [reelId] - The ID of the reel being viewed
  Future<Either<Failure, void>> recordReelView(int reelId);

  /// Like a reel
  /// [reelId] - The ID of the reel to like
  Future<Either<Failure, void>> likeReel(int reelId);

  /// Unlike a reel
  /// [reelId] - The ID of the reel to unlike
  Future<Either<Failure, void>> unlikeReel(int reelId);

  /// Get reel categories with their reel counts
  /// Returns a list of categories with the number of reels in each category
  Future<Either<Failure, List<ReelCategoryModel>>> getReelCategoriesWithReels();

  /// Get user reels (reels created by a specific user)
  /// [userId] - The ID of the user whose reels to retrieve
  /// [perPage] - Number of reels per page (default: 10)
  /// [page] - Page number (default: 1)
  Future<Either<Failure, ReelsFeedResponseModel>> getUserReels({
    required int userId,
    int perPage = 10,
    int page = 1,
  });

  /// Get user liked reels (reels that a specific user has liked)
  /// [userId] - The ID of the user whose liked reels to retrieve
  /// [perPage] - Number of reels per page (default: 10)
  /// [page] - Page number (default: 1)
  Future<Either<Failure, ReelsFeedResponseModel>> getUserLikedReels({
    required int userId,
    int perPage = 10,
    int page = 1,
  });
}



