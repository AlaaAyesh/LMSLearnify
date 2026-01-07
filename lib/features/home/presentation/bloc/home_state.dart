import 'package:equatable/equatable.dart';
import '../../domain/entities/home_data.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class HomeInitial extends HomeState {}

/// Loading state
class HomeLoading extends HomeState {}

/// State when home data is loaded successfully
class HomeLoaded extends HomeState {
  final HomeData homeData;

  const HomeLoaded(this.homeData);

  @override
  List<Object?> get props => [homeData];
}

/// Error state
class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}



