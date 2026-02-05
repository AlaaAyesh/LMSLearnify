import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/reels_repository.dart';

class ToggleReelLikeUseCase {
  final ReelsRepository repository;

  ToggleReelLikeUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required int reelId,
    required bool isCurrentlyLiked,
  }) async {
    if (isCurrentlyLiked) {
      final result = await repository.unlikeReel(reelId);
      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(false),
      );
    } else {
      final result = await repository.likeReel(reelId);
      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(true),
      );
    }
  }
}



