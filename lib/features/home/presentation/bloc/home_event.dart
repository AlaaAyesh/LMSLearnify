import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load home data
class LoadHomeDataEvent extends HomeEvent {}

/// Event to refresh home data
class RefreshHomeDataEvent extends HomeEvent {}

