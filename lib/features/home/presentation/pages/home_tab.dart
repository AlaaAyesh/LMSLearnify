import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_background.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/home_data.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/category_item.dart';
import '../widgets/course_grid_card.dart';
import '../widgets/popular_course_card.dart';
import '../widgets/promo_banner.dart';
import '../widgets/section_header.dart';
import 'categories_page.dart';
import 'course_details_page.dart';
import 'main_navigation_page.dart';
import 'single_category_page.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<HomeBloc>()..add(LoadHomeDataEvent()),
      child: const _HomeTabContent(),
    );
  }
}

class _HomeTabContent extends StatelessWidget {
  const _HomeTabContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          const CustomBackground(),
          SafeArea(
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state is HomeLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (state is HomeError) {
                  return _buildErrorState(context, state.message);
                }

                if (state is HomeLoaded) {
                  return _buildContent(context, state.homeData);
                }

                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeData homeData) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(RefreshHomeDataEvent());
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Promo Banner
            PromoBanner(
              title: 'افتح إمكاناتك الكاملة',
              subtitle: 'استكشف آلاف الدورات التدريبية والمدربين الخبراء لتعزيز مهاراتك',
              buttonText: 'ابدأ الآن',
              onButtonPressed: () {
                // Navigate to courses
              },
            ),
            const SizedBox(height: 24),

            // Banners with auto-rotation
            if (homeData.banners.isNotEmpty) ...[
              BannerCarousel(
                banners: homeData.banners,
                autoScrollDuration: const Duration(seconds: 3),
                onBannerTap: (banner) {
                  // Handle banner tap
                },
              ),
              const SizedBox(height: 24),
            ],

            // Categories Section
            if (homeData.categories.isNotEmpty) ...[
              SectionHeader(
                title: 'التصنيفات',
                onSeeAll: () => _navigateToCategoriesPage(context, homeData),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: homeData.categories.length,
                  itemBuilder: (context, index) {
                    final category = homeData.categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: CategoryItem(
                        category: category,
                        onTap: () => _onCategoryTap(context, category, homeData),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Popular/Most Watched Courses
            if (homeData.popularCourses.isNotEmpty || homeData.latestCourses.isNotEmpty) ...[
              const SectionHeader(title: 'الأكثر مشاهدة'),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(right: 16),
                  itemCount: homeData.popularCourses.isNotEmpty 
                      ? homeData.popularCourses.length 
                      : homeData.latestCourses.length,
                  itemBuilder: (context, index) {
                    final course = homeData.popularCourses.isNotEmpty 
                        ? homeData.popularCourses[index]
                        : homeData.latestCourses[index];
                    return PopularCourseCard(
                      course: course,
                      onTap: () => _onCourseTap(context, course),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Courses by Category
            ...homeData.coursesByCategory.entries.map((entry) {
              return _buildCategorySection(context, entry.key, entry.value, homeData);
            }),

            // Free Courses
            if (homeData.freeCourses.isNotEmpty) ...[
              SectionHeader(
                title: 'دورات مجانية',
                onSeeAll: () {
                  // Navigate to free courses
                },
              ),
              const SizedBox(height: 12),
              _buildCoursesGrid(context, homeData.freeCourses),
              const SizedBox(height: 24),
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, Category category, List<Course> courses, HomeData homeData) {
    if (courses.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'دورات ${category.nameAr}',
          onSeeAll: () => _navigateToSingleCategory(context, category, courses),
        ),
        const SizedBox(height: 12),
        _buildCoursesGrid(context, courses),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCoursesGrid(BuildContext context, List<Course> courses) {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return Padding(
            padding: const EdgeInsets.only(left: 20),
            child: CourseGridCard(
              course: course,
              onTap: () => _onCourseTap(context, course),
            ),
          );
        },
      ),
    );
  }

  void _onCategoryTap(BuildContext context, Category category, HomeData homeData) {
    final courses = homeData.coursesByCategory[category] ?? [];
    _navigateToSingleCategory(context, category, courses);
  }

  void _onCourseTap(BuildContext context, Course course) {
    if (course.soon) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('هذه الدورة قادمة قريباً'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    
    context.pushWithNav(CourseDetailsPage(course: course));
  }

  void _navigateToCategoriesPage(BuildContext context, HomeData homeData) {
    context.pushWithNav(CategoriesPage(
      categories: homeData.categories,
      coursesByCategory: homeData.coursesByCategory,
    ));
  }

  void _navigateToSingleCategory(BuildContext context, Category category, List<Course> courses) {
    context.pushWithNav(SingleCategoryPage(
      category: category,
      courses: courses,
    ));
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ',
              style: TextStyle(
                fontFamily: cairoFontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: cairoFontFamily,
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<HomeBloc>().add(LoadHomeDataEvent());
              },
              icon: const Icon(Icons.refresh),
              label: Text(
                'إعادة المحاولة',
                style: TextStyle(fontFamily: cairoFontFamily),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




