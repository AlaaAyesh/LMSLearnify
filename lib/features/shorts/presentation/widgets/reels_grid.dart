import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';

import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../reels/domain/entities/reel.dart';

class ReelsGrid extends StatelessWidget {
  final List<Reel> reels;
  final Function(Reel reel, int index) onReelTap;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  
  // Real-time state maps
  final Map<int, bool> likedReels;
  final Map<int, int> viewCounts;
  final Map<int, int> likeCounts;

  const ReelsGrid({
    super.key,
    required this.reels,
    required this.onReelTap,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.likedReels = const {},
    this.viewCounts = const {},
    this.likeCounts = const {},
  });

  @override
  Widget build(BuildContext context) {
    if (reels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد فيديوهات',
              style: TextStyle(
                fontFamily: cairoFontFamily,
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (onLoadMore != null &&
            scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
          onLoadMore!();
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.65,
        ),
        // Add cacheExtent for smoother scrolling
        cacheExtent: 500,
        itemCount: reels.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= reels.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            );
          }

          final reel = reels[index];
          // Get real-time values from state, fallback to original values
          final isLiked = likedReels[reel.id] ?? reel.liked;
          final viewCount = viewCounts[reel.id] ?? reel.viewsCount;

          return _ReelTile(
            reel: reel,
            isLiked: isLiked,
            viewCount: viewCount,
            onTap: () => onReelTap(reels[index], index),
          );
        },
      ),
    );
  }
}

class _ReelTile extends StatelessWidget {
  final Reel reel;
  final bool isLiked;
  final int viewCount;
  final VoidCallback onTap;

  const _ReelTile({
    required this.reel,
    required this.isLiked,
    required this.viewCount,
    required this.onTap,
  });

  String _formatViews(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return 'views $count';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail - with memory optimization
            CachedNetworkImage(
              imageUrl: reel.thumbnailUrl,
              fit: BoxFit.cover,
              memCacheWidth: 240, // Optimize memory for grid thumbnails
              placeholder: (context, url) => const ColoredBox(
                color: AppColors.primaryOpacity10,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => const ColoredBox(
                color: AppColors.primaryOpacity10,
                child: Icon(
                  Icons.play_circle_outline,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
            ),
            // Gradient overlay at bottom - wrapped in RepaintBoundary
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: RepaintBoundary(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.blackOpacity70,
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _formatViews(viewCount),
                          style: TextStyle(
                            fontFamily: cairoFontFamily,
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Liked indicator - uses real-time isLiked value
            if (isLiked)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.blackOpacity50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}



