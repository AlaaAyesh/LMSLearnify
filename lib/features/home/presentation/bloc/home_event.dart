import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeDataEvent extends HomeEvent {}

class RefreshHomeDataEvent extends HomeEvent {}

class StartRealtimeUpdatesEvent extends HomeEvent {}

class StopRealtimeUpdatesEvent extends HomeEvent {}



