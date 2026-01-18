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
          const SizedBox(height: 16),
          Text(
            'لا توجد تصنيفات',
            style: TextStyle(
              fontFamily: 'Cairo',
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
        childAspectRatio: 0.75,
        crossAxisSpacing: 20,
        mainAxisSpacing: 24,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final courses = coursesByCategory[category] ?? [];

        return _CategoryGridItem(
          category: category,
          coursesCount: courses.length,
          onTap: () => _onCategoryTap(context, category),
        );
      },
    );
  }

  void _onCategoryTap(BuildContext context, Category category) {
    context.pushWithNav(SingleCategoryPage(
      category: category,
    ));
  }
}

class _CategoryGridItem extends StatelessWidget {
  final Category category;
  final int coursesCount;
  final VoidCallback? onTap;

  const _CategoryGridItem({
    required this.category,
    required this.coursesCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Category Image
          SizedBox(
            width: 130,
            height: 130,
            child: category.imageUrl != null &&
                category.imageUrl!.isNotEmpty
                ? CachedNetworkImage(
              imageUrl: category.imageUrl!,
              fit: BoxFit.contain,
              errorWidget: (context, url, error) =>
                  Image.asset(
                    'assets/images/programing.png',
                    fit: BoxFit.contain,
                  ),
            )
                : Image.asset(
              'assets/images/programing.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 8),
          // Category Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              category.nameAr,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}