import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';

import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_background.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/course.dart';
import 'main_navigation_page.dart';
import 'single_category_page.dart';

class CategoriesPage extends StatelessWidget {
  final List<Category> categories;
  final Map<Category, List<Course>> coursesByCategory;

  const CategoriesPage({
    super.key,
    required this.categories,
    required this.coursesByCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(title: 'التصنيفات'),
      body: Stack(
        children: [
          const CustomBackground(),
          categories.isEmpty
              ? _buildEmptyState()
              : _buildCategoriesGrid(context),
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
            Icons.category_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'لا توجد تصنيفات',
            style: TextStyle(
              fontFamily: cairoFontFamily,
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 20,
        mainAxisSpacing: 24,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryGridItem(
          category: category,
          onTap: () => _onCategoryTap(context, category),
        );
      },
    );
  }

  void _onCategoryTap(BuildContext context, Category category) {
    // Get courses for this category
    final courses = coursesByCategory[category] ?? [];
    
    // Navigate to single category page using nested navigator
    context.pushWithNav(SingleCategoryPage(
      category: category,
      courses: courses,
    ));
  }
}

class _CategoryGridItem extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;

  const _CategoryGridItem({
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                color: AppColors.primary.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: category.imageUrl != null && category.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: category.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.primary.withOpacity(0.1),
                        child: const Icon(
                          Icons.category,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.primary.withOpacity(0.1),
                        child: const Icon(
                          Icons.category,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.primary.withOpacity(0.1),
                      child: const Icon(
                        Icons.category,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            category.nameAr,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: cairoFontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}




