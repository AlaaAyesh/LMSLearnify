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
    // HomeBloc is provided by TabletMainNavigationPage so it isn't recreated on setState (banners).
    return _TabletHomeTabContent(
      siteBanners: _siteBanners,
      isLoadingBanners: _isLoadingBanners,
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
              buildWhen: (previous, current) => previous != current,
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
    final contentWidth = context.sw;
    final contentHeight = context.sh;
    final isLandscape = context.isLandscape;

    final double horizontalPadding =
        (contentWidth * 0.035).clamp(24.0, 48.0).toDouble();
    final double verticalPadding =
        (contentHeight * 0.025).clamp(20.0, 40.0).toDouble();

    final double siteBannerHeight =
        (contentHeight * (isLandscape ? 0.25 : 0.3)).clamp(260.0, 420.0).toDouble();
    final double defaultBannerHeight =
        (contentHeight * (isLandscape ? 0.3 : 0.35)).clamp(230.0, 380.0).toDouble();

    final double categoriesSectionHeight =
        (contentHeight * (isLandscape ? 0.32 : 0.28)).clamp(210.0, 320.0).toDouble();
    final double categoryCardWidth =
        (contentWidth * (isLandscape ? 0.26 : 0.24)).clamp(200.0, 320.0).toDouble();

    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(RefreshHomeDataEvent());
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isLoadingBanners && siteBanners.isNotEmpty) ...[
                  SizedBox(
                    height: siteBannerHeight,
                    child: SiteBannerCarousel(
                      banners: siteBanners,
                      autoScrollDuration: const Duration(seconds: 20),
                    ),
                  ),
                ] else if (homeData.banners.isNotEmpty) ...[
                  SizedBox(
                    height: defaultBannerHeight,
                    child: BannerCarousel(
                      banners: homeData.banners,
                      autoScrollDuration: const Duration(seconds: 3),
                      onBannerTap: (banner) {},
                    ),
                  ),
                ],

                if (homeData.categories.isNotEmpty) ...[
                  SectionHeader(
                    title: 'التصنيفات',
                    onSeeAll: () => _navigateToCategoriesPage(context, homeData),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: categoriesSectionHeight,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: homeData.categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 20),
                      itemBuilder: (context, index) {
                        final category = homeData.categories[index];
                        return SizedBox(
                          width: categoryCardWidth,
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

                if (homeData.popularCourses.isNotEmpty) ...[
                  SectionHeader(
                    title: 'الأكثر مشاهدة',
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final maxWidth = constraints.maxWidth;
                      final isLandscape = context.isLandscape;

                      int crossAxisCount;
                      if (maxWidth >= 1100) {
                        crossAxisCount = 4;
                      } else if (maxWidth >= 800) {
                        crossAxisCount = 3;
                      } else {
                        crossAxisCount = 2;
                      }

                      final double spacing =
                          (maxWidth * 0.02).clamp(16.0, 28.0).toDouble();
                      final double childAspectRatio = isLandscape ? 1.0 : 0.9;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          childAspectRatio: childAspectRatio,
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

                if (homeData.categoryCourseBlocks.isNotEmpty) ...[
                  ...homeData.categoryCourseBlocks.map((block) {
                    return _buildCategoryCourseBlockSection(context, block);
                  }),
                ] else ...[
                  ...homeData.coursesByCategory.entries.map((entry) {
                    return _buildCategorySection(context, entry.key, entry.value, homeData);
                  }),
                ],

                if (homeData.freeCourses.isNotEmpty) ...[
                  SectionHeader(
                    title: 'دورات مجانية',
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final maxWidth = constraints.maxWidth;
                      final isLandscape = context.isLandscape;

                      int crossAxisCount;
                      if (maxWidth >= 1100) {
                        crossAxisCount = 5;
                      } else if (maxWidth >= 900) {
                        crossAxisCount = 4;
                      } else {
                        crossAxisCount = 3;
                      }

                      final double spacing =
                          (maxWidth * 0.018).clamp(14.0, 24.0).toDouble();
                      final double childAspectRatio = isLandscape ? 0.95 : 0.9;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          childAspectRatio: childAspectRatio,
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
            final maxWidth = constraints.maxWidth;
            final isLandscape = context.isLandscape;

            int crossAxisCount;
            if (maxWidth >= 1100) {
              crossAxisCount = 5;
            } else if (maxWidth >= 900) {
              crossAxisCount = 4;
            } else {
              crossAxisCount = 3;
            }

            final double spacing =
                (maxWidth * 0.018).clamp(14.0, 24.0).toDouble();
            final double childAspectRatio = isLandscape ? 0.95 : 0.9;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: childAspectRatio,
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
            final maxWidth = constraints.maxWidth;
            final isLandscape = context.isLandscape;

            int crossAxisCount;
            if (maxWidth >= 1100) {
              crossAxisCount = 5;
            } else if (maxWidth >= 900) {
              crossAxisCount = 4;
            } else {
              crossAxisCount = 3;
            }

            final double spacing =
                (maxWidth * 0.018).clamp(14.0, 24.0).toDouble();
            final double childAspectRatio = isLandscape ? 0.95 : 0.9;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: childAspectRatio,
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
        final imageHeight = cardWidth * 0.7;
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
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(radius),
                        ),
                        child: _buildThumbnail(),
                      ),
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
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    height: 48,
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
        final isLandscape = context.isLandscape;

        final availableHeight = (constraints.maxHeight - 32).clamp(70.0, double.infinity);
        double targetSize = cardWidth * (isLandscape ? 0.27 : 0.32);
        targetSize = targetSize.clamp(90.0, 180.0);
        final imageSize = (targetSize + 6).clamp(0.0, availableHeight);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                Flexible(
                  child: Text(
                    course.nameAr,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
              fontSize: 14.5,
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
