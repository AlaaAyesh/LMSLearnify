import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/course.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: Responsive.width(context, 180),
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(Responsive.radius(context, 16)),
                  ),
                  child: course.thumbnail != null && course.thumbnail!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: course.thumbnail!,
                          height: Responsive.height(context, 120),
                          width: double.infinity,
                          fit: BoxFit.cover,
                          memCacheWidth: _thumbCacheW(context),
                          memCacheHeight: _thumbCacheH(context),
                          placeholder: (context, url) => Container(
                            height: Responsive.height(context, 120),
                            color: AppColors.primary.withOpacity(0.1),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: Responsive.width(context, 2),
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: Responsive.height(context, 120),
                            color: AppColors.primary.withOpacity(0.1),
                            child: Icon(
                              Icons.play_circle_outline,
                              size: Responsive.iconSize(context, 40),
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : Container(
                          height: Responsive.height(context, 120),
                          color: AppColors.primary.withOpacity(0.1),
                          child: Center(
                            child: Icon(
                              Icons.play_circle_outline,
                              size: Responsive.iconSize(context, 40),
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                ),
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
                if (course.hasAccess && !course.soon)
                  Positioned(
                    top: Responsive.height(context, 8),
                    right: Responsive.width(context, 8),
                    child: Container(
                      padding: Responsive.padding(context, horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(Responsive.radius(context, 8)),
                      ),
                      child: Text(
                        'متاح',
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
                  SizedBox(height: Responsive.spacing(context, 4)),
                  if (course.specialty != null)
                    Text(
                      course.specialty!.nameAr,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: Responsive.fontSize(context, 12),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  SizedBox(height: Responsive.spacing(context, 8)),
                  Row(
                    children: [
                      if (course.hasDiscount) ...[
                        Text(
                          '${course.priceBeforeDiscount} ر.س',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: Responsive.fontSize(context, 11),
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        SizedBox(width: Responsive.width(context, 4)),
                      ],
                      Text(
                        course.price != null && course.price!.isNotEmpty
                            ? '${course.price} ر.س'
                            : 'مجاني',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: Responsive.fontSize(context, 12),
                          fontWeight: FontWeight.bold,
                          color: course.price == null || course.price!.isEmpty || course.price == '0'
                              ? AppColors.success
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static int _thumbCacheW(BuildContext context) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    return (Responsive.width(context, 180) * dpr).round().clamp(360, 720);
  }

  static int _thumbCacheH(BuildContext context) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    return (Responsive.height(context, 120) * dpr).round().clamp(240, 480);
  }
}
