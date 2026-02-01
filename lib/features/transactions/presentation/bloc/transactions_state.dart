import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';

abstract class TransactionsState extends Equatable {
  const TransactionsState();

  @override
  List<Object?> get props => [];
}

class TransactionsInitial extends TransactionsState {}

class TransactionsLoading extends TransactionsState {
  final List<Transaction>? cachedTransactions;

  const TransactionsLoading({this.cachedTransactions});

  @override
  List<Object?> get props => [cachedTransactions];
}

class TransactionsLoaded extends TransactionsState {
  final List<Transaction> transactions;
  final int total;
  final int currentPage;
  final int lastPage;
  final bool hasMore;
  final bool isLoadingMore;
  final String? nextPageUrl;

  const TransactionsLoaded({
    required this.transactions,
    required this.total,
    required this.currentPage,
    required this.lastPage,
    required this.hasMore,
    this.isLoadingMore = false,
    this.nextPageUrl,
  });

  TransactionsLoaded copyWith({
    List<Transaction>? transactions,
    int? total,
    int? currentPage,
    int? lastPage,
    bool? hasMore,
    bool? isLoadingMore,
    String? nextPageUrl,
  }) {
    return TransactionsLoaded(
      transactions: transactions ?? this.transactions,
      total: total ?? this.total,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      nextPageUrl: nextPageUrl ?? this.nextPageUrl,
    );
  }

  @override
  List<Object?> get props => [
        transactions,
        total,
        currentPage,
        lastPage,
        hasMore,
        isLoadingMore,
        nextPageUrl,
      ];
}

class TransactionsError extends TransactionsState {
  final String message;
  final List<Transaction>? cachedTransactions;

  const TransactionsError(this.message, {this.cachedTransactions});

  @override
  List<Object?> get props => [message, cachedTransactions];
}

class TransactionsEmpty extends TransactionsState {}
