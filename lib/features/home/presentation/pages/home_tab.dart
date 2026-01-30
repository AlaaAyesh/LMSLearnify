import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_background.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/category_course_block.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/home_data.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/site_banner_carousel.dart';
import '../widgets/category_item.dart';
import '../widgets/course_grid_card.dart';
import '../widgets/popular_course_card.dart';
import '../widgets/section_header.dart';
import '../../../banners/domain/entities/banner.dart' as banner_entity;
import '../../../banners/domain/usecases/get_site_banners_usecase.dart';
import 'categories_page.dart';
import 'course_details_page.dart';
import 'main_navigation_page.dart';
import 'popular_courses_page.dart';
import 'single_category_page.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<banner_entity.Banner> _siteBanners = [];
  bool _isLoadingBanners = true;
  final GetSiteBannersUseCase _getSiteBannersUseCase = sl<GetSiteBannersUseCase>();

  @override
  void initState() {
    super.initState();
    _loadSiteBanners();
  }

  Future<void> _loadSiteBanners() async {
    setState(() => _isLoadingBanners = true);
    final result = await _getSiteBannersUseCase(perPage: 10, page: 1);
    result.fold(
      (failure) {
        // Silently fail - banners are optional
        if (mounted) {
          setState(() {
            _isLoadingBanners = false;
            _siteBanners = [];
          });
        }
      },
      (response) {
        if (mounted) {
          setState(() {
            _isLoadingBanners = false;
            _siteBanners = response.banners;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<HomeBloc>()..add(LoadHomeDataEvent()),
      child: _HomeTabContent(
        siteBanners: _siteBanners,
        isLoadingBanners: _isLoadingBanners,
      ),
    );
  }
}

class _HomeTabContent extends StatelessWidget {
  final List<banner_entity.Banner> siteBanners;
  final bool isLoadingBanners;

  const _HomeTabContent({
    required this.siteBanners,
    required this.isLoadingBanners,
  });

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
                  return const Center(
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

                return const Center(
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
            SizedBox(height: Responsive.spacing(context, 16)),

            // Site Banners (from API) - Show first if available
            if (!isLoadingBanners && siteBanners.isNotEmpty) ...[
              SiteBannerCarousel(
                banners: siteBanners,
                autoScrollDuration: const Duration(seconds: 20),
              ),
              SizedBox(height: Responsive.spacing(context, 24)),
            ],

            // Home Banners (from home API) - Show as fallback
            if (homeData.banners.isNotEmpty && (isLoadingBanners || siteBanners.isEmpty)) ...[
              BannerCarousel(
                banners: homeData.banners,
                autoScrollDuration: const Duration(seconds: 3),
                onBannerTap: (banner) {
                  // Handle banner tap
                },
              ),
              SizedBox(height: Responsive.spacing(context, 24)),
            ],

            // Categories Section
            if (homeData.categories.isNotEmpty) ...[
              SectionHeader(
                title: 'التصنيفات',
                onSeeAll: () => _navigateToCategoriesPage(context, homeData),
              ),
              SizedBox(
                height: Responsive.height(context, 125),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: Responsive.padding(context, horizontal: 16),
                  itemCount: homeData.categories.length,
                  itemBuilder: (context, index) {
                    final category = homeData.categories[index];
                    return Padding(
                      padding: Responsive.padding(context, left: 16),
                      child: CategoryItem(
                        category: category,
                        onTap: () => _onCategoryTap(context, category, homeData),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: Responsive.spacing(context, 24)),
            ],

            // Popular/Most Watched Courses - الأكثر مشاهدة (best_seller من API)
            if (homeData.popularCourses.isNotEmpty) ...[
              SectionHeader(
                title: 'الأكثر مشاهدة',
                onSeeAll: () {
                  _navigateToPopularCourses(context, homeData.popularCourses);
                },
              ),
              SizedBox(height: Responsive.spacing(context, 12)),
              SizedBox(
                height: Responsive.height(context, 200),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: Responsive.padding(context, right: 16),
                  itemCount: homeData.popularCourses.length,
                  itemBuilder: (context, index) {
                    final course = homeData.popularCourses[index];
                    return Padding(
                      padding: Responsive.padding(context, left: 16),
                      child: PopularCourseCard(
                        course: course,
                        onTap: () => _onCourseTap(context, course),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: Responsive.spacing(context, 24)),
            ],

            // Courses by Category from category_course_blocks (API format)
            if (homeData.categoryCourseBlocks.isNotEmpty) ...[
              ...homeData.categoryCourseBlocks.map((block) {
                return _buildCategoryCourseBlockSection(context, block);
              }),
            ] else ...[
              // Fallback: Use coursesByCategory if category_course_blocks is empty
              ...homeData.coursesByCategory.entries.map((entry) {
                return _buildCategorySection(context, entry.key, entry.value, homeData);
              }),
            ],

            // Free Courses
            if (homeData.freeCourses.isNotEmpty) ...[
              SectionHeader(
                title: 'دورات مجانية',
                onSeeAll: () {
                  // Navigate to free courses
                },
              ),
              SizedBox(height: Responsive.spacing(context, 12)),
              _buildCoursesGrid(context, homeData.freeCourses),
              SizedBox(height: Responsive.spacing(context, 24)),
            ],

            SizedBox(height: Responsive.spacing(context, 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCourseBlockSection(BuildContext context, CategoryCourseBlock block) {
    if (block.courses.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'دورات ${block.category.nameAr}',
          onSeeAll: () => _navigateToSingleCategory(context, block.category, block.courses),
        ),
        SizedBox(height: Responsive.spacing(context, 12)),
        _buildCoursesGrid(context, block.courses),
        SizedBox(height: Responsive.spacing(context, 24)),
      ],
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
        SizedBox(height: Responsive.spacing(context, 12)),
        _buildCoursesGrid(context, courses),
        SizedBox(height: Responsive.spacing(context, 24)),
      ],
    );
  }

  Widget _buildCoursesGrid(BuildContext context, List<Course> courses) {
    return SizedBox(
      height: Responsive.height(context, 130),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: Responsive.padding(context, horizontal: 16),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return Padding(
            padding: Responsive.padding(context, left: 20),
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
        const SnackBar(
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
    ));
  }

  void _navigateToPopularCourses(BuildContext context, List<Course> popularCourses) {
    context.pushWithNav(PopularCoursesPage(
      initialCourses: popularCourses,
    ));
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: Responsive.padding(context, all: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: Responsive.iconSize(context, 80),
              color: Colors.red[400],
            ),
            SizedBox(height: Responsive.spacing(context, 16)),
            Text(
              'حدث خطأ',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: Responsive.fontSize(context, 18),
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: Responsive.spacing(context, 8)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: Responsive.fontSize(context, 14),
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: Responsive.spacing(context, 24)),
            ElevatedButton.icon(
              onPressed: () {
                context.read<HomeBloc>().add(LoadHomeDataEvent());
              },
              icon: Icon(Icons.refresh, size: Responsive.iconSize(context, 20)),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: Responsive.padding(context, horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




