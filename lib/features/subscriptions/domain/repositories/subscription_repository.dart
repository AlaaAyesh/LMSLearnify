import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/subscription_model.dart';
import '../entities/subscription.dart';

abstract class SubscriptionRepository {
  /// Get all available subscriptions
  Future<Either<Failure, List<Subscription>>> getSubscriptions();

  /// Get a specific subscription by its ID
  Future<Either<Failure, Subscription>> getSubscriptionById({required int id});

  /// Create a new subscription
  Future<Either<Failure, Subscription>> createSubscription({
    required CreateSubscriptionRequest request,
  });

  /// Update an existing subscription
  Future<Either<Failure, Subscription>> updateSubscription({
    required int id,
    required UpdateSubscriptionRequest request,
  });
}


