import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final int id;
  final int userId;
  final String purchasableType;
  final String? purchasableName;
  final int purchasableId;
  final String amount;
  final String currency;
  final String? transactionId;
  final String paymentService;
  final String status;
  final String? receiptPath;
  final String? receiptUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Transaction({
    required this.id,
    required this.userId,
    required this.purchasableType,
    this.purchasableName,
    required this.purchasableId,
    required this.amount,
    required this.currency,
    this.transactionId,
    required this.paymentService,
    required this.status,
    this.receiptPath,
    this.receiptUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isSuccess => status == 'success';
  bool get isPending => status == 'pending';
  bool get isSubscription => purchasableType.contains('Subscription');

  @override
  List<Object?> get props => [
        id,
        userId,
        purchasableType,
        purchasableName,
        purchasableId,
        amount,
        currency,
        transactionId,
        paymentService,
        status,
        receiptPath,
        receiptUrl,
        createdAt,
        updatedAt,
      ];
}
