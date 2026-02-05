import 'package:equatable/equatable.dart';
import '../../domain/entities/reel.dart';
import '../../data/models/reel_category_model.dart';

abstract class ReelsState extends Equatable {
  const ReelsState();

  @override
  List<Object?> get props => [];
}

class ReelsInitial extends ReelsState {
  const ReelsInitial();
}

class ReelsLoading extends ReelsState {
  const ReelsLoading();
}

class ReelsLoaded extends ReelsState {
  final List<Reel> reels;
  final String? nextCursor;
  final String? nextPageUrl;
  final bool hasMore;
  final bool isLoadingMore;
  final Map<int, bool> likedReels;
  final Map<int, int> viewCounts;
  final Map<int, int> likeCounts;
  final List<ReelCategoryModel> categories;

  const ReelsLoaded({
    required this.reels,
    this.nextCursor,
    this.nextPageUrl,
    required this.hasMore,
    this.isLoadingMore = false,
    this.likedReels = const {},
    this.viewCounts = const {},
    this.likeCounts = const {},
    this.categories = const [],
  });

  int getViewCount(Reel reel) {
    return viewCounts[reel.id] ?? reel.viewsCount;
  }

  int getLikeCount(Reel reel) {
    return likeCounts[reel.id] ?? reel.likesCount;
  }

  ReelsLoaded copyWith({
    List<Reel>? reels,
    String? nextCursor,
    String? nextPageUrl,
    bool? hasMore,
    bool? isLoadingMore,
    Map<int, bool>? likedReels,
    Map<int, int>? viewCounts,
    Map<int, int>? likeCounts,
    List<ReelCategoryModel>? categories,
  }) {
    return ReelsLoaded(
      reels: reels ?? this.reels,
      nextCursor: nextCursor ?? this.nextCursor,
      nextPageUrl: nextPageUrl ?? this.nextPageUrl,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      likedReels: likedReels ?? this.likedReels,
      viewCounts: viewCounts ?? this.viewCounts,
      likeCounts: likeCounts ?? this.likeCounts,
      categories: categories ?? this.categories,
    );
  }

  @override
  List<Object?> get props => [reels, nextCursor, nextPageUrl, hasMore, isLoadingMore, likedReels, viewCounts, likeCounts, categories];
}

class ReelsEmpty extends ReelsState {
  const ReelsEmpty();
}

class ReelsError extends ReelsState {
  final String message;

  const ReelsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReelsWithCategories extends ReelsState {
  final List<ReelCategoryModel> categories;

  const ReelsWithCategories({required this.categories});

  @override
  List<Object?> get props => [categories];
}


