import 'package:equatable/equatable.dart';
import '../../domain/entities/reel.dart';

abstract class ReelsState extends Equatable {
  const ReelsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ReelsInitial extends ReelsState {
  const ReelsInitial();
}

/// Loading initial reels
class ReelsLoading extends ReelsState {
  const ReelsLoading();
}

/// Reels loaded successfully
class ReelsLoaded extends ReelsState {
  final List<Reel> reels;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final Map<int, bool> likedReels;
  final Map<int, int> viewCounts;  // Track updated view counts
  final Map<int, int> likeCounts;  // Track updated like counts

  const ReelsLoaded({
    required this.reels,
    this.nextCursor,
    required this.hasMore,
    this.isLoadingMore = false,
    this.likedReels = const {},
    this.viewCounts = const {},
    this.likeCounts = const {},
  });

  /// Get view count for a reel (local update or original)
  int getViewCount(Reel reel) {
    return viewCounts[reel.id] ?? reel.viewsCount;
  }

  /// Get like count for a reel (local update or original)
  int getLikeCount(Reel reel) {
    return likeCounts[reel.id] ?? reel.likesCount;
  }

  ReelsLoaded copyWith({
    List<Reel>? reels,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    Map<int, bool>? likedReels,
    Map<int, int>? viewCounts,
    Map<int, int>? likeCounts,
  }) {
    return ReelsLoaded(
      reels: reels ?? this.reels,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      likedReels: likedReels ?? this.likedReels,
      viewCounts: viewCounts ?? this.viewCounts,
      likeCounts: likeCounts ?? this.likeCounts,
    );
  }

  @override
  List<Object?> get props => [reels, nextCursor, hasMore, isLoadingMore, likedReels, viewCounts, likeCounts];
}

/// No reels available
class ReelsEmpty extends ReelsState {
  const ReelsEmpty();
}

/// Error loading reels
class ReelsError extends ReelsState {
  final String message;

  const ReelsError(this.message);

  @override
  List<Object?> get props => [message];
}


