import 'package:equatable/equatable.dart';
import '../../domain/entities/home_data.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {
  final HomeData? cachedData;

  const HomeLoading({this.cachedData});

  @override
  List<Object?> get props => [cachedData];
}

class HomeLoaded extends HomeState {
  final HomeData homeData;

  const HomeLoaded(this.homeData);

  @override
  List<Object?> get props => [homeData];
}

class HomeError extends HomeState {
  final String message;
  final HomeData? cachedData;

  const HomeError(this.message, {this.cachedData});

  @override
  List<Object?> get props => [message, cachedData];
}



