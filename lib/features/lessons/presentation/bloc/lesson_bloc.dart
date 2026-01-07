import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_lesson_by_id_usecase.dart';
import '../../domain/usecases/mark_lesson_viewed_usecase.dart';
import 'lesson_event.dart';
import 'lesson_state.dart';

class LessonBloc extends Bloc<LessonEvent, LessonState> {
  final GetLessonByIdUseCase getLessonByIdUseCase;
  final MarkLessonViewedUseCase markLessonViewedUseCase;

  LessonBloc({
    required this.getLessonByIdUseCase,
    required this.markLessonViewedUseCase,
  }) : super(LessonInitial()) {
    on<LoadLessonEvent>(_onLoadLesson);
    on<MarkLessonViewedEvent>(_onMarkLessonViewed);
    on<ClearLessonStateEvent>(_onClearState);
  }

  Future<void> _onLoadLesson(
    LoadLessonEvent event,
    Emitter<LessonState> emit,
  ) async {
    // Skip invalid lesson IDs (e.g., intro videos use ID 0)
    if (event.lessonId <= 0) {
      emit(LessonError('Invalid lesson ID'));
      return;
    }

    emit(LessonLoading());

    final result = await getLessonByIdUseCase(id: event.lessonId);

    result.fold(
      (failure) => emit(LessonError(failure.message)),
      (lesson) => emit(LessonLoaded(lesson: lesson)),
    );
  }

  Future<void> _onMarkLessonViewed(
    MarkLessonViewedEvent event,
    Emitter<LessonState> emit,
  ) async {
    // Skip invalid lesson IDs (e.g., intro videos use ID 0)
    if (event.lessonId <= 0) {
      return;
    }

    // Mark as viewed silently - don't change the current state
    // This prevents the UI from re-rendering and losing the video player
    await markLessonViewedUseCase(id: event.lessonId);
    // Don't emit any state - keep the current LessonLoaded state
  }

  void _onClearState(
    ClearLessonStateEvent event,
    Emitter<LessonState> emit,
  ) {
    emit(LessonInitial());
  }
}



