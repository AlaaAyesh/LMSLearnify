import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/payment_model.dart';
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

  /// Process a payment for a subscription or course
  Future<Either<Failure, PaymentResponseModel>> processPayment({
    required ProcessPaymentRequest request,
  });

  /// Validate a coupon code for a subscription
  Future<Either<Failure, Map<String, dynamic>>> validateCoupon({
    required String code,
    required String type,
    required int id,
  });

  /// Verify In-App Purchase receipt (Google / Apple)
  Future<Either<Failure, Unit>> verifyIapReceipt({
    required String receiptData,
    required String transactionId,
    required int purchaseId,
    required String store, // gplay | iap
  });

  /// Get user transactions
  Future<Either<Failure, TransactionsResponseModel>> getMyTransactions({
    int page = 1,
    int perPage = 10,
  });

}


