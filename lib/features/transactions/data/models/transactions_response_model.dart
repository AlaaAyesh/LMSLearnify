import '../../domain/entities/transactions_response.dart';
import 'transaction_model.dart';

class TransactionsResponseModel extends TransactionsResponse {
  const TransactionsResponseModel({
    required super.transactions,
    required super.total,
    required super.perPage,
    required super.currentPage,
    required super.lastPage,
    super.nextPageUrl,
    super.prevPageUrl,
  });

  factory TransactionsResponseModel.fromJson(Map<String, dynamic> json) {
    final responseData = json['data'] as Map<String, dynamic>?;
    final data = responseData?['data'] as List<dynamic>? ?? [];
    final meta = responseData?['meta'] as Map<String, dynamic>? ?? {};

    return TransactionsResponseModel(
      transactions: data
          .map((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: meta['total'] as int? ?? 0,
      perPage: meta['per_page'] as int? ?? 10,
      currentPage: meta['current_page'] as int? ?? 1,
      lastPage: meta['last_page'] as int? ?? 1,
      nextPageUrl: meta['next_page_url']?.toString(),
      prevPageUrl: meta['prev_page_url']?.toString(),
    );
  }
}
