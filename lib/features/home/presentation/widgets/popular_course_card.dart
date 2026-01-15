import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/course.dart';

class PopularCourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;

  const PopularCourseCard({
    super.key,
    required this.course,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: Responsive.width(context, 200),
        margin: Responsive.margin(context, left: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.radius(context, 16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: Responsive.width(context, 10),
              offset: Offset(0, Responsive.height(context, 4)),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with play button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(Responsive.radius(context, 16)),
                  ),
                  child: _buildThumbnail(context),
                ),
                // Play button overlay
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: Responsive.padding(context, all: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: Responsive.width(context, 8),
                            offset: Offset(0, Responsive.height(context, 2)),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: Responsive.iconSize(context, 24),
                      ),
                    ),
                  ),
                ),
                // Badge
                if (course.soon)
                  Positioned(
                    top: Responsive.height(context, 8),
                    right: Responsive.width(context, 8),
                    child: Container(
                      padding: Responsive.padding(context, horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(Responsive.radius(context, 8)),
                      ),
                      child: Text(
                        'قريباً',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: Responsive.fontSize(context, 10),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Content
            Padding(
              padding: Responsive.padding(context, all: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.nameAr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: Responsive.fontSize(context, 14),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    final thumbnailUrl = course.effectiveThumbnail;
    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: thumbnailUrl,
        height: Responsive.height(context, 120),
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(context),
        errorWidget: (context, url, error) => _buildPlaceholder(context),
      );
    }
    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    final gradientColors = [
      [const Color(0xFFFFD54F), const Color(0xFFFFB300)],
      [const Color(0xFF81D4FA), const Color(0xFF29B6F6)],
      [const Color(0xFFA5D6A7), const Color(0xFF66BB6A)],
      [const Color(0xFFCE93D8), const Color(0xFFAB47BC)],
      [const Color(0xFFFFAB91), const Color(0xFFFF7043)],
    ];
    final colors = gradientColors[course.id % gradientColors.length];
    
    return Container(
      height: Responsive.height(context, 120),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.school_outlined,
          size: Responsive.iconSize(context, 50),
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}




