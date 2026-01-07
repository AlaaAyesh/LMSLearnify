import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/subscription.dart';
import '../repositories/subscription_repository.dart';

class GetSubscriptionsUseCase {
  final SubscriptionRepository repository;

  GetSubscriptionsUseCase(this.repository);

  Future<Either<Failure, List<Subscription>>> call() async {
    return await repository.getSubscriptions();
  }
}




