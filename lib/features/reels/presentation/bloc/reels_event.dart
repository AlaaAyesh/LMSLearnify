import 'package:equatable/equatable.dart';
import '../../domain/entities/reel.dart';

abstract class ReelsEvent extends Equatable {
  const ReelsEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial reels feed
class LoadReelsFeedEvent extends ReelsEvent {
  final int perPage;
  final int? categoryId;

  const LoadReelsFeedEvent({this.perPage = 10, this.categoryId});

  @override
  List<Object?> get props => [perPage, categoryId];
}

/// Load more reels (pagination)
class LoadMoreReelsEvent extends ReelsEvent {
  const LoadMoreReelsEvent();
}

/// Refresh reels feed
class RefreshReelsFeedEvent extends ReelsEvent {
  const RefreshReelsFeedEvent();
}

/// Toggle like on a reel
class ToggleReelLikeEvent extends ReelsEvent {
  final int reelId;

  const ToggleReelLikeEvent({required this.reelId});

  @override
  List<Object?> get props => [reelId];
}

/// Mark reel as viewed
class MarkReelViewedEvent extends ReelsEvent {
  final int reelId;

  const MarkReelViewedEvent({required this.reelId});

  @override
  List<Object?> get props => [reelId];
}

/// Load reel categories
class LoadReelCategoriesEvent extends ReelsEvent {
  const LoadReelCategoriesEvent();
}

/// Seed bloc with a single reel (used when opening one reel from grid/profile)
class SeedSingleReelEvent extends ReelsEvent {
  final Reel reel;

  const SeedSingleReelEvent({required this.reel});

  @override
  List<Object?> get props => [reel];
}

/// Seed bloc with a list of reels (used when opening a list from grid/profile)
class SeedReelsListEvent extends ReelsEvent {
  final List<Reel> reels;

  const SeedReelsListEvent({required this.reels});

  @override
  List<Object?> get props => [reels];
}

/// Load reels for the next category and append to current feed
class LoadNextCategoryReelsEvent extends ReelsEvent {
  final int categoryId;

  const LoadNextCategoryReelsEvent({required this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}



