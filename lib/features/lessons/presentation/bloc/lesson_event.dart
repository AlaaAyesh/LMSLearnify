import 'package:equatable/equatable.dart';

abstract class LessonEvent extends Equatable {
  const LessonEvent();

  @override
  List<Object?> get props => [];
}

class LoadLessonEvent extends LessonEvent {
  final int lessonId;

  const LoadLessonEvent({required this.lessonId});

  @override
  List<Object?> get props => [lessonId];
}

class MarkLessonViewedEvent extends LessonEvent {
  final int lessonId;

  const MarkLessonViewedEvent({required this.lessonId});

  @override
  List<Object?> get props => [lessonId];
}

class ClearLessonStateEvent extends LessonEvent {
  const ClearLessonStateEvent();
}



