import 'package:equatable/equatable.dart';

abstract class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactionsEvent extends TransactionsEvent {
  final bool refresh;

  const LoadTransactionsEvent({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class LoadMoreTransactionsEvent extends TransactionsEvent {
  const LoadMoreTransactionsEvent();
}

class RefreshTransactionsEvent extends TransactionsEvent {
  const RefreshTransactionsEvent();
}

class ClearTransactionsStateEvent extends TransactionsEvent {
  const ClearTransactionsStateEvent();
}
