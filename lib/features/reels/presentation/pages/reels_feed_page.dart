import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../authentication/data/datasources/auth_local_datasource.dart';
import '../../../home/presentation/pages/main_navigation_page.dart';
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
  final bool hideCategoryFilters; // Used when opening a single reel
  final Reel? initialReel; // If provided, show only this reel

  const ReelsFeedPage({
    super.key,
    this.initialIndex = 0,
    this.showBackButton = true,
    this.freeReelsLimit = 5, // Default: show paywall after 5 reels
    this.isTabActive = false, // Default to false - only true when in Shorts tab
    this.hideCategoryFilters = false,
    this.initialReel,
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
  bool _isFiltering = false; // Track if filtering is in progress
  int? _lastFilteredCategoryId; // Track last filtered category ID for PageView key
  int? _activeCategoryId; // Track currently selected category
  int _pageViewResetToken = 0; // Force PageView rebuilds on category reloads
  
  // Debounce timer for category filtering
  Timer? _filterDebounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentIndex = widget.initialReel != null ? 0 : widget.initialIndex;
    _pageController = PageController(
      initialPage: widget.initialReel != null ? 0 : widget.initialIndex,
    );
    _checkSubscriptionStatus();

    if (widget.initialReel != null) {
      // Single reel mode: seed bloc with selected reel and skip category loading
      context.read<ReelsBloc>().add(SeedSingleReelEvent(reel: widget.initialReel!));
    } else if (!widget.hideCategoryFilters) {
      // Load categories from API first, then load reels for default category
      context.read<ReelsBloc>().add(const LoadReelCategoriesEvent());
    }

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

  // Track if we need to reset page when reels reload
  bool _shouldResetOnNextLoad = false;

  @override
  void didUpdateWidget(ReelsFeedPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle status bar and trigger rebuild when tab becomes active/inactive
    if (widget.isTabActive != oldWidget.isTabActive) {
      if (widget.isTabActive) {
        _setDarkStatusBar();
        // When tab becomes active, reset to initial state like first time
        if (widget.initialReel == null &&
            !widget.hideCategoryFilters &&
            mounted) {
          // Mark that we should reset when new reels load
          _shouldResetOnNextLoad = true;
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            try {
              final bloc = context.read<ReelsBloc>();
              // Check if bloc already has categories in its state
              final currentState = bloc.state;
              if (currentState is ReelsWithCategories) {
                // Restore categories and reset to default category
                setState(() {
                  _categories = currentState.categories
                      .where((c) => c.isActive)
                      .toList()
                      .reversed
                      .toList();
                  
                  // Reset to default category (General or first)
                  if (_categories.isNotEmpty) {
                    final generalCategory = _categories.firstWhere(
                      (c) =>
                          c.slug.toLowerCase() == 'general' ||
                          c.name.contains('عام'),
                      orElse: () => _categories[0],
                    );
                    _selectedCategoryIndex = _categories.indexOf(generalCategory);
                    if (_selectedCategoryIndex == -1) {
                      _selectedCategoryIndex = 0;
                    }
                    _activeCategoryId = generalCategory.id;
                    _lastFilteredCategoryId = generalCategory.id;
                    _pageViewResetToken++;
                    
                    // Reload reels for the default category with smaller page for faster first response
                    bloc.add(
                      LoadReelsFeedEvent(
                        perPage: 5,
                        categoryId: generalCategory.id,
                      ),
                    );
                  }
                });
              } else if (currentState is ReelsLoaded && currentState.categories.isNotEmpty) {
                // Restore categories from ReelsLoaded state and reset
                setState(() {
                  _categories = currentState.categories
                      .where((c) => c.isActive)
                      .toList()
                      .reversed
                      .toList();
                  
                  if (_categories.isNotEmpty) {
                    final generalCategory = _categories.firstWhere(
                      (c) =>
                          c.slug.toLowerCase() == 'general' ||
                          c.name.contains('عام'),
                      orElse: () => _categories[0],
                    );
                    _selectedCategoryIndex = _categories.indexOf(generalCategory);
                    if (_selectedCategoryIndex == -1) {
                      _selectedCategoryIndex = 0;
                    }
                    _activeCategoryId = generalCategory.id;
                    _lastFilteredCategoryId = generalCategory.id;
                    _pageViewResetToken++;
                    
                    // Reload reels for the default category with smaller page for faster first response
                    bloc.add(
                      LoadReelsFeedEvent(
                        perPage: 5,
                        categoryId: generalCategory.id,
                      ),
                    );
                  }
                });
              } else if (_categories.isEmpty) {
                // No categories loaded, load them
                bloc.add(const LoadReelCategoriesEvent());
              }
            } catch (e) {
              // Bloc might be closed, ignore the error
              debugPrint('ReelsFeedPage: Could not restore/load categories: $e');
            }
          });
        }
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
    _filterDebounceTimer?.cancel();
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
              if (widget.hideCategoryFilters || widget.initialReel != null) {
                return; // Don't override feed when showing a single reel
              }
              
              // Handle ReelsWithCategories state - initial category load
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
                    _activeCategoryId = generalCategory.id;
                    _lastFilteredCategoryId = generalCategory.id;
                    _pageViewResetToken++;

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
              
              // Restore categories from ReelsLoaded state if they exist
              if (state is ReelsLoaded && state.categories.isNotEmpty && _categories.isEmpty) {
                setState(() {
                  _categories = state.categories
                      .where((c) => c.isActive)
                      .toList()
                      .reversed
                      .toList();
                  // Reset selected index if out of bounds
                  if (_categories.isNotEmpty && _selectedCategoryIndex >= _categories.length) {
                    _selectedCategoryIndex = 0;
                  }
                  if (_categories.isNotEmpty) {
                    _activeCategoryId = _categories[_selectedCategoryIndex].id;
                    _lastFilteredCategoryId ??= _activeCategoryId;
                  }
                });
              }
              
              // Reset page controller when reels are loaded after tab reactivation
              // Only reset on fresh loads (not pagination) and only if flag is set
              if (state is ReelsLoaded && 
                  _shouldResetOnNextLoad && 
                  state.reels.isNotEmpty &&
                  !state.isLoadingMore &&
                  !_isFiltering) {
                _shouldResetOnNextLoad = false;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _pageController.hasClients) {
                    setState(() {
                      _currentIndex = 0;
                    });
                    _pageController.jumpToPage(0);
                  }
                });
              }
              
              // Reset filtering state and page controller when filtering completes
              if (state is ReelsLoaded && _isFiltering && state.reels.isNotEmpty) {
                final categoryId = _categories.isNotEmpty && _selectedCategoryIndex < _categories.length
                    ? _categories[_selectedCategoryIndex].id
                    : null;
                
                // Update last filtered category
                if (categoryId != null && categoryId != _lastFilteredCategoryId) {
                  _lastFilteredCategoryId = categoryId;
                }
                
                _isFiltering = false;
                _pageViewResetToken++;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      // Ensure current index is valid
                      if (_currentIndex >= state.reels.length) {
                        _currentIndex = 0;
                      }
                    });
                    // Reset to first video when filtering completes
                    if (_pageController.hasClients) {
                      if (_currentIndex != 0) {
                        _pageController.jumpToPage(0);
                      }
                    }
                  }
                });
              }

              if (state is ReelsEmpty && _isFiltering) {
                setState(() {
                  _isFiltering = false;
                  _pageViewResetToken++;
                  _currentIndex = 0;
                });
              }

              if (state is ReelsError && _isFiltering) {
                setState(() {
                  _isFiltering = false;
                });
              }
            },
            builder: (context, state) {
              // Show loading only on initial load (no categories yet)
              // The bloc now handles keeping existing reels during filtering
              if (state is ReelsLoading && _categories.isEmpty) {
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
                // Restore categories from state if available
                if (state.categories.isNotEmpty && _categories.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _categories = state.categories
                            .where((c) => c.isActive)
                            .toList()
                            .reversed
                            .toList();
                        if (_categories.isNotEmpty && _selectedCategoryIndex >= _categories.length) {
                          _selectedCategoryIndex = 0;
                        }
                      });
                    }
                  });
                }
                // If categories are still empty and we're not in single-reel mode, reload them
                else if (_categories.isEmpty &&
                    widget.initialReel == null &&
                    !widget.hideCategoryFilters &&
                    widget.isTabActive) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      try {
                        context.read<ReelsBloc>().add(const LoadReelCategoriesEvent());
                      } catch (e) {
                        debugPrint('ReelsFeedPage: Could not reload categories: $e');
                      }
                    }
                  });
                }
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
                  // Category filters (hidden in single-reel mode)
                  if (!widget.hideCategoryFilters && widget.initialReel == null)
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
              if (!mounted) return;
              
              setState(() {
                _selectedCategoryIndex = index;
                _isFiltering = true;
                _activeCategoryId = category.id;
                _lastFilteredCategoryId = category.id;
                _pageViewResetToken++;
                // Clear reset flag when user manually filters
                _shouldResetOnNextLoad = false;
                // Reset to first video when filtering
                _currentIndex = 0;
              });
              
              // Reset page controller to first item when filtering
              if (_pageController.hasClients) {
                _pageController.jumpToPage(0);
              }
              
              // Cancel previous debounce timer
              _filterDebounceTimer?.cancel();
              
              // Debounce the filter request to prevent rapid API calls
              _filterDebounceTimer = Timer(const Duration(milliseconds: 250), () {
                if (!mounted) return;
                
                try {
                  final bloc = context.read<ReelsBloc>();
                  bloc.add(
                    LoadReelsFeedEvent(
                      perPage: 10,
                      categoryId: category.id,
                    ),
                  );
                } catch (e) {
                  debugPrint('ReelsFeedPage: Could not filter by category: $e');
                  if (mounted) {
                    setState(() => _isFiltering = false);
                  }
                }
              });
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Responsive.fontSize(context, 13),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isSelected && _isFiltering) ...[
                      SizedBox(width: Responsive.width(context, 8)),
                      SizedBox(
                        width: Responsive.width(context, 12),
                        height: Responsive.height(context, 12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ],
                  ],
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
    final hasNextCategory = _getNextCategoryIndex() != null;
    final itemCount = state.reels.isEmpty && !_isSubscribed
        ? 1 // Show paywall even if no reels
        : state.reels.length +
            ((state.hasMore ||
                    state.isLoadingMore ||
                    (!state.hasMore && hasNextCategory))
                ? 1
                : 0);

    // Use category ID + reset token for key to force rebuilds on category reloads
    final categoryKey = _activeCategoryId ??
        (_categories.isNotEmpty && _selectedCategoryIndex < _categories.length
            ? _categories[_selectedCategoryIndex].id
            : null);
    final pageViewKey = ValueKey(
      'reels_feed_category_${categoryKey ?? "all"}_$_pageViewResetToken',
    );
    
    return PageView.builder(
      key: pageViewKey,
      controller: _pageController,
      scrollDirection: Axis.vertical,
      allowImplicitScrolling: true,
      itemCount: itemCount,
      onPageChanged: (index) {
        setState(() => _currentIndex = index);

        // Check if paywall should be shown
        _checkPaywall(index);

        final thresholdIndex =
            state.reels.isNotEmpty ? state.reels.length - 1 : 0;
        final isAtPaginationThreshold =
            state.reels.isNotEmpty && index >= thresholdIndex;
        final isLoaderIndex = index >= state.reels.length;

        // Load more from current category
        if (isAtPaginationThreshold &&
            state.hasMore &&
            !state.isLoadingMore) {
          try {
            context.read<ReelsBloc>().add(const LoadMoreReelsEvent());
          } catch (e) {
            debugPrint('ReelsFeedPage: Could not load more reels: $e');
          }
          return;
        }

        // Auto-load next category when the current one ends
        if ((isAtPaginationThreshold || isLoaderIndex) &&
            !state.hasMore &&
            !state.isLoadingMore) {
          _loadNextCategoryIfAvailable();
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

        // Determine if this reel belongs to the currently selected (visible) category.
        // In single-reel mode or when filters are hidden we always allow playback.
        bool isCategoryAllowed = true;
        if (!widget.hideCategoryFilters &&
            widget.initialReel == null &&
            _categories.isNotEmpty &&
            _selectedCategoryIndex < _categories.length) {
          final selectedCategoryId = _categories[_selectedCategoryIndex].id;
          // If reel has category data, require that it matches the selected category.
          if (reel.categories.isNotEmpty) {
            isCategoryAllowed =
                reel.categories.any((c) => c.id == selectedCategoryId);
          }
        }

        return ReelPlayerWidget(
          key: ValueKey('reel_${reel.id}'),
          reel: reel,
          isLiked: isLiked,
          viewCount: viewCount,
          likeCount: likeCount,
          // Video only plays when:
          // - it's the current page
          // - the Shorts/Reels tab is active
          // - this page is visible (not covered by another route)
          // - the reel belongs to the currently selected category (if filters are shown)
          isActive: index == _currentIndex &&
              widget.isTabActive &&
              _isPageVisible &&
              isCategoryAllowed,
          onLike: () {
            if (!mounted) return;
            try {
              context.read<ReelsBloc>().add(ToggleReelLikeEvent(reelId: reel.id));
            } catch (e) {
              debugPrint('ReelsFeedPage: Could not toggle like: $e');
            }
          },
          onShare: () => _shareReel(reel),
          onRedirect: () => _handleRedirect(reel),
          onViewed: () {
            if (!mounted) return;
            try {
              context.read<ReelsBloc>().add(MarkReelViewedEvent(reelId: reel.id));
            } catch (e) {
              debugPrint('ReelsFeedPage: Could not mark viewed: $e');
            }
          },
          // In "opened from profile/list" mode we want the logo to behave like back
          // (not open another page).
          onLogoTap: () {
            if (widget.hideCategoryFilters || widget.initialReel != null) {
              Navigator.of(context).pop();
            } else {
              _navigateToCollectedReels(context);
            }
          },
        );
      },
    );
  }

  int? _getNextCategoryIndex() {
    if (widget.hideCategoryFilters || widget.initialReel != null) {
      return null;
    }

    if (_categories.isEmpty) {
      return null;
    }

    // If only one category, don't loop to avoid endless reloads of same list
    if (_categories.length == 1) {
      return null;
    }

    // Cycle through categories: after last, go back to first
    return (_selectedCategoryIndex + 1) % _categories.length;
  }

  void _loadNextCategoryIfAvailable() {
    if (!mounted) return;
    final nextCategoryIndex = _getNextCategoryIndex();
    if (nextCategoryIndex == null) return;
    final nextCategory = _categories[nextCategoryIndex];
    setState(() => _selectedCategoryIndex = nextCategoryIndex);
    try {
      context
          .read<ReelsBloc>()
          .add(LoadNextCategoryReelsEvent(categoryId: nextCategory.id));
    } catch (e) {
      debugPrint('ReelsFeedPage: Could not load next category: $e');
    }
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

    final mainNav = context.mainNavigation;
    if (mainNav != null) {
      // Keep bottom nav visible by pushing inside the current tab navigator
      mainNav.setShowBottomNav(true);
      mainNav.pushPage(const CollectedReelsPage());
    } else {
      // Fallback: regular push (may hide bottom nav if above shell)
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CollectedReelsPage()),
      );
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
}
