import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transactions_response.dart';
import '../repositories/transactions_repository.dart';

class GetMyTransactionsUseCase {
  final TransactionsRepository repository;

  GetMyTransactionsUseCase(this.repository);

  Future<Either<Failure, TransactionsResponse>> call({
    int? page,
    String? nextPageUrl,
  }) async {
    return await repository.getMyTransactions(
      page: page,
      nextPageUrl: nextPageUrl,
    );
  }
}
