import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/subscription.dart';
import '../repositories/subscription_repository.dart';

class GetSubscriptionByIdUseCase {
  final SubscriptionRepository repository;

  GetSubscriptionByIdUseCase(this.repository);

  Future<Either<Failure, Subscription>> call({required int id}) async {
    return await repository.getSubscriptionById(id: id);
  }
}


