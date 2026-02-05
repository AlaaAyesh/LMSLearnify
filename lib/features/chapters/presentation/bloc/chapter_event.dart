import 'package:equatable/equatable.dart';

abstract class ChapterEvent extends Equatable {
  const ChapterEvent();

  @override
  List<Object?> get props => [];
}

class LoadChapterEvent extends ChapterEvent {
  final int chapterId;

  const LoadChapterEvent({required this.chapterId});

  @override
  List<Object?> get props => [chapterId];
}

class ClearChapterStateEvent extends ChapterEvent {
  const ClearChapterStateEvent();
}



