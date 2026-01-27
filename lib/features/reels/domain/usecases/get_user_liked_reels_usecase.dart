import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/reels_feed_response_model.dart';
import '../../domain/repositories/reels_repository.dart';

class GetUserLikedReelsUseCase {
  final ReelsRepository repository;

  GetUserLikedReelsUseCase(this.repository);

  Future<Either<Failure, ReelsFeedResponseModel>> call({
    required int userId,
    int perPage = 10,
    int page = 1,
  }) async {
    return await repository.getUserLikedReels(
      userId: userId,
      perPage: perPage,
      page: page,
    );
  }
}
