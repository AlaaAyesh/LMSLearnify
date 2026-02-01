import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transactions_response.dart';

abstract class TransactionsRepository {
  Future<Either<Failure, TransactionsResponse>> getMyTransactions({
    int? page,
    String? nextPageUrl,
  });
}
