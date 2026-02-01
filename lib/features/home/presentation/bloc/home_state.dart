import 'package:equatable/equatable.dart';
import '../../domain/entities/home_data.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class HomeInitial extends HomeState {}

/// Loading state (with optional cached data for optimistic updates)
class HomeLoading extends HomeState {
  final HomeData? cachedData;

  const HomeLoading({this.cachedData});

  @override
  List<Object?> get props => [cachedData];
}

/// State when home data is loaded successfully
class HomeLoaded extends HomeState {
  final HomeData homeData;

  const HomeLoaded(this.homeData);

  @override
  List<Object?> get props => [homeData];
}

/// Error state (with optional cached data to keep UI functional)
class HomeError extends HomeState {
  final String message;
  final HomeData? cachedData;

  const HomeError(this.message, {this.cachedData});

  @override
  List<Object?> get props => [message, cachedData];
}



