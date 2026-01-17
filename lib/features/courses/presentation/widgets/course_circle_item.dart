import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../home/domain/entities/course.dart';

/// A circular course item widget used in the All Courses Page
/// Displays the course image in a circle with the name below
class CourseCircleItem extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;

  const CourseCircleItem({
    super.key,
    required this.course,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isComingSoon = course.soon;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: isComingSoon ? null : onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Main Circle
              Container(
                width: Responsive.width(context, 120),
                height: Responsive.width(context, 120),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: Responsive.padding(context, all: 16),
                  child: ClipOval(
                    child: _buildThumbnail(context),
                  ),
                ),
              ),

              // Coming Soon Overlay (centered like image)
              if (isComingSoon)
                Container(
                  width: Responsive.width(context, 120),
                  height: Responsive.width(context, 120),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.65),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'قريبآ',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      shadows: [
                        Shadow(
                          offset: const Offset(3, 3),
                          blurRadius: 0,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ],
                      fontSize: Responsive.fontSize(context, 40),
                      fontWeight: FontWeight.bold,
                      color: AppColors.soonText,
                    ),
                  ),
                ),
            ],
          ),
        ),

        SizedBox(height: Responsive.spacing(context, 12)),

        // Course Title
        Text(
          course.nameAr,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: Responsive.fontSize(context, 14),
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    final thumbnailUrl = course.effectiveThumbnail;

    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: thumbnailUrl,
        fit: BoxFit.contain,
        placeholder: (context, url) => _defaultImage(),
        errorWidget: (context, url, error) => _defaultImage(),
      );
    }

    return _defaultImage();
  }

  Widget _defaultImage() {
    return Image.asset(
      'assets/images/paint.png',
      fit: BoxFit.contain,
    );
  }

}

