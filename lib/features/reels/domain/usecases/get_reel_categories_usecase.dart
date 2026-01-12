import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/reel_category_model.dart';
import '../repositories/reels_repository.dart';

class GetReelCategoriesUseCase {
  final ReelsRepository repository;

  GetReelCategoriesUseCase(this.repository);

  Future<Either<Failure, List<ReelCategoryModel>>> call() async {
    return await repository.getReelCategoriesWithReels();
  }
}
