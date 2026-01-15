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
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: Responsive.width(context, 110),
        child: Padding(
          padding: Responsive.padding(context, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            // Circle Image Container
            Stack(
              children: [
                Container(
                  width: Responsive.width(context, 90),
                  height: Responsive.width(context, 90),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: Responsive.width(context, 3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.15),
                        blurRadius: Responsive.width(context, 10),
                        offset: Offset(0, Responsive.height(context, 4)),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _buildThumbnail(context),
                  ),
                ),
                // Badges
                if (course.soon)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: Responsive.padding(context, horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(Responsive.radius(context, 8)),
                      ),
                      child: Text(
                        'قريباً',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: Responsive.fontSize(context, 8),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (course.hasAccess && !course.soon)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: Responsive.padding(context, all: 4),
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: Responsive.iconSize(context, 12),
                      ),
                    ),
                  ),
                // Free badge
                if (_isFree && !course.hasAccess && !course.soon)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: Responsive.padding(context, horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(Responsive.radius(context, 8)),
                        ),
                        child: Text(
                          'مجاني',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: Responsive.fontSize(context, 9),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: Responsive.spacing(context, 6)),
            // Course Name
            Text(
              course.nameAr,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: Responsive.fontSize(context, 12),
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Price (if not free)
            if (!_isFree)
              Padding(
                padding: Responsive.padding(context, top: 2),
                child: Text(
                  '${course.price} جم',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: Responsive.fontSize(context, 11),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _isFree {
    return course.price == null || 
           course.price!.isEmpty || 
           course.price == '0' || 
           course.price == '0.00';
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
    final gradientColors = [
      [const Color(0xFFFFD54F), const Color(0xFFFFB300)],
      [const Color(0xFF81D4FA), const Color(0xFF29B6F6)],
      [const Color(0xFFA5D6A7), const Color(0xFF66BB6A)],
      [const Color(0xFFCE93D8), const Color(0xFFAB47BC)],
      [const Color(0xFFFFAB91), const Color(0xFFFF7043)],
      [const Color(0xFF80DEEA), const Color(0xFF26C6DA)],
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
      child: Center(
        child: Icon(
          Icons.school_outlined,
          size: Responsive.iconSize(context, 32),
          color: Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }
}

