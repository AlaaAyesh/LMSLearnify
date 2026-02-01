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

/// Event to start real-time updates
class StartRealtimeUpdatesEvent extends HomeEvent {}

/// Event to stop real-time updates
class StopRealtimeUpdatesEvent extends HomeEvent {}



