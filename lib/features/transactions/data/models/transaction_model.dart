import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.userId,
    required super.purchasableType,
    super.purchasableName,
    required super.purchasableId,
    required super.amount,
    required super.currency,
    super.transactionId,
    required super.paymentService,
    required super.status,
    super.receiptPath,
    super.receiptUrl,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      purchasableType: json['purchasable_type'] as String? ?? '',
      purchasableName: json['purchasable_name'] as String?,
      purchasableId: json['purchasable_id'] as int? ?? 0,
      amount: json['amount']?.toString() ?? '0',
      currency: json['currency'] as String? ?? 'EGP',
      transactionId: json['transaction_id'] as String?,
      paymentService: json['payment_service'] as String? ?? 'kashier',
      status: json['status'] as String? ?? 'pending',
      receiptPath: json['receipt_path'] as String?,
      receiptUrl: json['receipt_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'purchasable_type': purchasableType,
      'purchasable_name': purchasableName,
      'purchasable_id': purchasableId,
      'amount': amount,
      'currency': currency,
      'transaction_id': transactionId,
      'payment_service': paymentService,
      'status': status,
      'receipt_path': receiptPath,
      'receipt_url': receiptUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
