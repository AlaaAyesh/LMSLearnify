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
      print('LessonBloc: Skipping mark as viewed for invalid lesson ID: ${event.lessonId}');
      return;
    }

    print('LessonBloc: Marking lesson ${event.lessonId} as viewed');
    
    // Mark as viewed silently - don't change the current state
    // This prevents the UI from re-rendering and losing the video player
    final result = await markLessonViewedUseCase(id: event.lessonId);
    
    result.fold(
      (failure) {
        // Log error but don't emit state to avoid disrupting video playback
        print('LessonBloc: Failed to mark lesson ${event.lessonId} as viewed: ${failure.message}');
        print('LessonBloc: Error details: ${failure.toString()}');
      },
      (_) {
        print('LessonBloc: Successfully marked lesson ${event.lessonId} as viewed via API');
        // Emit a state to notify listeners (but only if we're not in the middle of playing a video)
        // This allows course_details_page to update if it's listening
        if (state is! LessonLoaded) {
          emit(LessonMarkedAsViewed(lessonId: event.lessonId));
        }
      },
    );
    
    // Keep the current LessonLoaded state if we're playing a video
    // This prevents the UI from re-rendering and losing the video player
  }

  void _onClearState(
    ClearLessonStateEvent event,
    Emitter<LessonState> emit,
  ) {
    emit(LessonInitial());
  }
}



