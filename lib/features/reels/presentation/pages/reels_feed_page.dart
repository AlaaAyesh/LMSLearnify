import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../authentication/data/datasources/auth_local_datasource.dart';
import '../../domain/entities/reel.dart';
import '../../data/models/reel_category_model.dart';
import '../bloc/reels_bloc.dart';
import '../bloc/reels_event.dart';
import '../bloc/reels_state.dart';
import '../widgets/reel_paywall_widget.dart';
import '../widgets/reel_player_widget.dart';
import 'collected_reels_page.dart';

/// Global RouteObserver to track page visibility
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class ReelsFeedPage extends StatefulWidget {
  final int initialIndex;
  final bool showBackButton;
  final int
      freeReelsLimit; // Number of free reels before paywall (0 = unlimited)
  final bool isTabActive; // Whether the shorts tab is currently active

  const ReelsFeedPage({
    super.key,
    this.initialIndex = 0,
    this.showBackButton = true,
    this.freeReelsLimit = 5, // Default: show paywall after 5 reels
    this.isTabActive = false, // Default to false - only true when in Shorts tab
  });

  @override
  State<ReelsFeedPage> createState() => _ReelsFeedPageState();
}

class _ReelsFeedPageState extends State<ReelsFeedPage>
    with RouteAware, WidgetsBindingObserver {
  late PageController _pageController;
  int _currentIndex = 0;
  int _selectedCategoryIndex = 0; // Default to first category (General)
  bool _showPaywall = false;
  bool _isSubscribed = false;
  bool _isPageVisible =
      true; // Track if this page is visible (not covered by another page)

  List<ReelCategoryModel> _categories = []; // Categories loaded from API

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _checkSubscriptionStatus();

    // Load categories from API first, then load reels for default category
    context.read<ReelsBloc>().add(const LoadReelCategoriesEvent());

    // Set status bar to light for dark background only when tab is active
    if (widget.isTabActive) {
      _setDarkStatusBar();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When app goes to background, mark page as not visible to stop videos
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      if (_isPageVisible) {
        setState(() => _isPageVisible = false);
      }
    } else if (state == AppLifecycleState.resumed) {
      // When app comes back, restore visibility if tab is active
      if (widget.isTabActive && !_isPageVisible) {
        setState(() {
          _isPageVisible = true;
          _setDarkStatusBar();
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes to detect when page is covered
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didUpdateWidget(ReelsFeedPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle status bar and trigger rebuild when tab becomes active/inactive
    if (widget.isTabActive != oldWidget.isTabActive) {
      if (widget.isTabActive) {
        _setDarkStatusBar();
      } else {
        _setLightStatusBar();
      }
      // Force rebuild to update all ReelPlayerWidgets with new isActive state
      setState(() {});
    }
  }

  // RouteAware callbacks
  @override
  void didPush() {
    // This page became visible (pushed onto navigator)
    setState(() => _isPageVisible = true);
  }

  @override
  void didPopNext() {
    // Another page was popped, this page is visible again
    setState(() {
      _isPageVisible = true;
      if (widget.isTabActive) {
        _setDarkStatusBar();
      }
    });
  }

  @override
  void didPushNext() {
    // Another page was pushed on top, this page is now hidden
    setState(() => _isPageVisible = false);
  }

  @override
  void didPop() {
    // This page was popped
    setState(() => _isPageVisible = false);
  }

  void _setDarkStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _setLightStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> _checkSubscriptionStatus() async {
    final authLocalDataSource = sl<AuthLocalDataSource>();
    final token = await authLocalDataSource.getAccessToken();

    // For now, consider subscribed if user has token
    // In production, you'd check actual subscription status from API
    setState(() {
      _isSubscribed = token != null && token.isNotEmpty;
    });
  }

  void _checkPaywall(int index) {
    // Paywall is now handled directly in itemBuilder, no need for this logic
    // Keep this method for potential future use
  }

  void _handleSubscribe() async {
    // Pause videos before navigating
    setState(() => _isPageVisible = false);

    // Wait for the frame to rebuild and pause the video
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    final authLocalDataSource = sl<AuthLocalDataSource>();
    final token = await authLocalDataSource.getAccessToken();

    final isAuthenticated = token != null && token.isNotEmpty;

    if (!isAuthenticated) {
      // Not logged in - go to login first, then subscriptions
      final result = await Navigator.pushNamed(
        context,
        '/login',
        arguments: {
          'returnTo': 'subscriptions',
        },
      );

      if (result == true && mounted) {
        // After login, navigate to subscriptions
        await Navigator.pushNamed(context, '/subscriptions');
      }
    } else {
      // Logged in - go directly to subscriptions/payment
      await Navigator.pushNamed(context, '/subscriptions');
    }

    // Resume videos when returning
    if (mounted) {
      setState(() {
        _isPageVisible = true;
        if (widget.isTabActive) {
          _setDarkStatusBar();
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    _pageController.dispose();
    // Reset status bar
    _setLightStatusBar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Main content (full screen)
          BlocConsumer<ReelsBloc, ReelsState>(
            listener: (context, state) {
              if (state is ReelsWithCategories) {
                setState(() {
                  // Get active categories and reverse the order
                  _categories = state.categories
                      .where((c) => c.isActive)
                      .toList()
                      .reversed
                      .toList();

                  // Find "General" category (slug: "general" or name contains "عام")
                  if (_categories.isNotEmpty) {
                    final generalCategory = _categories.firstWhere(
                      (c) =>
                          c.slug.toLowerCase() == 'general' ||
                          c.name.contains('عام'),
                      orElse: () =>
                          _categories[0], // Fallback to first category
                    );

                    // Set selected index to General category
                    _selectedCategoryIndex =
                        _categories.indexOf(generalCategory);
                    if (_selectedCategoryIndex == -1) {
                      _selectedCategoryIndex = 0; // Fallback to first category
                    }

                    // Load reels for General category
                    context.read<ReelsBloc>().add(
                          LoadReelsFeedEvent(
                            perPage: 10,
                            categoryId: generalCategory.id,
                          ),
                        );
                  }
                });
              }
            },
            builder: (context, state) {
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
                        color: Colors.white54,
                        size: Responsive.iconSize(context, 64),
                      ),
                      SizedBox(height: Responsive.spacing(context, 16)),
                      Text(
                        state.message,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.white70,
                          fontSize: Responsive.fontSize(context, 16),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: Responsive.spacing(context, 24)),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<ReelsBloc>()
                              .add(const LoadReelsFeedEvent());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: Responsive.padding(
                            context,
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                Responsive.radius(context, 24)),
                          ),
                        ),
                        child: Text(
                          'إعادة المحاولة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: Responsive.fontSize(context, 14),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is ReelsEmpty) {
                return Container(
                  color:  AppColors.primary,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: Colors.white,
                          size: Responsive.iconSize(context, 90),
                        ),
                        SizedBox(height: Responsive.spacing(context, 20)),
                        Text(
                          'اشترك لفتح باقي الفيديوهات',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: Colors.white,
                            fontSize: Responsive.fontSize(context, 18),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: Responsive.spacing(context, 16)),
                        SizedBox(
                          width: Responsive.width(context, 160),
                          height: Responsive.height(context, 44),
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: navigate to subscription page
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize
                                  .shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'اشترك من هنا',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  color: AppColors.primary,
                                  fontSize: Responsive.fontSize(context, 14),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }

              if (state is ReelsLoaded) {
                return _buildReelsFeed(context, state);
              }

              // If categories are loaded but reels are not, show loading
              if (state is ReelsWithCategories) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),

          // Top bar with back button and category filters
          if (!(_currentIndex == 0 && !_isSubscribed))
            Positioned(
              top: topPadding + Responsive.height(context, 12),
              left: 0,
              right: 0,
              child: Row(
                children: [
                  // Back button (only show if enabled)
                  if (widget.showBackButton)
                    Padding(
                      padding: Responsive.padding(context, left: 16),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: Responsive.iconSize(context, 24),
                        ),
                      ),
                    ),
                  // Category filters
                  Expanded(child: _buildCategoryFilters(context)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(BuildContext context) {
    // If no categories loaded yet, show empty
    if (_categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: Responsive.height(context, 36),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: Responsive.padding(context, horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) =>
            SizedBox(width: Responsive.width(context, 10)),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedCategoryIndex;
          final category = _categories[index];

          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategoryIndex = index);
              // Filter reels by category
              context.read<ReelsBloc>().add(
                    LoadReelsFeedEvent(
                      perPage: 10,
                      categoryId: category.id,
                    ),
                  );
            },
            child: Container(
              padding: Responsive.padding(context, horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6A4BC3)
                    : const Color(0xFF2C2C36),
                borderRadius:
                    BorderRadius.circular(Responsive.radius(context, 18)),
              ),
              child: Center(
                child: Text(
                  category.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Responsive.fontSize(context, 13),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReelsFeed(BuildContext context, ReelsLoaded state) {
    // Ensure we have at least one item for paywall if user is not subscribed
    final itemCount = state.reels.isEmpty && !_isSubscribed
        ? 1 // Show paywall even if no reels
        : state.reels.length + (state.hasMore ? 1 : 0);

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      allowImplicitScrolling: true,
      itemCount: itemCount,
      onPageChanged: (index) {
        setState(() => _currentIndex = index);

        // Check if paywall should be shown
        _checkPaywall(index);

        if (state.reels.isNotEmpty &&
            index >= state.reels.length - 3 &&
            state.hasMore &&
            !state.isLoadingMore) {
          context.read<ReelsBloc>().add(const LoadMoreReelsEvent());
        }
      },
      itemBuilder: (context, index) {
        // For non-subscribed users, show paywall for the first item (index 0)
        if (index == 0 && !_isSubscribed) {
          // If we have reels, use the first reel's thumbnail, otherwise use null
          final thumbnailUrl =
              state.reels.isNotEmpty ? state.reels[0].thumbnailUrl : null;
          return ReelPaywallWidget(
            onSubscribe: _handleSubscribe,
            thumbnailUrl: thumbnailUrl,
          );
        }

        // If no reels available, show loading
        if (state.reels.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        // Loading indicator for pagination
        if (index >= state.reels.length) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        final reel = state.reels[index];
        final isLiked = state.likedReels[reel.id] ?? reel.liked;
        final viewCount = state.getViewCount(reel);
        final likeCount = state.getLikeCount(reel);

        return ReelPlayerWidget(
          key: ValueKey('reel_${reel.id}'),
          reel: reel,
          isLiked: isLiked,
          viewCount: viewCount,
          likeCount: likeCount,
          // Video only plays when: current index + tab is active + page is visible (not covered)
          isActive:
              index == _currentIndex && widget.isTabActive && _isPageVisible,
          onLike: () {
            context.read<ReelsBloc>().add(ToggleReelLikeEvent(reelId: reel.id));
          },
          onShare: () => _shareReel(reel),
          onRedirect: () => _handleRedirect(reel),
          onViewed: () {
            context.read<ReelsBloc>().add(MarkReelViewedEvent(reelId: reel.id));
          },
          onLogoTap: () => _navigateToCollectedReels(context),
        );
      },
    );
  }

  void _shareReel(Reel reel) {
    // Create reel link (remove /api/ from baseUrl to get app URL)
    final baseAppUrl = ApiConstants.baseUrl.replaceAll('/api/', '');
    final reelLink = '$baseAppUrl/reels/${reel.id}';

    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: reelLink));

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم نسخ رابط الريل',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleRedirect(Reel reel) {
    if (reel.redirectType == 'course' && reel.redirectLink.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'الذهاب إلى الكورس: ${reel.redirectLink}',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  void _navigateToCollectedReels(BuildContext context) async {
    // Pause videos before navigating
    setState(() => _isPageVisible = false);

    // Wait for the frame to rebuild and pause the video
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => const CollectedReelsPage(),
      ),
    );

    // Resume videos when returning
    if (mounted) {
      setState(() {
        _isPageVisible = true;
        if (widget.isTabActive) {
          _setDarkStatusBar();
        }
      });
    }
  }
}
