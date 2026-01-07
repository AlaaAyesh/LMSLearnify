import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';

import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/short_video.dart';

class ShortsGrid extends StatelessWidget {
  final List<ShortVideo> videos;
  final Function(ShortVideo video, int index) onVideoTap;

  const ShortsGrid({
    super.key,
    required this.videos,
    required this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
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

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.65,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        return _ShortVideoTile(
          video: videos[index],
          onTap: () => onVideoTap(videos[index], index),
        );
      },
    );
  }
}

class _ShortVideoTile extends StatelessWidget {
  final ShortVideo video;
  final VoidCallback onTap;

  const _ShortVideoTile({
    required this.video,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail
            CachedNetworkImage(
              imageUrl: video.thumbnailUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.primary.withOpacity(0.1),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.primary.withOpacity(0.1),
                child: const Icon(
                  Icons.play_circle_outline,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
            ),
            // Gradient overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
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
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        video.formattedViews,
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
          ],
        ),
      ),
    );
  }
}





