import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_background.dart';
import '../../../../core/routing/app_router.dart';
import '../../../authentication/data/datasources/auth_local_datasource.dart';
import '../../../home/presentation/pages/main_navigation_page.dart';
import '../../domain/entities/reel.dart';
import '../../domain/entities/reel_owner.dart';
import '../../data/models/reel_category_model.dart';
import '../bloc/reels_bloc.dart';
import '../bloc/reels_event.dart';
import '../bloc/reels_state.dart';
import '../widgets/reel_paywall_widget.dart';
import '../widgets/reel_player_widget.dart';
import 'collected_reels_page.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class ReelsFeedPage extends StatefulWidget {
  final int initialIndex;
  final bool showBackButton;
  final int
      freeReelsLimit;
  final bool isTabActive;
  final bool hideCategoryFilters;
  final Reel? initialReel;

  const ReelsFeedPage({
    super.key,
    this.initialIndex = 0,
    this.showBackButton = true,
    this.freeReelsLimit = 5,
    this.isTabActive = false,
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
  int _selectedCategoryIndex = -1;
  bool _showPaywall = false;
  bool _isSubscribed = false;
  bool _isPageVisible =
      true;
  bool _isCheckingAuth = true;
  bool _isAuthenticated = false;

  List<ReelCategoryModel> _categories = [];
  bool _isFiltering = false;
  int? _lastFilteredCategoryId;
  int? _activeCategoryId;
  int _pageViewResetToken = 0;

  Timer? _filterDebounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentIndex = widget.initialReel != null ? 0 : widget.initialIndex;
    _pageController = PageController(
      initialPage: widget.initialReel != null ? 0 : widget.initialIndex,
    );
    _checkAuthentication();
    _checkSubscriptionStatus();

    if (widget.initialReel != null) {
      context.read<ReelsBloc>().add(SeedSingleReelEvent(reel: widget.initialReel!));
    } else if (!widget.hideCategoryFilters) {
      context.read<ReelsBloc>().add(const LoadReelCategoriesEvent());
    }

    if (widget.isTabActive) {
      _setDarkStatusBar();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      if (_isPageVisible) {
        setState(() => _isPageVisible = false);
      }
    } else if (state == AppLifecycleState.resumed) {
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
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  bool _shouldResetOnNextLoad = false;

  @override
  void didUpdateWidget(ReelsFeedPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isTabActive != oldWidget.isTabActive) {
      if (widget.isTabActive) {
        _setDarkStatusBar();
        if (widget.initialReel == null &&
            !widget.hideCategoryFilters &&
            mounted) {
          _shouldResetOnNextLoad = true;
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            try {
              final bloc = context.read<ReelsBloc>();
              final currentState = bloc.state;
              if (currentState is ReelsWithCategories) {
                setState(() {
                  _categories = currentState.categories
                      .where((c) => c.isActive)
                      .toList()
                      .reversed
                      .toList();

                  if (_categories.isNotEmpty) {
                    _selectedCategoryIndex = -1;
                    _activeCategoryId = null;
                    _lastFilteredCategoryId = null;
                    _pageViewResetToken++;

                    bloc.add(
                      const LoadReelsFeedEvent(
                        perPage: 5,
                        categoryId: null,
                      ),
                    );
                  }
                });
              } else if (currentState is ReelsLoaded && currentState.categories.isNotEmpty) {
                setState(() {
                  _categories = currentState.categories
                      .where((c) => c.isActive)
                      .toList()
                      .reversed
                      .toList();
                  
                  if (_categories.isNotEmpty) {
                    _selectedCategoryIndex = -1;
                    _activeCategoryId = null;
                    _lastFilteredCategoryId = null;
                    _pageViewResetToken++;

                    bloc.add(
                      const LoadReelsFeedEvent(
                        perPage: 5,
                        categoryId: null,
                      ),
                    );
                  }
                });
              } else if (_categories.isEmpty) {
                bloc.add(const LoadReelCategoriesEvent());
              }
            } catch (e) {
              debugPrint('ReelsFeedPage: Could not restore/load categories: $e');
            }
          });
        }
      } else {
        _setLightStatusBar();
      }
      setState(() {});
    }
  }

  @override
  void didPush() {
    setState(() => _isPageVisible = true);
  }

  @override
  void didPopNext() {
    setState(() {
      _isPageVisible = true;
      if (widget.isTabActive) {
        _setDarkStatusBar();
      }
    });
  }

  @override
  void didPushNext() {
    setState(() => _isPageVisible = false);
  }

  @override
  void didPop() {
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

  Future<void> _checkAuthentication() async {
    final authLocalDataSource = sl<AuthLocalDataSource>();
    final token = await authLocalDataSource.getAccessToken();
    setState(() {
      _isAuthenticated = token != null && token.isNotEmpty;
      _isCheckingAuth = false;
    });
  }

  Future<void> _checkSubscriptionStatus() async {
    final authLocalDataSource = sl<AuthLocalDataSource>();
    final token = await authLocalDataSource.getAccessToken();

    setState(() {
      _isSubscribed = token != null && token.isNotEmpty;
    });
  }

  void _checkPaywall(int index) {
  }

  void _handleSubscribe() async {
    setState(() => _isPageVisible = false);

    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    final authLocalDataSource = sl<AuthLocalDataSource>();
    final token = await authLocalDataSource.getAccessToken();

    final isAuthenticated = token != null && token.isNotEmpty;

    if (!isAuthenticated) {
      final result = await Navigator.pushNamed(
        context,
        '/login',
        arguments: {
          'returnTo': 'subscriptions',
        },
      );

      if (result == true && mounted) {
        await Navigator.pushNamed(context, '/subscriptions');
      }
    } else {
      await Navigator.pushNamed(context, '/subscriptions');
    }

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
    _setLightStatusBar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return const Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(title: 'شورتس'),
        body: Stack(
          children: [
            CustomBackground(),
            Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ],
        ),
      );
    }

    if (!_isAuthenticated) {
      return _UnauthenticatedReelsPage();
    }

    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          BlocConsumer<ReelsBloc, ReelsState>(
            listener: (context, state) {
              if (widget.hideCategoryFilters || widget.initialReel != null) {
                return;
              }

              if (state is ReelsWithCategories) {
                setState(() {
                  _categories = state.categories
                      .where((c) => c.isActive)
                      .toList()
                      .reversed
                      .toList();

                  if (_categories.isNotEmpty) {
                    _selectedCategoryIndex = -1;
                    _activeCategoryId = null;
                    _lastFilteredCategoryId = null;
                    _pageViewResetToken++;

                    context.read<ReelsBloc>().add(
                          const LoadReelsFeedEvent(
                            perPage: 10,
                            categoryId: null,
                          ),
                        );
                  }
                });
              }

              if (state is ReelsLoaded && state.categories.isNotEmpty && _categories.isEmpty) {
                setState(() {
                  _categories = state.categories
                      .where((c) => c.isActive)
                      .toList()
                      .reversed
                      .toList();
                  if (_categories.isNotEmpty) {
                    if (_selectedCategoryIndex < 0 || _selectedCategoryIndex >= _categories.length) {
                      _selectedCategoryIndex = -1;
                      _activeCategoryId = null;
                      _lastFilteredCategoryId = null;
                    } else {
                      _activeCategoryId = _categories[_selectedCategoryIndex].id;
                      _lastFilteredCategoryId ??= _activeCategoryId;
                    }
                  }
                });
              }

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

              if (state is ReelsLoaded && _isFiltering && state.reels.isNotEmpty) {
                final categoryId = _categories.isNotEmpty && 
                    _selectedCategoryIndex >= 0 && 
                    _selectedCategoryIndex < _categories.length
                    ? _categories[_selectedCategoryIndex].id
                    : null;

                if (categoryId != null && categoryId != _lastFilteredCategoryId) {
                  _lastFilteredCategoryId = categoryId;
                }
                
                _isFiltering = false;
                _pageViewResetToken++;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      if (_currentIndex >= state.reels.length) {
                        _currentIndex = 0;
                      }
                    });
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
              if (state is ReelsLoading && _categories.isEmpty) {
                return const Center(
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
                            onPressed: () {},
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
                if (state.categories.isNotEmpty && _categories.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _categories = state.categories
                            .where((c) => c.isActive)
                            .toList()
                            .reversed
                            .toList();
                        if (_categories.isNotEmpty) {
                          if (_selectedCategoryIndex < 0 || _selectedCategoryIndex >= _categories.length) {
                            _selectedCategoryIndex = -1;
                          }
                        }
                      });
                    }
                  });
                }
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

              if (state is ReelsWithCategories) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),

          if (!(_currentIndex == 0 && !_isSubscribed))
            Positioned(
              top: topPadding + Responsive.height(context, 12),
              left: 0,
              right: 0,
              child: Row(
                children: [
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

              if (isSelected) {
                setState(() {
                  _selectedCategoryIndex = -1;
                  _isFiltering = true;
                  _activeCategoryId = null;
                  _lastFilteredCategoryId = null;
                  _pageViewResetToken++;
                  _shouldResetOnNextLoad = false;
                  _currentIndex = 0;
                });

                if (_pageController.hasClients) {
                  _pageController.jumpToPage(0);
                }

                _filterDebounceTimer?.cancel();

                _filterDebounceTimer = Timer(const Duration(milliseconds: 250), () {
                  if (!mounted) return;
                  
                  try {
                    final bloc = context.read<ReelsBloc>();
                    bloc.add(
                      const LoadReelsFeedEvent(
                        perPage: 10,
                        categoryId: null,
                      ),
                    );
                  } catch (e) {
                    debugPrint('ReelsFeedPage: Could not load all reels: $e');
                    if (mounted) {
                      setState(() => _isFiltering = false);
                    }
                  }
                });
              } else {
                setState(() {
                  _selectedCategoryIndex = index;
                  _isFiltering = true;
                  _activeCategoryId = category.id;
                  _lastFilteredCategoryId = category.id;
                  _pageViewResetToken++;
                  _shouldResetOnNextLoad = false;
                  _currentIndex = 0;
                });

                if (_pageController.hasClients) {
                  _pageController.jumpToPage(0);
                }

                _filterDebounceTimer?.cancel();

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
              }
            },
            child: Container(
              padding: Responsive.padding(context, horizontal: 14, vertical: 6),
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
                        fontSize: Responsive.fontSize(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isSelected && _isFiltering) ...[
                      SizedBox(width: Responsive.width(context, 8)),
                      SizedBox(
                        width: Responsive.width(context, 12),
                        height: Responsive.height(context, 12),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
    final hasNextCategory = _getNextCategoryIndex() != null;
    final itemCount = state.reels.isEmpty && !_isSubscribed
        ? 1
        : state.reels.length +
            ((state.hasMore ||
                    state.isLoadingMore ||
                    (!state.hasMore && hasNextCategory))
                ? 1
                : 0);

    final categoryKey = _activeCategoryId ??
        (_categories.isNotEmpty && 
         _selectedCategoryIndex >= 0 && 
         _selectedCategoryIndex < _categories.length
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

        _checkPaywall(index);

        final thresholdIndex =
            state.reels.isNotEmpty ? state.reels.length - 1 : 0;
        final isAtPaginationThreshold =
            state.reels.isNotEmpty && index >= thresholdIndex;
        final isLoaderIndex = index >= state.reels.length;

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

        if ((isAtPaginationThreshold || isLoaderIndex) &&
            !state.hasMore &&
            !state.isLoadingMore) {
          _loadNextCategoryIfAvailable();
        }
      },
      itemBuilder: (context, index) {
        if (index == 0 && !_isSubscribed) {
          final thumbnailUrl =
              state.reels.isNotEmpty ? state.reels[0].thumbnailUrl : null;
          return ReelPaywallWidget(
            onSubscribe: _handleSubscribe,
            thumbnailUrl: thumbnailUrl,
          );
        }

        if (state.reels.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

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

        bool isCategoryAllowed = true;
        if (!widget.hideCategoryFilters &&
            widget.initialReel == null &&
            _categories.isNotEmpty &&
            _selectedCategoryIndex >= 0 &&
            _selectedCategoryIndex < _categories.length) {
          final selectedCategoryId = _categories[_selectedCategoryIndex].id;
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
          onLogoTap: () {
            if (widget.hideCategoryFilters || widget.initialReel != null) {
              Navigator.of(context).pop();
            } else {
              _navigateToUserProfile(context, reel.owner);
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

    if (_categories.length == 1) {
      return null;
    }

    final startIndex = _selectedCategoryIndex >= 0 ? _selectedCategoryIndex : -1;
    return (startIndex + 1) % _categories.length;
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
    final baseAppUrl = ApiConstants.baseUrl.replaceAll('/api/', '');
    final reelLink = '$baseAppUrl/reels/${reel.id}';

    Clipboard.setData(ClipboardData(text: reelLink));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم نسخ رابط الريل',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleRedirect(Reel reel) {
    if (reel.redirectType == 'course' && reel.redirectLink.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'الذهاب إلى الكورس: ${reel.redirectLink}',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  void _navigateToUserProfile(BuildContext context, ReelOwner owner) async {
    setState(() => _isPageVisible = false);

    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    final profilePage = CollectedReelsPage(
      userId: owner.id,
      userName: owner.name,
      userAvatarUrl: owner.avatarUrl,
    );

    final mainNav = context.mainNavigation;
    if (mainNav != null) {
      mainNav.setShowBottomNav(true);
      mainNav.pushPage(profilePage);
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => profilePage),
      );
    }

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

class _UnauthenticatedReelsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'شورتس', showBackButton: false),
      body: Stack(
        children: [
          const CustomBackground(),
          Center(
            child: Padding(
              padding: Responsive.padding(
                context,
                horizontal: 24,
                vertical: 16,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: Responsive.iconSize(context, 80),
                      color: AppColors.primary,
                    ),
                    SizedBox(height: Responsive.spacing(context, 24)),
                    Text(
                      'تسجيل الدخول مطلوب',
                      style: AppTextStyles.displayMedium.copyWith(
                        fontSize: Responsive.fontSize(context, 24),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Responsive.spacing(context, 12)),
                    Text(
                      'للوصول إلى الشورتس، يرجى تسجيل الدخول أو إنشاء حساب جديد',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontSize: Responsive.fontSize(context, 16),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Responsive.spacing(context, 28)),
                    SizedBox(
                      width: double.infinity,
                      height: Responsive.height(context, 56),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushNamed(
                              AppRouter.login,
                              arguments: {'returnTo': 'reels'},
                            );

                            if (result == true && context.mounted) {
                              Navigator.of(context, rootNavigator: true)
                                  .pushReplacementNamed(AppRouter.reelsFeed);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: Text(
                            'تسجيل الدخول',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: Responsive.fontSize(context, 18),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, 24)),
                    SizedBox(
                      width: double.infinity,
                      height: Responsive.height(context, 56),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: OutlinedButton(
                          onPressed: () async {
                            final result = await Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushNamed(
                              AppRouter.register,
                              arguments: {'returnTo': 'reels'},
                            );

                            if (result == true && context.mounted) {
                              Navigator.of(context, rootNavigator: true)
                                  .pushReplacementNamed(AppRouter.reelsFeed);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            side: const BorderSide(color: AppColors.primary),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: Text(
                            'إنشاء حساب جديد',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: Responsive.fontSize(context, 18),
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
