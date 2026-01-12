import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/banners_repository.dart';

class RecordBannerClickUseCase {
  final BannersRepository repository;

  RecordBannerClickUseCase(this.repository);

  Future<Either<Failure, void>> call(int bannerId) async {
    return await repository.recordBannerClick(bannerId);
  }
}
