import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/subscription_model.dart';
import '../entities/subscription.dart';
import '../repositories/subscription_repository.dart';

class UpdateSubscriptionUseCase {
  final SubscriptionRepository repository;

  UpdateSubscriptionUseCase(this.repository);

  Future<Either<Failure, Subscription>> call({
    required int id,
    required UpdateSubscriptionRequest request,
  }) async {
    return await repository.updateSubscription(id: id, request: request);
  }
}


