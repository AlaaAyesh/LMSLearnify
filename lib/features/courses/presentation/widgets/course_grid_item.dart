import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../home/domain/entities/course.dart';

class CourseGridItem extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;

  const CourseGridItem({
    super.key,
    required this.course,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            // Thumbnail
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(Responsive.radius(context, 16)),
                    ),
                    child: _buildThumbnail(context),
                  ),
                  // Badges
                  _buildBadges(),
                ],
              ),
            ),
            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: Responsive.padding(context, all: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Course name
                    Text(
                      course.nameAr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: cairoFontFamily,
                        fontSize: Responsive.fontSize(context, 13),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    // Price and rating row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price
                        _buildPrice(context),
                        // Rating
                        if (course.reviewsAvg != null)
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: Responsive.iconSize(context, 14),
                                color: AppColors.warning,
                              ),
                              SizedBox(width: Responsive.width(context, 2)),
                              Text(
                                course.reviewsAvg!,
                                style: TextStyle(
                                  fontFamily: cairoFontFamily,
                                  fontSize: Responsive.fontSize(context, 11),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                      ],
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

  Widget _buildThumbnail(BuildContext context) {
    final thumbnailUrl = course.effectiveThumbnail;
    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: thumbnailUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(context),
        errorWidget: (context, url, error) => _buildPlaceholder(context),
      );
    }
    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    // Use different gradient colors based on course ID for variety
    final gradientColors = [
      [const Color(0xFFFFD54F), const Color(0xFFFFB300)], // Yellow/Orange
      [const Color(0xFF81D4FA), const Color(0xFF29B6F6)], // Light Blue
      [const Color(0xFFA5D6A7), const Color(0xFF66BB6A)], // Green
      [const Color(0xFFCE93D8), const Color(0xFFAB47BC)], // Purple
      [const Color(0xFFFFAB91), const Color(0xFFFF7043)], // Orange/Red
      [const Color(0xFF80DEEA), const Color(0xFF26C6DA)], // Cyan
    ];
    
    final colorIndex = course.id % gradientColors.length;
    final colors = gradientColors[colorIndex];
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            right: -Responsive.width(context, 20),
            bottom: -Responsive.height(context, 20),
            child: Icon(
              _getCategoryIcon(),
              size: Responsive.iconSize(context, 80),
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          // Play button
          Center(
            child: Container(
              padding: Responsive.padding(context, all: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: Responsive.width(context, 8),
                    offset: Offset(0, Responsive.height(context, 2)),
                  ),
                ],
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                size: Responsive.iconSize(context, 28),
                color: colors[1],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon() {
    // Try to determine icon from category or course name
    final name = course.nameAr.toLowerCase() + course.nameEn.toLowerCase();
    
    if (name.contains('game') || name.contains('ألعاب') || name.contains('لعب')) {
      return Icons.sports_esports;
    } else if (name.contains('python') || name.contains('بايثون') || name.contains('code') || name.contains('برمج')) {
      return Icons.code;
    } else if (name.contains('web') || name.contains('مواقع') || name.contains('ويب')) {
      return Icons.web;
    } else if (name.contains('design') || name.contains('تصميم')) {
      return Icons.design_services;
    } else if (name.contains('logic') || name.contains('منطق')) {
      return Icons.psychology;
    } else if (name.contains('language') || name.contains('لغة')) {
      return Icons.translate;
    }
    return Icons.school;
  }

  Widget _buildBadges() {
    return Positioned(
      top: Responsive.height(context, 8),
      right: Responsive.width(context, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (course.soon)
            Container(
              padding: Responsive.padding(context, horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(Responsive.radius(context, 8)),
              ),
              child: Text(
                'قريباً',
                style: TextStyle(
                  fontFamily: cairoFontFamily,
                  fontSize: Responsive.fontSize(context, 10),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          if (course.hasAccess && !course.soon)
            Container(
              padding: Responsive.padding(context, horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(Responsive.radius(context, 8)),
              ),
              child: Text(
                'متاح',
                style: TextStyle(
                  fontFamily: cairoFontFamily,
                  fontSize: Responsive.fontSize(context, 10),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          if (course.userHasCertificate) ...[
            SizedBox(height: Responsive.spacing(context, 4)),
            Container(
              padding: Responsive.padding(context, horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(Responsive.radius(context, 8)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.workspace_premium,
                    size: Responsive.iconSize(context, 12),
                    color: Colors.white,
                  ),
                  SizedBox(width: Responsive.width(context, 2)),
                  Text(
                    'شهادة',
                    style: TextStyle(
                      fontFamily: cairoFontFamily,
                      fontSize: Responsive.fontSize(context, 10),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrice(BuildContext context) {
    final hasDiscount = course.hasDiscount;
    final isFree = course.price == null || course.price!.isEmpty || course.price == '0';

    if (isFree) {
      return Container(
        padding: Responsive.padding(context, horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(Responsive.radius(context, 4)),
        ),
        child: Text(
          'مجاني',
          style: TextStyle(
            fontFamily: cairoFontFamily,
            fontSize: Responsive.fontSize(context, 11),
            fontWeight: FontWeight.bold,
            color: AppColors.success,
          ),
        ),
      );
    }

    return Row(
      children: [
        if (hasDiscount) ...[
          Text(
            '${course.priceBeforeDiscount}',
            style: TextStyle(
              fontFamily: cairoFontFamily,
              fontSize: Responsive.fontSize(context, 10),
              color: AppColors.textSecondary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          SizedBox(width: Responsive.width(context, 4)),
        ],
        Text(
          '${course.price} جم',
          style: TextStyle(
            fontFamily: cairoFontFamily,
            fontSize: Responsive.fontSize(context, 12),
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}





