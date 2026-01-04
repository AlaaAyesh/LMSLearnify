import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/home_data.dart';

abstract class HomeRepository {
  /// Get home page data (banners + latest courses)
  Future<Either<Failure, HomeData>> getHomeData();
}

