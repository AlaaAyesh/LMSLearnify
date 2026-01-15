import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_background.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/course.dart';
import 'course_details_page.dart';
import 'main_navigation_page.dart';

class SingleCategoryPage extends StatelessWidget {
  final Category category;
  final List<Course> courses;

  const SingleCategoryPage({
    super.key,
    required this.category,
    required this.courses,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(title: 'دورات ${category.nameAr}'),
      body: Stack(
        children: [
          const CustomBackground(),
          courses.isEmpty ? _buildEmptyState() : _buildCoursesGrid(context),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد دورات في هذا التصنيف',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesGrid(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 20,
        mainAxisSpacing: 24,
      ),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return _CourseGridItem(
          course: course,
          onTap: course.soon ? null : () => _onCourseTap(context, course),
        );
      },
    );
  }

  void _onCourseTap(BuildContext context, Course course) {
    context.pushWithNav(CourseDetailsPage(course: course));
  }
}

class _CourseGridItem extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;

  const _CourseGridItem({
    required this.course,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isComingSoon = course.soon;

    return GestureDetector(
      onTap: isComingSoon ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.grey.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildThumbnail(),
                  // Coming Soon overlay
                  if (isComingSoon)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(
                        child: Text(
                          'قريباً',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
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
          const SizedBox(height: 12),
          Text(
            course.nameAr,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isComingSoon ? Colors.grey[600] : AppColors.textPrimary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    final thumbnailUrl = course.effectiveThumbnail;
    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: thumbnailUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Image.asset(
      'assets/images/paint.png',
      fit: BoxFit.cover,
    );
  }
}