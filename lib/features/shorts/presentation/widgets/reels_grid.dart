import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
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
              size: Responsive.iconSize(context, 80),
              color: Colors.grey[400],
            ),
            SizedBox(height: Responsive.spacing(context, 16)),
            Text(
              'لا توجد فيديوهات',
              style: TextStyle(
                fontFamily: cairoFontFamily,
                fontSize: Responsive.fontSize(context, 16),
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
        padding: Responsive.padding(context, horizontal: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: Responsive.height(context, 8),
          crossAxisSpacing: Responsive.width(context, 8),
          childAspectRatio: 0.65,
        ),
        // Add cacheExtent for smoother scrolling
        cacheExtent: Responsive.width(context, 500),
        itemCount: reels.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= reels.length) {
            return Center(
              child: Padding(
                padding: Responsive.padding(context, all: 16),
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: Responsive.width(context, 2),
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
        borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail - with memory optimization
            CachedNetworkImage(
              imageUrl: reel.thumbnailUrl,
              fit: BoxFit.cover,
              memCacheWidth: (Responsive.width(context, 240)).toInt(), // Optimize memory for grid thumbnails
              placeholder: (context, url) => ColoredBox(
                color: AppColors.primaryOpacity10,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: Responsive.width(context, 2),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => ColoredBox(
                color: AppColors.primaryOpacity10,
                child: Icon(
                  Icons.play_circle_outline,
                  color: AppColors.primary,
                  size: Responsive.iconSize(context, 40),
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
                  padding: Responsive.padding(context, all: 8),
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
                      Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: Responsive.iconSize(context, 14),
                      ),
                      SizedBox(width: Responsive.width(context, 4)),
                      Expanded(
                        child: Text(
                          _formatViews(viewCount),
                          style: TextStyle(
                            fontFamily: cairoFontFamily,
                            fontSize: Responsive.fontSize(context, 10),
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
                top: Responsive.height(context, 8),
                right: Responsive.width(context, 8),
                child: Container(
                  padding: Responsive.padding(context, all: 4),
                  decoration: const BoxDecoration(
                    color: AppColors.blackOpacity50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: Responsive.iconSize(context, 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}



