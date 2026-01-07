import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/subscription_model.dart';
import '../entities/subscription.dart';
import '../repositories/subscription_repository.dart';

class CreateSubscriptionUseCase {
  final SubscriptionRepository repository;

  CreateSubscriptionUseCase(this.repository);

  Future<Either<Failure, Subscription>> call({
    required CreateSubscriptionRequest request,
  }) async {
    return await repository.createSubscription(request: request);
  }
}




