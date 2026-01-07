import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_chapter_by_id_usecase.dart';
import 'chapter_event.dart';
import 'chapter_state.dart';

class ChapterBloc extends Bloc<ChapterEvent, ChapterState> {
  final GetChapterByIdUseCase getChapterByIdUseCase;

  ChapterBloc({
    required this.getChapterByIdUseCase,
  }) : super(ChapterInitial()) {
    on<LoadChapterEvent>(_onLoadChapter);
    on<ClearChapterStateEvent>(_onClearState);
  }

  Future<void> _onLoadChapter(
    LoadChapterEvent event,
    Emitter<ChapterState> emit,
  ) async {
    emit(ChapterLoading());

    final result = await getChapterByIdUseCase(id: event.chapterId);

    result.fold(
      (failure) => emit(ChapterError(failure.message)),
      (chapter) => emit(ChapterLoaded(chapter: chapter)),
    );
  }

  void _onClearState(
    ClearChapterStateEvent event,
    Emitter<ChapterState> emit,
  ) {
    emit(ChapterInitial());
  }
}



