import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/payment_model.dart';
import '../../data/models/subscription_model.dart';
import '../entities/subscription.dart';

abstract class SubscriptionRepository {
  Future<Either<Failure, List<Subscription>>> getSubscriptions();

  Future<Either<Failure, Subscription>> getSubscriptionById({required int id});

  Future<Either<Failure, Subscription>> createSubscription({
    required CreateSubscriptionRequest request,
  });

  Future<Either<Failure, Subscription>> updateSubscription({
    required int id,
    required UpdateSubscriptionRequest request,
  });

  Future<Either<Failure, PaymentResponseModel>> processPayment({
    required ProcessPaymentRequest request,
  });

  Future<Either<Failure, Map<String, dynamic>>> validateCoupon({
    required String code,
    required String type,
    required int id,
  });

  Future<Either<Failure, Unit>> verifyIapReceipt({
    required String receiptData,
    required String transactionId,
    required int purchaseId,
    required String store,
  });

  Future<Either<Failure, TransactionsResponseModel>> getMyTransactions({
    int page = 1,
    int perPage = 10,
  });

}


