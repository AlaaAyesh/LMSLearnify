import 'package:equatable/equatable.dart';
import 'transaction.dart';

class TransactionsResponse extends Equatable {
  final List<Transaction> transactions;
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final String? nextPageUrl;
  final String? prevPageUrl;

  const TransactionsResponse({
    required this.transactions,
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  bool get hasMore => currentPage < lastPage;
  bool get hasNextPage => nextPageUrl != null && nextPageUrl!.isNotEmpty;
  bool get hasPrevPage => prevPageUrl != null && prevPageUrl!.isNotEmpty;

  @override
  List<Object?> get props => [
        transactions,
        total,
        perPage,
        currentPage,
        lastPage,
        nextPageUrl,
        prevPageUrl,
      ];
}
