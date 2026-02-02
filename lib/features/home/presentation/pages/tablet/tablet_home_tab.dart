import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../../core/di/injection_container.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/widgets/custom_background.dart';
import '../../../../../../core/utils/responsive.dart';
import '../../../../banners/domain/entities/banner.dart' as banner_entity;
import '../../../../banners/domain/usecases/get_site_banners_usecase.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/category_course_block.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/home_data.dart';
import '../../bloc/home_bloc.dart';
import '../../bloc/home_event.dart';
import '../../bloc/home_state.dart';
import '../../widgets/banner_carousel.dart';
import '../../widgets/section_header.dart';
import '../../widgets/site_banner_carousel.dart';
import '../categories_page.dart';
import '../course_details_page.dart';
import 'tablet_main_navigation_page.dart';
import '../single_category_page.dart';

/// Tablet-specific home tab with optimized layout for larger screens
class TabletHomeTab extends StatefulWidget {
  const TabletHomeTab({super.key});

  @override
  State<TabletHomeTab> createState() => _TabletHomeTabState();
}

class _TabletHomeTabState extends State<TabletHomeTab> {
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
      child: _TabletHomeTabContent(
        siteBanners: _siteBanners,
        isLoadingBanners: _isLoadingBanners,
      ),
    );
  }
}

class _TabletHomeTabContent extends StatelessWidget {
  final List<banner_entity.Banner> siteBanners;
  final bool isLoadingBanners;

  const _TabletHomeTabContent({
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
                  if (state.cachedData != null) {
                    return _buildContent(context, state.cachedData!);
                  }
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (state is HomeError) {
                  if (state.cachedData != null) {
                    return _buildContent(context, state.cachedData!);
                  }
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
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Site Banners
                if (!isLoadingBanners && siteBanners.isNotEmpty) ...[
                  SizedBox(
                    height: 300,
                    child: SiteBannerCarousel(
                      banners: siteBanners,
                      autoScrollDuration: const Duration(seconds: 20),
                    ),
                  ),
                  const SizedBox(height: 32),
                ] else if (homeData.banners.isNotEmpty) ...[
                  SizedBox(
                    height: 300,
                    child: BannerCarousel(
                      banners: homeData.banners,
                      autoScrollDuration: const Duration(seconds: 3),
                      onBannerTap: (banner) {},
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Categories Section - Grid layout for tablet
                if (homeData.categories.isNotEmpty) ...[
                  SectionHeader(
                    title: 'التصنيفات',
                    onSeeAll: () => _navigateToCategoriesPage(context, homeData),
                  ),
                  const SizedBox(height: 16),
                  // على التابلت نجعل التصنيفات في سطر واحد مع سكرول أفقي
                  SizedBox(
                    height: Responsive.isLandscape(context) ? 280 : 230,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: homeData.categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 20),
                      itemBuilder: (context, index) {
                        final category = homeData.categories[index];
                        return SizedBox(
                          width: Responsive.isLandscape(context) ? 280 : 220,
                          child: _TabletCategoryItem(
                            category: category,
                            onTap: () => _onCategoryTap(context, category, homeData),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                ],

                // Popular Courses - Grid layout for tablet
                if (homeData.popularCourses.isNotEmpty) ...[
                  SectionHeader(
                    title: 'الأكثر مشاهدة',
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          childAspectRatio: 0.8, // Adjusted to prevent overflow
                        ),
                        itemCount: homeData.popularCourses.length,
                        itemBuilder: (context, index) {
                          final course = homeData.popularCourses[index];
                          return _TabletPopularCourseCard(
                            course: course,
                            onTap: () => _onCourseTap(context, course),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],

                // Courses by Category - Grid layout for tablet
                if (homeData.categoryCourseBlocks.isNotEmpty) ...[
                  ...homeData.categoryCourseBlocks.map((block) {
                    return _buildCategoryCourseBlockSection(context, block);
                  }),
                ] else ...[
                  ...homeData.coursesByCategory.entries.map((entry) {
                    return _buildCategorySection(context, entry.key, entry.value, homeData);
                  }),
                ],

                // Free Courses - Grid layout
                if (homeData.freeCourses.isNotEmpty) ...[
                  SectionHeader(
                    title: 'دورات مجانية',
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.9, // Adjusted to prevent overflow
                        ),
                        itemCount: homeData.freeCourses.length,
                        itemBuilder: (context, index) {
                          final course = homeData.freeCourses[index];
                          return _TabletCourseGridCard(
                            course: course,
                            onTap: () => _onCourseTap(context, course),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
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
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.9, // Adjusted to prevent overflow
              ),
              itemCount: block.courses.length,
              itemBuilder: (context, index) {
                final course = block.courses[index];
                return _TabletCourseGridCard(
                  course: course,
                  onTap: () => _onCourseTap(context, course),
                );
              },
            );
          },
        ),
        const SizedBox(height: 40),
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
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.9, // Adjusted to prevent overflow
              ),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return _TabletCourseGridCard(
                  course: course,
                  onTap: () => _onCourseTap(context, course),
                );
              },
            );
          },
        ),
        const SizedBox(height: 40),
      ],
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
    
    context.pushWithNavTablet(CourseDetailsPage(course: course));
  }

  void _navigateToCategoriesPage(BuildContext context, HomeData homeData) {
    context.pushWithNavTablet(CategoriesPage(
      categories: homeData.categories,
      coursesByCategory: homeData.coursesByCategory,
    ));
  }

  void _navigateToSingleCategory(BuildContext context, Category category, List<Course> courses) {
    context.pushWithNavTablet(SingleCategoryPage(
      category: category,
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
                fontFamily: 'Cairo',
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
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<HomeBloc>().add(LoadHomeDataEvent());
              },
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(fontFamily: 'Cairo'),
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

/// Tablet-optimized category item with fixed height to prevent overflow
class _TabletCategoryItem extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;

  const _TabletCategoryItem({
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image with flexible size
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.backgroundLight,
                ),
                child: category.imageUrl != null && category.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: category.imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              Image.asset(
                            'assets/images/programing.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                    : Image.asset(
                        'assets/images/programing.png',
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            const SizedBox(height: 6),
            // Category Name with flexible height
            Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  category.nameAr,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tablet-optimized popular course card with better spacing
class _TabletPopularCourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;

  const _TabletPopularCourseCard({
    required this.course,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final radius = 16.0;
        final imageHeight = cardWidth * 0.7; // Adjusted for tablet
        final playSize = cardWidth * 0.22;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image section
                SizedBox(
                  height: imageHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(radius),
                        ),
                        child: _buildThumbnail(),
                      ),
                      // Play button
                      Center(
                        child: Container(
                          width: playSize,
                          height: playSize,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: playSize * 0.5,
                          ),
                        ),
                      ),
                      // Soon overlay
                      if (course.soon)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(radius),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'قريباً',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Title section with fixed padding
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    height: 48, // Fixed height for title
                    child: Text(
                      course.nameAr,
                      maxLines: 2,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThumbnail() {
    final thumbnailUrl = course.effectiveThumbnail;
    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: thumbnailUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.backgroundLight,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Tablet-optimized course grid card with fixed dimensions
class _TabletCourseGridCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;

  const _TabletCourseGridCard({
    required this.course,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        // تقليل حجم الصورة لتجنب الـ overflow
        final imageSize = (constraints.maxHeight - 56).clamp(0.0, cardWidth * 0.65);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Circular image
                Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.grey.withOpacity(0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildThumbnail(),
                        // Soon overlay
                        if (course.soon)
                          Container(
                            color: Colors.black.withValues(alpha: 0.5),
                            child: const Center(
                              child: Text(
                                'قريباً',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
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
                const SizedBox(height: 6),
                // Title with flexible height
                Flexible(
                  child: Text(
                    course.nameAr,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThumbnail() {
    final thumbnailUrl = course.effectiveThumbnail;
    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: thumbnailUrl,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Image.asset(
      'assets/images/paint.png',
      fit: BoxFit.cover,
    );
  }
}
