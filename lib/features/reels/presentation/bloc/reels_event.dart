import 'package:equatable/equatable.dart';
import '../../domain/entities/reel.dart';

abstract class ReelsEvent extends Equatable {
  const ReelsEvent();

  @override
  List<Object?> get props => [];
}

class LoadReelsFeedEvent extends ReelsEvent {
  final int perPage;
  final int? categoryId;

  const LoadReelsFeedEvent({this.perPage = 10, this.categoryId});

  @override
  List<Object?> get props => [perPage, categoryId];
}

class LoadMoreReelsEvent extends ReelsEvent {
  const LoadMoreReelsEvent();
}

class RefreshReelsFeedEvent extends ReelsEvent {
  const RefreshReelsFeedEvent();
}

class ToggleReelLikeEvent extends ReelsEvent {
  final int reelId;

  const ToggleReelLikeEvent({required this.reelId});

  @override
  List<Object?> get props => [reelId];
}

class MarkReelViewedEvent extends ReelsEvent {
  final int reelId;

  const MarkReelViewedEvent({required this.reelId});

  @override
  List<Object?> get props => [reelId];
}

class LoadReelCategoriesEvent extends ReelsEvent {
  const LoadReelCategoriesEvent();
}

class SeedSingleReelEvent extends ReelsEvent {
  final Reel reel;

  const SeedSingleReelEvent({required this.reel});

  @override
  List<Object?> get props => [reel];
}

class SeedReelsListEvent extends ReelsEvent {
  final List<Reel> reels;

  const SeedReelsListEvent({required this.reels});

  @override
  List<Object?> get props => [reels];
}

class LoadNextCategoryReelsEvent extends ReelsEvent {
  final int categoryId;

  const LoadNextCategoryReelsEvent({required this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

class LoadUserReelsEvent extends ReelsEvent {
  final int userId;
  final int perPage;
  final int page;

  const LoadUserReelsEvent({
    required this.userId,
    this.perPage = 10,
    this.page = 1,
  });

  @override
  List<Object?> get props => [userId, perPage, page];
}

class LoadMoreUserReelsEvent extends ReelsEvent {
  const LoadMoreUserReelsEvent();
}

class LoadUserLikedReelsEvent extends ReelsEvent {
  final int userId;
  final int perPage;
  final int page;

  const LoadUserLikedReelsEvent({
    required this.userId,
    this.perPage = 10,
    this.page = 1,
  });

  @override
  List<Object?> get props => [userId, perPage, page];
}

class LoadMoreUserLikedReelsEvent extends ReelsEvent {
  const LoadMoreUserLikedReelsEvent();
}



