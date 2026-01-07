import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_remote_datasource.dart';
import '../models/payment_model.dart';
import '../models/subscription_model.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource remoteDataSource;

  SubscriptionRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<Subscription>>> getSubscriptions() async {
    try {
      final subscriptions = await remoteDataSource.getSubscriptions();
      return Right(subscriptions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, Subscription>> getSubscriptionById({
    required int id,
  }) async {
    try {
      final subscription = await remoteDataSource.getSubscriptionById(id);
      return Right(subscription);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, Subscription>> createSubscription({
    required CreateSubscriptionRequest request,
  }) async {
    try {
      final subscription = await remoteDataSource.createSubscription(request);
      return Right(subscription);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, Subscription>> updateSubscription({
    required int id,
    required UpdateSubscriptionRequest request,
  }) async {
    try {
      final subscription = await remoteDataSource.updateSubscription(id, request);
      return Right(subscription);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, PaymentResponseModel>> processPayment({
    required ProcessPaymentRequest request,
  }) async {
    try {
      final response = await remoteDataSource.processPayment(request);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }
}


