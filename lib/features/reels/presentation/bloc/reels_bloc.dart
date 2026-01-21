import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_reels_feed_usecase.dart';
import '../../domain/usecases/record_reel_view_usecase.dart';
import '../../domain/usecases/toggle_reel_like_usecase.dart';
import '../../domain/usecases/get_reel_categories_usecase.dart';
import 'reels_event.dart';
import 'reels_state.dart';

class ReelsBloc extends Bloc<ReelsEvent, ReelsState> {
  final GetReelsFeedUseCase getReelsFeedUseCase;
  final RecordReelViewUseCase recordReelViewUseCase;
  final ToggleReelLikeUseCase toggleReelLikeUseCase;
  final GetReelCategoriesUseCase getReelCategoriesUseCase;

  int _perPage = 10;
  int? _currentCategoryId; // Track current category filter
  final Set<int> _viewedReelIds = {}; // Track viewed reels to avoid duplicate API calls

  ReelsBloc({
    required this.getReelsFeedUseCase,
    required this.recordReelViewUseCase,
    required this.toggleReelLikeUseCase,
    required this.getReelCategoriesUseCase,
  }) : super(const ReelsInitial()) {
    on<LoadReelsFeedEvent>(_onLoadReelsFeed);
    on<LoadMoreReelsEvent>(_onLoadMoreReels);
    on<LoadNextCategoryReelsEvent>(_onLoadNextCategoryReels);
    on<RefreshReelsFeedEvent>(_onRefreshReelsFeed);
    on<ToggleReelLikeEvent>(_onToggleReelLike);
    on<MarkReelViewedEvent>(_onMarkReelViewed);
    on<LoadReelCategoriesEvent>(_onLoadReelCategories);
    on<SeedSingleReelEvent>(_onSeedSingleReel);
    on<SeedReelsListEvent>(_onSeedReelsList);
  }

  void _onSeedReelsList(
    SeedReelsListEvent event,
    Emitter<ReelsState> emit,
  ) {
    _currentCategoryId = null; // clear category filter in seeded-list mode

    final reels = event.reels;
    if (reels.isEmpty) {
      emit(const ReelsEmpty());
      return;
    }

    final likedReels = <int, bool>{};
    for (final reel in reels) {
      likedReels[reel.id] = reel.liked;
      if (reel.viewed) {
        _viewedReelIds.add(reel.id);
      }
    }

    emit(ReelsLoaded(
      reels: reels,
      nextCursor: null,
      nextPageUrl: null,
      hasMore: false,
      isLoadingMore: false,
      likedReels: likedReels,
    ));
  }

  void _onSeedSingleReel(
    SeedSingleReelEvent event,
    Emitter<ReelsState> emit,
  ) {
    _currentCategoryId = null; // clear category filter in single-reel mode

    final reel = event.reel;

    final likedReels = <int, bool>{reel.id: reel.liked};
    final viewCounts = <int, int>{};
    final likeCounts = <int, int>{};

    if (reel.viewed) {
      _viewedReelIds.add(reel.id);
    }

    emit(ReelsLoaded(
      reels: [reel],
      nextCursor: null,
      nextPageUrl: null,
      hasMore: false,
      isLoadingMore: false,
      likedReels: likedReels,
      viewCounts: viewCounts,
      likeCounts: likeCounts,
    ));
  }

  Future<void> _onLoadReelsFeed(
    LoadReelsFeedEvent event,
    Emitter<ReelsState> emit,
  ) async {
    emit(const ReelsLoading());
    _perPage = event.perPage;
    _currentCategoryId = event.categoryId;

    final result = await getReelsFeedUseCase(
      perPage: _perPage,
      categoryId: _currentCategoryId,
    );

    result.fold(
      (failure) => emit(ReelsError(failure.message)),
      (response) {
        if (response.reels.isEmpty) {
          emit(const ReelsEmpty());
        } else {
          // Initialize liked status from API response
          final likedReels = <int, bool>{};
          for (final reel in response.reels) {
            likedReels[reel.id] = reel.liked;
            // Mark already viewed reels
            if (reel.viewed) {
              _viewedReelIds.add(reel.id);
            }
          }

          emit(ReelsLoaded(
            reels: response.reels,
            nextCursor: response.meta.nextCursor,
            nextPageUrl: response.meta.nextPageUrl,
            hasMore: response.meta.hasMore,
            likedReels: likedReels,
          ));
        }
      },
    );
  }

  Future<void> _onLoadNextCategoryReels(
    LoadNextCategoryReelsEvent event,
    Emitter<ReelsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ReelsLoaded) return;

    emit(currentState.copyWith(isLoadingMore: true));

    _currentCategoryId = event.categoryId;

    final result = await getReelsFeedUseCase(
      perPage: _perPage,
      categoryId: _currentCategoryId,
    );

    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingMore: false)),
      (response) {
        if (response.reels.isEmpty) {
          emit(currentState.copyWith(
            hasMore: false,
            isLoadingMore: false,
            nextCursor: null,
            nextPageUrl: null,
          ));
          return;
        }

        final newLikedReels = Map<int, bool>.from(currentState.likedReels);
        for (final reel in response.reels) {
          newLikedReels[reel.id] = reel.liked;
          if (reel.viewed) {
            _viewedReelIds.add(reel.id);
          }
        }

        emit(currentState.copyWith(
          reels: [...currentState.reels, ...response.reels],
          nextCursor: response.meta.nextCursor,
          nextPageUrl: response.meta.nextPageUrl,
          hasMore: response.meta.hasMore,
          isLoadingMore: false,
          likedReels: newLikedReels,
        ));
      },
    );
  }

  Future<void> _onLoadMoreReels(
    LoadMoreReelsEvent event,
    Emitter<ReelsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ReelsLoaded) return;
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    // Use nextPageUrl if available, otherwise fall back to cursor
    final result = await getReelsFeedUseCase(
      perPage: _perPage,
      cursor: currentState.nextCursor,
      nextPageUrl: currentState.nextPageUrl,
      categoryId: _currentCategoryId,
    );

    result.fold(
      (failure) {
        emit(currentState.copyWith(isLoadingMore: false));
      },
      (response) {
        // Update liked status for new reels
        final newLikedReels = Map<int, bool>.from(currentState.likedReels);
        for (final reel in response.reels) {
          newLikedReels[reel.id] = reel.liked;
          // Mark already viewed reels
          if (reel.viewed) {
            _viewedReelIds.add(reel.id);
          }
        }

        emit(currentState.copyWith(
          reels: [...currentState.reels, ...response.reels],
          nextCursor: response.meta.nextCursor,
          nextPageUrl: response.meta.nextPageUrl,
          hasMore: response.meta.hasMore,
          isLoadingMore: false,
          likedReels: newLikedReels,
        ));
      },
    );
  }

  Future<void> _onRefreshReelsFeed(
    RefreshReelsFeedEvent event,
    Emitter<ReelsState> emit,
  ) async {
    final result = await getReelsFeedUseCase(
      perPage: _perPage,
      categoryId: _currentCategoryId,
    );

    result.fold(
      (failure) => emit(ReelsError(failure.message)),
      (response) {
        if (response.reels.isEmpty) {
          emit(const ReelsEmpty());
        } else {
          final likedReels = <int, bool>{};
          for (final reel in response.reels) {
            likedReels[reel.id] = reel.liked;
            if (reel.viewed) {
              _viewedReelIds.add(reel.id);
            }
          }

          emit(ReelsLoaded(
            reels: response.reels,
            nextCursor: response.meta.nextCursor,
            nextPageUrl: response.meta.nextPageUrl,
            hasMore: response.meta.hasMore,
            likedReels: likedReels,
          ));
        }
      },
    );
  }

  Future<void> _onToggleReelLike(
    ToggleReelLikeEvent event,
    Emitter<ReelsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ReelsLoaded) {
      debugPrint('ReelsBloc: Cannot toggle like - state is not ReelsLoaded');
      return;
    }

    final isCurrentlyLiked = currentState.likedReels[event.reelId] ?? false;
    debugPrint('ReelsBloc: Toggling like for reel ${event.reelId}, currently liked: $isCurrentlyLiked');
    
    // Find current like count
    final reelIndex = currentState.reels.indexWhere((r) => r.id == event.reelId);
    if (reelIndex == -1) {
      debugPrint('ReelsBloc: Reel ${event.reelId} not found in state');
      return;
    }
    final reel = currentState.reels[reelIndex];
    final currentLikeCount = currentState.getLikeCount(reel);

    // Optimistic update - update UI immediately
    final newLikedReels = Map<int, bool>.from(currentState.likedReels);
    newLikedReels[event.reelId] = !isCurrentlyLiked;
    
    // Update like count locally
    final newLikeCounts = Map<int, int>.from(currentState.likeCounts);
    if (isCurrentlyLiked) {
      // Unliking - decrease count
      newLikeCounts[event.reelId] = (currentLikeCount - 1).clamp(0, double.maxFinite.toInt());
    } else {
      // Liking - increase count
      newLikeCounts[event.reelId] = currentLikeCount + 1;
    }
    
    emit(currentState.copyWith(
      likedReels: newLikedReels,
      likeCounts: newLikeCounts,
    ));

    // Call API to persist like status
    debugPrint('ReelsBloc: Calling API to ${isCurrentlyLiked ? "unlike" : "like"} reel ${event.reelId}');
    final result = await toggleReelLikeUseCase(
      reelId: event.reelId,
      isCurrentlyLiked: isCurrentlyLiked,
    );

    result.fold(
      (failure) {
        debugPrint('ReelsBloc: Like API failed - ${failure.message}');
        // Revert on failure
        if (state is ReelsLoaded) {
          final revertedLikedReels = Map<int, bool>.from((state as ReelsLoaded).likedReels);
          revertedLikedReels[event.reelId] = isCurrentlyLiked;
          
          final revertedLikeCounts = Map<int, int>.from((state as ReelsLoaded).likeCounts);
          revertedLikeCounts[event.reelId] = currentLikeCount;
          
          emit((state as ReelsLoaded).copyWith(
            likedReels: revertedLikedReels,
            likeCounts: revertedLikeCounts,
          ));
        }
      },
      (newLikedStatus) {
        debugPrint('ReelsBloc: Like API success - new status: $newLikedStatus');
        // API call successful, state already updated optimistically
      },
    );
  }

  Future<void> _onMarkReelViewed(
    MarkReelViewedEvent event,
    Emitter<ReelsState> emit,
  ) async {
    // Skip if already viewed in this session
    if (_viewedReelIds.contains(event.reelId)) {
      debugPrint('ReelsBloc: Reel ${event.reelId} already viewed, skipping');
      return;
    }

    final currentState = state;
    if (currentState is! ReelsLoaded) {
      debugPrint('ReelsBloc: Cannot mark viewed - state is not ReelsLoaded');
      return;
    }

    debugPrint('ReelsBloc: Marking reel ${event.reelId} as viewed');
    
    // Mark as viewed locally
    _viewedReelIds.add(event.reelId);

    // Find current view count
    final reelIndex = currentState.reels.indexWhere((r) => r.id == event.reelId);
    if (reelIndex == -1) {
      debugPrint('ReelsBloc: Reel ${event.reelId} not found in state for view tracking');
      return;
    }
    final reel = currentState.reels[reelIndex];
    final currentViewCount = currentState.getViewCount(reel);

    // Update view count locally (increment by 1)
    final newViewCounts = Map<int, int>.from(currentState.viewCounts);
    newViewCounts[event.reelId] = currentViewCount + 1;
    
    emit(currentState.copyWith(viewCounts: newViewCounts));

    // Call API to record view
    debugPrint('ReelsBloc: Calling API to record view for reel ${event.reelId}');
    final result = await recordReelViewUseCase(event.reelId);
    
    result.fold(
      (failure) {
        debugPrint('ReelsBloc: View API failed - ${failure.message}');
        // Don't revert view count on failure - it's okay if API fails
      },
      (_) {
        debugPrint('ReelsBloc: View API success for reel ${event.reelId}');
      },
    );
  }

  Future<void> _onLoadReelCategories(
    LoadReelCategoriesEvent event,
    Emitter<ReelsState> emit,
  ) async {
    final result = await getReelCategoriesUseCase();

    result.fold(
      (failure) {
        // Don't emit error state, just keep current state
        debugPrint('ReelsBloc: Failed to load categories - ${failure.message}');
      },
      (categories) {
        emit(ReelsWithCategories(categories: categories));
      },
    );
  }
}


