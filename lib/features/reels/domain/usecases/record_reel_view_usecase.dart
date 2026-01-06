import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/reels_repository.dart';

class RecordReelViewUseCase {
  final ReelsRepository repository;

  RecordReelViewUseCase(this.repository);

  Future<Either<Failure, void>> call(int reelId) async {
    return await repository.recordReelView(reelId);
  }
}

