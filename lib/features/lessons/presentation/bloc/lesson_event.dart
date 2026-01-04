import 'package:equatable/equatable.dart';

abstract class LessonEvent extends Equatable {
  const LessonEvent();

  @override
  List<Object?> get props => [];
}

/// Load lesson details by ID
class LoadLessonEvent extends LessonEvent {
  final int lessonId;

  const LoadLessonEvent({required this.lessonId});

  @override
  List<Object?> get props => [lessonId];
}

/// Mark lesson as viewed
class MarkLessonViewedEvent extends LessonEvent {
  final int lessonId;

  const MarkLessonViewedEvent({required this.lessonId});

  @override
  List<Object?> get props => [lessonId];
}

/// Clear lesson state
class ClearLessonStateEvent extends LessonEvent {
  const ClearLessonStateEvent();
}

