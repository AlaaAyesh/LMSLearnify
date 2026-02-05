import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/lesson.dart';

abstract class LessonState extends Equatable {
  const LessonState();

  @override
  List<Object?> get props => [];
}

class LessonInitial extends LessonState {}

class LessonLoading extends LessonState {}

class LessonLoaded extends LessonState {
  final Lesson lesson;

  const LessonLoaded({required this.lesson});

  @override
  List<Object?> get props => [lesson];
}

class LessonMarkedAsViewed extends LessonState {
  final int lessonId;

  const LessonMarkedAsViewed({required this.lessonId});

  @override
  List<Object?> get props => [lessonId];
}

class LessonError extends LessonState {
  final String message;

  const LessonError(this.message);

  @override
  List<Object?> get props => [message];
}



