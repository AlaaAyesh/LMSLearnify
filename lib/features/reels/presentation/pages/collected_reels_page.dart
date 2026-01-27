import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../authentication/data/datasources/auth_local_datasource.dart';
import '../../../shorts/presentation/widgets/reels_grid.dart';
import '../../domain/entities/reel.dart';
import '../bloc/reels_bloc.dart';
import '../bloc/reels_event.dart';
import '../bloc/reels_state.dart';
import 'reels_feed_page.dart';

/// A page that shows a user's profile with their reels
/// Works like Facebook/TikTok - can view any user's profile
class CollectedReelsPage extends StatelessWidget {
  /// The user ID whose profile to display
  /// If null, displays the current logged-in user's profile
  final int? userId;
  
  /// User's display name
  final String? userName;
  
  /// User's avatar URL
  final String? userAvatarUrl;
  
  /// User's bio/description
  final String? userBio;

  const CollectedReelsPage({
    super.key,
    this.userId,
    this.userName,
    this.userAvatarUrl,
    this.userBio,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReelsBloc>(),
      child: _CollectedReelsPageContent(
        userId: userId,
        userName: userName,
        userAvatarUrl: userAvatarUrl,
        userBio: userBio,
      ),
    );
  }
}

class _CollectedReelsPageContent extends StatefulWidget {
  final int? userId;
  final String? userName;
  final String? userAvatarUrl;
  final String? userBio;

  const _CollectedReelsPageContent({
    this.userId,
    this.userName,
    this.userAvatarUrl,
    this.userBio,
  });

  @override
  State<_CollectedReelsPageContent> createState() => _CollectedReelsPageContentState();
}

class _CollectedReelsPageContentState extends State<_CollectedReelsPageContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _profileUserId;
  String? _profileUserName;
  String? _profileAvatarUrl;
  String? _profileBio;
  bool _isLoadingUser = true;
  bool _isOwnProfile = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    // If userId is provided, use it (viewing someone else's profile)
    if (widget.userId != null) {
      setState(() {
        _profileUserId = widget.userId;
        _profileUserName = widget.userName;
        _profileAvatarUrl = widget.userAvatarUrl;
        _profileBio = widget.userBio;
        _isLoadingUser = false;
      });
      
      // Check if this is the current user's own profile
      try {
        final authLocalDataSource = sl<AuthLocalDataSource>();
        final currentUser = await authLocalDataSource.getCachedUser();
        if (mounted && currentUser != null) {
          setState(() {
            _isOwnProfile = currentUser.id == widget.userId;
          });
        }
      } catch (_) {}
      
      // Load user reels
      context.read<ReelsBloc>().add(
            LoadUserReelsEvent(
              userId: _profileUserId!,
              perPage: 20,
            ),
          );
    } else {
      // No userId provided, load current user's profile
      await _loadCurrentUserProfile();
    }
  }

  Future<void> _loadCurrentUserProfile() async {
    try {
      final authLocalDataSource = sl<AuthLocalDataSource>();
      final user = await authLocalDataSource.getCachedUser();
      if (mounted) {
        setState(() {
          _profileUserId = user?.id;
          _profileUserName = user?.name;
          _profileAvatarUrl = user?.avatarUrl;
          _profileBio = null; // Current user might not have bio in cached data
          _isLoadingUser = false;
          _isOwnProfile = true;
        });
        // Load user reels by default (My Videos tab)
        if (_profileUserId != null) {
          context.read<ReelsBloc>().add(
                LoadUserReelsEvent(
                  userId: _profileUserId!,
                  perPage: 20,
                ),
              );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging && _profileUserId != null) {
      if (_tabController.index == 0) {
        // Videos tab
        context.read<ReelsBloc>().add(
              LoadUserReelsEvent(
                userId: _profileUserId!,
                perPage: 20,
              ),
            );
      } else if (_tabController.index == 1) {
        // Liked tab
        context.read<ReelsBloc>().add(
              LoadUserLikedReelsEvent(
                userId: _profileUserId!,
                perPage: 20,
              ),
            );
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
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
    final displayName = _profileUserName ?? 'مستخدم';
    final avatarUrl = _profileAvatarUrl;
    final bio = _profileBio;
    
    return Column(
      children: [
        // Avatar Circle
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 3),
          ),
          child: ClipOval(
            child: avatarUrl != null && avatarUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: avatarUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.primaryOpacity10,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => _buildDefaultAvatar(displayName),
                  )
                : _buildDefaultAvatar(displayName),
          ),
        ),
        const SizedBox(height: 16),
        // Name
        Text(
          displayName,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (bio != null && bio.isNotEmpty) ...[
          const SizedBox(height: 4),
          // Bio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              bio,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDefaultAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      color: AppColors.primaryOpacity10,
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    // Show "My Videos" only for own profile, otherwise "Videos"
    final videosTabLabel = _isOwnProfile ? 'فيديوهاتي' : 'الفيديوهات';
    final likedTabLabel = _isOwnProfile ? 'المفضلة' : 'المفضلة';
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
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
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow_outlined, size: 20),
                const SizedBox(width: 6),
                Text(videosTabLabel),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_border, size: 20),
                const SizedBox(width: 6),
                Text(likedTabLabel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyVideosTab(BuildContext context, ReelsState state) {
    if (_isLoadingUser) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (_profileUserId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _isOwnProfile ? 'يجب تسجيل الدخول لعرض فيديوهاتك' : 'المستخدم غير موجود',
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
      if (state.reels.isEmpty) {
        return _buildEmptyState();
      }
      
      return ReelsGrid(
        reels: state.reels,
        onReelTap: (reel, index) => _openReelsViewer(
          context,
          reels: state.reels,
          initialIndex: index,
        ),
        onLoadMore: state.hasMore && !state.isLoadingMore
            ? () => context.read<ReelsBloc>().add(const LoadMoreUserReelsEvent())
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
    if (_isLoadingUser) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (_profileUserId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _isOwnProfile ? 'يجب تسجيل الدخول لعرض الفيديوهات المفضلة' : 'المستخدم غير موجود',
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

    if (state is ReelsEmpty || (state is ReelsLoaded && state.reels.isEmpty)) {
      return _buildEmptyLikedState();
    }

    if (state is ReelsLoaded) {
      return ReelsGrid(
        reels: state.reels,
        onReelTap: (reel, index) {
          _openReelsViewer(
            context,
            reels: state.reels,
            initialIndex: index,
          );
        },
        onLoadMore: state.hasMore && !state.isLoadingMore
            ? () => context.read<ReelsBloc>().add(const LoadMoreUserLikedReelsEvent())
            : null,
        isLoadingMore: state.isLoadingMore,
        likedReels: state.likedReels,
        viewCounts: state.viewCounts,
        likeCounts: state.likeCounts,
      );
    }

    return _buildEmptyLikedState();
  }

  Widget _buildEmptyLikedState() {
    final message = _isOwnProfile ? 'لا توجد فيديوهات مفضلة' : 'لا توجد فيديوهات مفضلة لهذا المستخدم';
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
            message,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final message = _isOwnProfile ? 'لا توجد فيديوهات' : 'لا توجد فيديوهات لهذا المستخدم';
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
            message,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_profileUserId != null) {
                if (_tabController.index == 0) {
                  context.read<ReelsBloc>().add(
                        LoadUserReelsEvent(
                          userId: _profileUserId!,
                          perPage: 20,
                        ),
                      );
                } else {
                  context.read<ReelsBloc>().add(
                        LoadUserLikedReelsEvent(
                          userId: _profileUserId!,
                          perPage: 20,
                        ),
                      );
                }
              }
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

  void _openReelsViewer(
    BuildContext context, {
    required List<Reel> reels,
    required int initialIndex,
  }) {
    final safeInitialIndex =
        initialIndex.clamp(0, (reels.isEmpty ? 0 : reels.length - 1));

    // Open viewer seeded with the chosen list, without category filters
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<ReelsBloc>()..add(SeedReelsListEvent(reels: reels)),
          child: ReelsFeedPage(
            initialIndex: safeInitialIndex,
            showBackButton: true,
            freeReelsLimit: 0, // don't show paywall when opening from profile lists
            isTabActive: true, // allow playback outside the Shorts tab
            hideCategoryFilters: true,
          ),
        ),
      ),
    );
  }
}
