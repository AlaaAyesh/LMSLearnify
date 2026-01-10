import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../authentication/data/datasources/auth_local_datasource.dart';
import '../../domain/entities/reel.dart';
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
  final int freeReelsLimit; // Number of free reels before paywall (0 = unlimited)
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

class _ReelsFeedPageState extends State<ReelsFeedPage> with RouteAware, WidgetsBindingObserver {
  late PageController _pageController;
  int _currentIndex = 0;
  int _selectedCategoryIndex = 0; // عام selected by default (leftmost)
  bool _showPaywall = false;
  bool _isSubscribed = false;
  bool _isPageVisible = true; // Track if this page is visible (not covered by another page)
  
  // Display order (left to right): عام, انجلش, رسم, برمجة
  final List<String> _categories = ['عام', 'انجلش', 'رسم', 'برمجة'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _checkSubscriptionStatus();

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
    final isGuest = await authLocalDataSource.isGuestMode();
    
    // For now, consider subscribed if user has token and is not guest
    // In production, you'd check actual subscription status from API
    setState(() {
      _isSubscribed = token != null && token.isNotEmpty && !isGuest;
    });
  }

  void _checkPaywall(int index) {
    // If already subscribed or no limit set, don't show paywall
    if (_isSubscribed || widget.freeReelsLimit <= 0) {
      return;
    }
    
    // Show paywall after reaching the limit
    if (index >= widget.freeReelsLimit && !_showPaywall) {
      setState(() {
        _showPaywall = true;
      });
    }
  }

  void _handleSubscribe() async {
    // Pause videos before navigating
    setState(() => _isPageVisible = false);
    
    // Wait for the frame to rebuild and pause the video
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!mounted) return;
    
    final authLocalDataSource = sl<AuthLocalDataSource>();
    final token = await authLocalDataSource.getAccessToken();
    final isGuest = await authLocalDataSource.isGuestMode();
    
    final isAuthenticated = token != null && token.isNotEmpty && !isGuest;
    
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
          BlocBuilder<ReelsBloc, ReelsState>(
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
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white54,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: TextStyle(
                          fontFamily: cairoFontFamily,
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ReelsBloc>().add(const LoadReelsFeedEvent());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
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
                      const Icon(
                        Icons.video_library_outlined,
                        color: Colors.white54,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد فيديوهات حالياً',
                        style: TextStyle(
                          fontFamily: cairoFontFamily,
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is ReelsLoaded) {
                return _buildReelsFeed(context, state);
              }

              return const SizedBox.shrink();
            },
          ),
          
          // Paywall overlay
          if (_showPaywall)
            Positioned.fill(
              child: ReelPaywallWidget(
                onSubscribe: _handleSubscribe,
              ),
            ),
          
          // Top bar with back button and category filters
          if (!_showPaywall)
            Positioned(
              top: topPadding + 12,
              left: 0,
              right: 0,
              child: Row(
                children: [
                  // Back button (only show if enabled)
                  if (widget.showBackButton)
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  // Category filters
                  Expanded(child: _buildCategoryFilters()),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedCategoryIndex;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategoryIndex = index);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6A4BC3)
                    : const Color(0xFF2C2C36),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  _categories[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
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
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      allowImplicitScrolling: true,
      itemCount: state.reels.length + (state.hasMore ? 1 : 0),
      onPageChanged: (index) {
        setState(() => _currentIndex = index);
        
        // Check if paywall should be shown
        _checkPaywall(index);

        if (index >= state.reels.length - 3 && state.hasMore && !state.isLoadingMore) {
          context.read<ReelsBloc>().add(const LoadMoreReelsEvent());
        }
      },
      itemBuilder: (context, index) {
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
          isActive: index == _currentIndex && widget.isTabActive && _isPageVisible,
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'مشاركة الفيديو',
          style: TextStyle(fontFamily: cairoFontFamily),
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _handleRedirect(Reel reel) {
    if (reel.redirectType == 'course' && reel.redirectLink.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'الذهاب إلى الكورس: ${reel.redirectLink}',
            style: TextStyle(fontFamily: cairoFontFamily),
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
