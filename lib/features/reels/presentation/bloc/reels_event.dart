import 'package:equatable/equatable.dart';

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



