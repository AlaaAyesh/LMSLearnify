import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../home/presentation/pages/main_navigation_page.dart';
import '../../../shorts/presentation/pages/shorts_page.dart';
import '../../../shorts/presentation/widgets/reels_grid.dart';
import '../bloc/reels_bloc.dart';
import '../bloc/reels_event.dart';
import '../bloc/reels_state.dart';
import 'reels_feed_page.dart';

/// A page that shows all reels in a grid format
/// Accessed when user taps on Learnify logo/name in the reels player
class CollectedReelsPage extends StatelessWidget {
  const CollectedReelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReelsBloc>()..add(const LoadReelsFeedEvent(perPage: 20)),
      child: const _CollectedReelsPageContent(),
    );
  }
}

class _CollectedReelsPageContent extends StatefulWidget {
  const _CollectedReelsPageContent();

  @override
  State<_CollectedReelsPageContent> createState() => _CollectedReelsPageContentState();
}

class _CollectedReelsPageContentState extends State<_CollectedReelsPageContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: '',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Logo and title
            _buildHeader(),
            const SizedBox(height: 24),
            // Tabs
            _buildTabs(),
            const SizedBox(height: 16),
            // Content
            Expanded(
              child: BlocBuilder<ReelsBloc, ReelsState>(
                builder: (context, state) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMyVideosTab(context, state),
                      _buildLikedVideosTab(context, state),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo Circle
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 3),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/app_logo.png',
              fit: BoxFit.cover,
              cacheWidth: 240,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.primaryOpacity10,
                  child: const Center(
                    child: Text(
                      'L',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Title
        const Text(
          'Learnify',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        // Subtitle
        const Text(
          '🧡🧡🧡I love a colorful life ',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 60),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primary,
        indicatorWeight: 2,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow_outlined, size: 20),
                SizedBox(width: 6),
                Text('My Videos'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 20),
                SizedBox(width: 6),
                Text('Liked'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyVideosTab(BuildContext context, ReelsState state) {
    if (state is ReelsLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (state is ReelsError) {
      return _buildErrorState(context, state.message);
    }

    if (state is ReelsEmpty) {
      return _buildEmptyState();
    }

    if (state is ReelsLoaded) {
      return ReelsGrid(
        reels: state.reels,
        onReelTap: (reel, index) => _onReelTap(context, state, index),
        onLoadMore: state.hasMore && !state.isLoadingMore
            ? () => context.read<ReelsBloc>().add(const LoadMoreReelsEvent())
            : null,
        isLoadingMore: state.isLoadingMore,
        likedReels: state.likedReels,
        viewCounts: state.viewCounts,
        likeCounts: state.likeCounts,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildLikedVideosTab(BuildContext context, ReelsState state) {
    if (state is ReelsLoaded) {
      // Filter liked videos
      final likedReels = state.reels.where((reel) {
        return state.likedReels[reel.id] == true || reel.liked;
      }).toList();

      if (likedReels.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد فيديوهات مفضلة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }

      return ReelsGrid(
        reels: likedReels,
        onReelTap: (reel, index) {
          // Find the actual index in the full list
          final actualIndex = state.reels.indexOf(reel);
          _onReelTap(context, state, actualIndex >= 0 ? actualIndex : index);
        },
        likedReels: state.likedReels,
        viewCounts: state.viewCounts,
        likeCounts: state.likeCounts,
      );
    }

    if (state is ReelsLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد فيديوهات مفضلة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
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
            Icons.video_library_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد فيديوهات',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ReelsBloc>().add(const LoadReelsFeedEvent(perPage: 20));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'إعادة المحاولة',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onReelTap(BuildContext context, ReelsLoaded state, int index) {
    // Set the initial index for ShortsPage
    ShortsPage.setInitialIndex(index);
    
    // Try to get main navigation before popping
    final mainNav = context.mainNavigation;
    
    // Pop back to the main navigation (root)
    Navigator.of(context, rootNavigator: true).popUntil((route) {
      // Keep popping until we reach the main navigation
      return route.isFirst;
    });
    
    // Switch to Shorts tab after navigation completes
    if (mainNav != null) {
      // Use post-frame callback to ensure navigation is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          mainNav.switchToTab(1);
          // Also update tab notifier if we can access it
          try {
            final tabNotifier = TabIndexProvider.of(context);
            if (tabNotifier != null) {
              tabNotifier.value = 1;
            }
          } catch (e) {
            // Context might not be available, but mainNav.switchToTab should still work
          }
        }
      });
    }
  }
}
