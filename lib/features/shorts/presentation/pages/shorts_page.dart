import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../reels/domain/entities/reel.dart';
import '../../../reels/presentation/bloc/reels_bloc.dart';
import '../../../reels/presentation/bloc/reels_event.dart';
import '../../../reels/presentation/bloc/reels_state.dart';
import '../../../reels/presentation/pages/reels_feed_page.dart';
import '../widgets/reels_grid.dart';

class ShortsPage extends StatefulWidget {
  const ShortsPage({super.key});

  @override
  State<ShortsPage> createState() => _ShortsPageState();
}

class _ShortsPageState extends State<ShortsPage> with SingleTickerProviderStateMixin {
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
    return BlocProvider(
      create: (_) => sl<ReelsBloc>()..add(const LoadReelsFeedEvent(perPage: 20)),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 16),
              // Logo
              _buildHeader(),
              SizedBox(height: 24),
              // Tabs
              _buildTabs(),
              SizedBox(height: 16),
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
      ),
    );
  }

  Widget _buildMyVideosTab(BuildContext context, ReelsState state) {
    if (state is ReelsLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (state is ReelsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              state.message,
              style: TextStyle(
                fontFamily: cairoFontFamily,
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
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
              child: Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontFamily: cairoFontFamily,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (state is ReelsEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'لا توجد فيديوهات',
              style: TextStyle(
                fontFamily: cairoFontFamily,
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (state is ReelsLoaded) {
      return ReelsGrid(
        reels: state.reels,
        onReelTap: (reel, index) => _onVideoTap(context, state.reels, index),
        onLoadMore: state.hasMore && !state.isLoadingMore
            ? () => context.read<ReelsBloc>().add(const LoadMoreReelsEvent())
            : null,
        isLoadingMore: state.isLoadingMore,
        // Pass real-time state for updates
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
              SizedBox(height: 16),
              Text(
                'لا توجد فيديوهات مفضلة',
                style: TextStyle(
                  fontFamily: cairoFontFamily,
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
        onReelTap: (reel, index) => _onVideoTap(context, likedReels, index),
        // Pass real-time state for updates
        likedReels: state.likedReels,
        viewCounts: state.viewCounts,
        likeCounts: state.likeCounts,
      );
    }

    if (state is ReelsLoading) {
      return Center(
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
          SizedBox(height: 16),
          Text(
            'لا توجد فيديوهات مفضلة',
            style: TextStyle(
              fontFamily: cairoFontFamily,
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo Circle
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary,
              width: 3,
            ),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/app_logo.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.primary.withOpacity(0.1),
                  child: Center(
                    child: Text(
                      'L',
                      style: TextStyle(
                        fontSize: 40,
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
        SizedBox(height: 12),
        // Title
        Text(
          'Learnify',
          style: TextStyle(
            fontFamily: cairoFontFamily,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4),
        // Subtitle with emojis
        Text(
          'I love a colorful life 🧡🧡🧡',
          style: TextStyle(
            fontFamily: cairoFontFamily,
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
        labelStyle: TextStyle(
          fontFamily: cairoFontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: cairoFontFamily,
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

  void _onVideoTap(BuildContext context, List<Reel> reels, int index) {
    // Use rootNavigator to push above the bottom navigation bar
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ReelsBloc>(),
          child: ReelsFeedPage(initialIndex: index),
        ),
      ),
    );
  }
}



