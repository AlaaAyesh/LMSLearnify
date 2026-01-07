import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/reel.dart';
import '../bloc/reels_bloc.dart';
import '../bloc/reels_event.dart';
import '../bloc/reels_state.dart';
import '../widgets/reel_player_widget.dart';

class ReelsFeedPage extends StatefulWidget {
  final int initialIndex;

  const ReelsFeedPage({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<ReelsFeedPage> createState() => _ReelsFeedPageState();
}

class _ReelsFeedPageState extends State<ReelsFeedPage> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Set status bar to light for dark background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Reset status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Reels',
          style: TextStyle(
            fontFamily: cairoFontFamily,
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<ReelsBloc, ReelsState>(
        builder: (context, state) {
          if (state is ReelsLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (state is ReelsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white54,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontFamily: cairoFontFamily,
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ReelsBloc>().add(const LoadReelsFeedEvent());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      'إعادة المحاولة',
                      style: TextStyle(
                        fontFamily: cairoFontFamily,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is ReelsEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.video_library_outlined,
                    color: Colors.white54,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد فيديوهات حالياً',
                    style: TextStyle(
                      fontFamily: cairoFontFamily,
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is ReelsLoaded) {
            return _buildReelsFeed(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildReelsFeed(BuildContext context, ReelsLoaded state) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      // Allow preloading adjacent pages for smoother transitions
      allowImplicitScrolling: true,
      itemCount: state.reels.length + (state.hasMore ? 1 : 0),
      onPageChanged: (index) {
        setState(() => _currentIndex = index);

        // Load more when reaching near the end
        if (index >= state.reels.length - 3 && state.hasMore && !state.isLoadingMore) {
          context.read<ReelsBloc>().add(const LoadMoreReelsEvent());
        }
      },
      itemBuilder: (context, index) {
        // Loading indicator at the end
        if (index >= state.reels.length) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        final reel = state.reels[index];
        final isLiked = state.likedReels[reel.id] ?? reel.liked;
        final viewCount = state.getViewCount(reel);
        final likeCount = state.getLikeCount(reel);

        return ReelPlayerWidget(
          key: ValueKey('reel_${reel.id}'),
          reel: reel,
          isLiked: isLiked,
          viewCount: viewCount,
          likeCount: likeCount,
          isActive: index == _currentIndex,
          onLike: () {
            context.read<ReelsBloc>().add(ToggleReelLikeEvent(reelId: reel.id));
          },
          onShare: () => _shareReel(reel),
          onRedirect: () => _handleRedirect(reel),
          onViewed: () {
            context.read<ReelsBloc>().add(MarkReelViewedEvent(reelId: reel.id));
          },
        );
      },
    );
  }

  void _shareReel(Reel reel) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'مشاركة الفيديو',
          style: TextStyle(fontFamily: cairoFontFamily),
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _handleRedirect(Reel reel) {
    // Handle redirect based on redirect_type
    if (reel.redirectType == 'course' && reel.redirectLink.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'الذهاب إلى الكورس: ${reel.redirectLink}',
            style: TextStyle(fontFamily: cairoFontFamily),
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }
}



