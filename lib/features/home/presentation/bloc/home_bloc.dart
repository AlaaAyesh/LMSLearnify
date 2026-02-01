import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/realtime_update_service.dart';
import '../../domain/usecases/get_home_data_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeDataUseCase getHomeDataUseCase;
  final RealtimeUpdateService _realtimeUpdateService = sl<RealtimeUpdateService>();
  bool _isLoading = false;

  HomeBloc({
    required this.getHomeDataUseCase,
  }) : super(HomeInitial()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
    on<RefreshHomeDataEvent>(_onRefreshHomeData);
    on<StartRealtimeUpdatesEvent>(_onStartRealtimeUpdates);
    on<StopRealtimeUpdatesEvent>(_onStopRealtimeUpdates);
    
    // Start real-time updates when bloc is created
    add(StartRealtimeUpdatesEvent());
  }
  
  Future<void> _onStartRealtimeUpdates(
    StartRealtimeUpdatesEvent event,
    Emitter<HomeState> emit,
  ) async {
    // Start polling for home data updates
    _realtimeUpdateService.startPolling(
      key: 'home_data',
      updateCallback: () async {
        // Silently refresh data in background
        final result = await getHomeDataUseCase();
        result.fold(
          (_) {}, // Ignore errors in background updates
          (homeData) => emit(HomeLoaded(homeData)),
        );
      },
    );
  }
  
  Future<void> _onStopRealtimeUpdates(
    StopRealtimeUpdatesEvent event,
    Emitter<HomeState> emit,
  ) async {
    _realtimeUpdateService.stopPolling('home_data');
  }
  
  @override
  Future<void> close() {
    _realtimeUpdateService.stopPolling('home_data');
    return super.close();
  }

  Future<void> _onLoadHomeData(
    LoadHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    // Prevent duplicate loading
    if (_isLoading) return;
    
    // Show cached data immediately if available (optimistic update)
    final currentState = state;
    if (currentState is HomeLoaded) {
      // Keep showing cached data while loading
      _isLoading = true;
      emit(HomeLoading(cachedData: currentState.homeData));
    } else {
      _isLoading = true;
      emit(HomeLoading());
    }

    final result = await getHomeDataUseCase();

    _isLoading = false;
    result.fold(
      (failure) {
        // On error, keep showing cached data if available
        if (currentState is HomeLoaded) {
          emit(HomeError(failure.message, cachedData: currentState.homeData));
        } else {
          emit(HomeError(failure.message));
        }
      },
      (homeData) => emit(HomeLoaded(homeData)),
    );
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    // Don't show loading state during refresh, keep current data visible
    final currentState = state;
    final cachedData = currentState is HomeLoaded ? currentState.homeData : null;
    
    final result = await getHomeDataUseCase();

    result.fold(
      (failure) {
        // On error, keep showing cached data if available
        if (cachedData != null) {
          emit(HomeError(failure.message, cachedData: cachedData));
        } else {
          emit(HomeError(failure.message));
        }
      },
      (homeData) => emit(HomeLoaded(homeData)),
    );
  }
}



