import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/chapter.dart';

abstract class ChapterState extends Equatable {
  const ChapterState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ChapterInitial extends ChapterState {}

/// Loading state
class ChapterLoading extends ChapterState {}

/// Chapter loaded successfully
class ChapterLoaded extends ChapterState {
  final Chapter chapter;

  const ChapterLoaded({required this.chapter});

  @override
  List<Object?> get props => [chapter];
}

/// Error state
class ChapterError extends ChapterState {
  final String message;

  const ChapterError(this.message);

  @override
  List<Object?> get props => [message];
}

