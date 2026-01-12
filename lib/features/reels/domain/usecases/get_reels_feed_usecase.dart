import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/reels_feed_response_model.dart';
import '../repositories/reels_repository.dart';

class GetReelsFeedUseCase {
  final ReelsRepository repository;

  GetReelsFeedUseCase(this.repository);

  Future<Either<Failure, ReelsFeedResponseModel>> call({
    int perPage = 10,
    String? cursor,
    String? nextPageUrl,
    int? categoryId,
  }) async {
    return await repository.getReelsFeed(
      perPage: perPage,
      cursor: cursor,
      nextPageUrl: nextPageUrl,
      categoryId: categoryId,
    );
  }
}



