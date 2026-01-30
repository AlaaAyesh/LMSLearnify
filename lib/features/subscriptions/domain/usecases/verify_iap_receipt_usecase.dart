import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/subscription_repository.dart';

class VerifyIapReceiptUseCase {
  final SubscriptionRepository repository;

  VerifyIapReceiptUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String receiptData,
    required String transactionId,
    required int purchaseId,
    required String store,
  }) {
    return repository.verifyIapReceipt(
      receiptData: receiptData,
      transactionId: transactionId,
      purchaseId: purchaseId,
      store: store,
    );
  }
}
