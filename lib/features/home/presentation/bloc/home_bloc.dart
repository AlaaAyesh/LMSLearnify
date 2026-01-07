import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_home_data_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeDataUseCase getHomeDataUseCase;

  HomeBloc({
    required this.getHomeDataUseCase,
  }) : super(HomeInitial()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
    on<RefreshHomeDataEvent>(_onRefreshHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    final result = await getHomeDataUseCase();

    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (homeData) => emit(HomeLoaded(homeData)),
    );
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    // Don't show loading state during refresh
    final result = await getHomeDataUseCase();

    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (homeData) => emit(HomeLoaded(homeData)),
    );
  }
}



