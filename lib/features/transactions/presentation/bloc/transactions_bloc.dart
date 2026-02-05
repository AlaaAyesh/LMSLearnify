import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_my_transactions_usecase.dart';
import 'transactions_event.dart';
import 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final GetMyTransactionsUseCase getMyTransactionsUseCase;

  int _currentPage = 1;
  String? _nextPageUrl;

  TransactionsBloc({
    required this.getMyTransactionsUseCase,
  }) : super(TransactionsInitial()) {
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<LoadMoreTransactionsEvent>(_onLoadMoreTransactions);
    on<RefreshTransactionsEvent>(_onRefreshTransactions);
    on<ClearTransactionsStateEvent>(_onClearState);
  }

  Future<void> _onLoadTransactions(
    LoadTransactionsEvent event,
    Emitter<TransactionsState> emit,
  ) async {
    if (event.refresh) {
      _currentPage = 1;
      _nextPageUrl = null;
    }

    final currentState = state;
    if (currentState is TransactionsLoaded && !event.refresh) {
      emit(TransactionsLoading(cachedTransactions: currentState.transactions));
    } else {
      emit(TransactionsLoading());
    }

    final result = await getMyTransactionsUseCase(
      page: event.refresh ? 1 : _currentPage,
      nextPageUrl: event.refresh ? null : _nextPageUrl,
    );

    result.fold(
      (failure) {
        final cachedTransactions = currentState is TransactionsLoaded
            ? currentState.transactions
            : null;
        emit(TransactionsError(failure.message, cachedTransactions: cachedTransactions));
      },
      (response) {
        _currentPage = response.currentPage;
        _nextPageUrl = response.nextPageUrl;

        if (response.transactions.isEmpty) {
          emit(TransactionsEmpty());
        } else {
          emit(TransactionsLoaded(
            transactions: response.transactions,
            total: response.total,
            currentPage: response.currentPage,
            lastPage: response.lastPage,
            hasMore: response.hasMore,
            nextPageUrl: response.nextPageUrl,
          ));
        }
      },
    );
  }

  Future<void> _onLoadMoreTransactions(
    LoadMoreTransactionsEvent event,
    Emitter<TransactionsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TransactionsLoaded ||
        currentState.isLoadingMore ||
        !currentState.hasMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    final result = await getMyTransactionsUseCase(
      nextPageUrl: currentState.nextPageUrl,
    );

    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingMore: false)),
      (response) {
        _currentPage = response.currentPage;
        _nextPageUrl = response.nextPageUrl;

        emit(currentState.copyWith(
          transactions: [...currentState.transactions, ...response.transactions],
          currentPage: response.currentPage,
          lastPage: response.lastPage,
          hasMore: response.hasMore,
          isLoadingMore: false,
          nextPageUrl: response.nextPageUrl,
        ));
      },
    );
  }

  Future<void> _onRefreshTransactions(
    RefreshTransactionsEvent event,
    Emitter<TransactionsState> emit,
  ) async {
    final currentState = state;
    final cachedTransactions = currentState is TransactionsLoaded
        ? currentState.transactions
        : null;

    final result = await getMyTransactionsUseCase(page: 1);

    result.fold(
      (failure) {
        if (cachedTransactions != null) {
          emit(TransactionsError(failure.message, cachedTransactions: cachedTransactions));
        } else {
          emit(TransactionsError(failure.message));
        }
      },
      (response) {
        _currentPage = response.currentPage;
        _nextPageUrl = response.nextPageUrl;

        if (response.transactions.isEmpty) {
          emit(TransactionsEmpty());
        } else {
          emit(TransactionsLoaded(
            transactions: response.transactions,
            total: response.total,
            currentPage: response.currentPage,
            lastPage: response.lastPage,
            hasMore: response.hasMore,
            nextPageUrl: response.nextPageUrl,
          ));
        }
      },
    );
  }

  void _onClearState(
    ClearTransactionsStateEvent event,
    Emitter<TransactionsState> emit,
  ) {
    _currentPage = 1;
    _nextPageUrl = null;
    emit(TransactionsInitial());
  }
}
