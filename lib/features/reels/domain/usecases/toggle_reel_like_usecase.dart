import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/reels_repository.dart';

class ToggleReelLikeUseCase {
  final ReelsRepository repository;

  ToggleReelLikeUseCase(this.repository);

  /// Toggle like status for a reel
  /// [reelId] - The ID of the reel
  /// [isCurrentlyLiked] - Current like status (true = liked, false = not liked)
  /// Returns the new like status after toggling
  Future<Either<Failure, bool>> call({
    required int reelId,
    required bool isCurrentlyLiked,
  }) async {
    if (isCurrentlyLiked) {
      // Currently liked, so unlike it
      final result = await repository.unlikeReel(reelId);
      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(false), // New status: not liked
      );
    } else {
      // Currently not liked, so like it
      final result = await repository.likeReel(reelId);
      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(true), // New status: liked
      );
    }
  }
}

