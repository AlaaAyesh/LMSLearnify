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
    if (event.lessonId <= 0) {
      print('LessonBloc: Skipping mark as viewed for invalid lesson ID: ${event.lessonId}');
      return;
    }

    print('LessonBloc: Marking lesson ${event.lessonId} as viewed');

    final result = await markLessonViewedUseCase(id: event.lessonId);
    
    result.fold(
      (failure) {
        print('LessonBloc: Failed to mark lesson ${event.lessonId} as viewed: ${failure.message}');
        print('LessonBloc: Error details: ${failure.toString()}');
      },
      (_) {
        print('LessonBloc: Successfully marked lesson ${event.lessonId} as viewed via API');
        if (state is! LessonLoaded) {
          emit(LessonMarkedAsViewed(lessonId: event.lessonId));
        }
      },
    );
  }

  void _onClearState(
    ClearLessonStateEvent event,
    Emitter<LessonState> emit,
  ) {
    emit(LessonInitial());
  }
}



