import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/course.dart';

class CourseGridCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;

  const CourseGridCard({
    super.key,
    required this.course,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: Responsive.width(context, 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: Responsive.width(context, 90),
              height: Responsive.width(context, 90),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: Responsive.width(context, 2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: Responsive.width(context, 8),
                  offset: Offset(0, Responsive.height(context, 2)),
                ),
              ],
            ),
            child: ClipOval(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildThumbnail(context),
                  // Soon overlay
                  if (course.soon)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Text(
                          'قريباً',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: Responsive.fontSize(context, 12),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 6)),
          Text(
            course.nameAr,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: Responsive.fontSize(context, 11),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.2,
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
          size: Responsive.iconSize(context, 30),
          color: Colors.white.withOpacity(0.6),
        ),
      ),
    );
  }
}




