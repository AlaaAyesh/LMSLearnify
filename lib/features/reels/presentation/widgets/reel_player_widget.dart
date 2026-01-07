import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/reel.dart';

class ReelPlayerWidget extends StatefulWidget {
  final Reel reel;
  final bool isLiked;
  final int? viewCount;  // Updated view count from state
  final int? likeCount;  // Updated like count from state
  final bool isActive;
  final VoidCallback onLike;
  final VoidCallback onShare;
  final VoidCallback onRedirect;
  final VoidCallback? onViewed;

  const ReelPlayerWidget({
    super.key,
    required this.reel,
    required this.isLiked,
    this.viewCount,
    this.likeCount,
    required this.isActive,
    required this.onLike,
    required this.onShare,
    required this.onRedirect,
    this.onViewed,
  });

  @override
  State<ReelPlayerWidget> createState() => _ReelPlayerWidgetState();
}

class _ReelPlayerWidgetState extends State<ReelPlayerWidget>
    with AutomaticKeepAliveClientMixin {
  WebViewController? _videoController;
  bool _isVideoLoading = true;
  bool _showThumbnail = true;
  bool _isDisposed = false;
  bool _isInitialized = false;
  
  // View tracking
  Timer? _viewTimer;
  bool _hasRecordedView = false;
  static const _viewDuration = Duration(seconds: 3);
  
  // Delay video initialization for smoother scrolling
  Timer? _initDelayTimer;
  static const _initDelay = Duration(milliseconds: 300);

  // Local state for counts (updates in real-time)
  late int _currentViewCount;
  late int _currentLikeCount;
  
  @override
  bool get wantKeepAlive => widget.isActive;

  @override
  void initState() {
    super.initState();
    
    // Initialize counts from widget props
    _currentViewCount = widget.viewCount ?? widget.reel.viewsCount;
    _currentLikeCount = widget.likeCount ?? widget.reel.likesCount;
    
    // Start view timer if this reel is active
    if (widget.isActive) {
      _startViewTimer();
      // Delay video init to not block UI during scroll
      _scheduleVideoInit();
    }
  }

  @override
  void didUpdateWidget(ReelPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update counts when they change from parent - avoid setState if values are same
    final newViewCount = widget.viewCount ?? widget.reel.viewsCount;
    final newLikeCount = widget.likeCount ?? widget.reel.likesCount;
    
    if (_currentViewCount != newViewCount || _currentLikeCount != newLikeCount) {
      _currentViewCount = newViewCount;
      _currentLikeCount = newLikeCount;
      // Only rebuild if mounted
      if (mounted) setState(() {});
    }
    
    // Handle isActive state changes
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startViewTimer();
        // Schedule video init with delay
        if (!_isInitialized && widget.reel.bunnyUrl.isNotEmpty) {
          _scheduleVideoInit();
        }
      } else {
        _cancelViewTimer();
        _initDelayTimer?.cancel();
      }
    }
  }
  
  void _scheduleVideoInit() {
    _initDelayTimer?.cancel();
    if (widget.reel.bunnyUrl.isEmpty || _isInitialized || _isDisposed) return;
    
    _initDelayTimer = Timer(_initDelay, () {
      if (mounted && widget.isActive && !_isInitialized) {
        _initializeVideoPlayer();
      }
    });
  }

  /// Get formatted like count
  String get _formattedLikes {
    if (_currentLikeCount >= 1000000) {
      return '${(_currentLikeCount / 1000000).toStringAsFixed(1)}M';
    } else if (_currentLikeCount >= 1000) {
      return '${(_currentLikeCount / 1000).toStringAsFixed(1)}K';
    }
    return '$_currentLikeCount';
  }

  /// Get formatted view count
  String get _formattedViews {
    if (_currentViewCount >= 1000000) {
      return '${(_currentViewCount / 1000000).toStringAsFixed(1)}M';
    } else if (_currentViewCount >= 1000) {
      return '${(_currentViewCount / 1000).toStringAsFixed(1)}K';
    }
    return '$_currentViewCount';
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cancelViewTimer();
    _initDelayTimer?.cancel();
    _videoController = null;
    super.dispose();
  }

  void _startViewTimer() {
    // Don't start timer if already recorded view
    if (_hasRecordedView) {
      debugPrint('ReelPlayer: View already recorded for reel ${widget.reel.id}, not starting timer');
      return;
    }
    
    _cancelViewTimer();
    debugPrint('ReelPlayer: Starting 3-second view timer for reel ${widget.reel.id}');
    _viewTimer = Timer(_viewDuration, () {
      debugPrint('ReelPlayer: View timer completed for reel ${widget.reel.id}');
      if (mounted && !_isDisposed && widget.isActive && !_hasRecordedView) {
        debugPrint('ReelPlayer: Recording view for reel ${widget.reel.id}');
        _hasRecordedView = true;
        widget.onViewed?.call();
      } else {
        debugPrint('ReelPlayer: View not recorded - mounted: $mounted, disposed: $_isDisposed, active: ${widget.isActive}, alreadyRecorded: $_hasRecordedView');
      }
    });
  }

  void _cancelViewTimer() {
    _viewTimer?.cancel();
    _viewTimer = null;
  }

  void _initializeVideoPlayer() {
    if (_isDisposed || _isInitialized) return;
    _isInitialized = true;
    
    try {
      final embedUrl = _getEmbedUrl(widget.reel.bunnyUrl);

      final html = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { 
      width: 100vw; 
      height: 100vh; 
      background: #000;
      overflow: hidden;
    }
    .video-wrapper {
      position: relative;
      width: 100vw;
      height: 100vh;
    }
    iframe {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      border: 0;
    }
  </style>
</head>
<body>
  <div class="video-wrapper">
    <iframe 
      src="$embedUrl"
      loading="lazy"
      style="border:0;position:absolute;top:0;left:0;height:100%;width:100%;"
      allow="accelerometer;gyroscope;autoplay;encrypted-media;picture-in-picture;"
      allowfullscreen="true">
    </iframe>
  </div>
</body>
</html>
''';

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (url) {
              if (mounted && !_isDisposed) {
                setState(() {
                  _isVideoLoading = false;
                  _showThumbnail = false;
                });
              }
            },
            onWebResourceError: (error) {
              // Handle web resource errors silently
              debugPrint('WebView error: ${error.description}');
            },
          ),
        );
      
      if (!_isDisposed && mounted) {
        controller.loadHtmlString(html);
        _videoController = controller;
      }
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  String _getEmbedUrl(String url) {
    String embedUrl = url.replaceFirst('/play/', '/embed/');
    if (!embedUrl.contains('?')) {
      embedUrl = '$embedUrl?autoplay=true&responsive=true&loop=true';
    } else {
      embedUrl = '$embedUrl&autoplay=true&responsive=true&loop=true';
    }
    return embedUrl;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Player or Thumbnail
        if (widget.reel.bunnyUrl.isNotEmpty && _videoController != null && !_showThumbnail)
          WebViewWidget(controller: _videoController!)
        else
          _buildThumbnail(),

        // Loading indicator
        if (_isVideoLoading && widget.reel.bunnyUrl.isNotEmpty)
          const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),

        // Gradient overlay at bottom - wrapped in RepaintBoundary for performance
        const Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 350,
          child: IgnorePointer(
            child: RepaintBoundary(
              child: _BottomGradient(),
            ),
          ),
        ),

        // Gradient overlay at top - wrapped in RepaintBoundary for performance
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 150,
          child: IgnorePointer(
            child: RepaintBoundary(
              child: _TopGradient(),
            ),
          ),
        ),

        // Right Side Actions
        Positioned(
          right: 16,
          bottom: 180,
          child: _buildSideActions(),
        ),

        // Bottom Content Info
        Positioned(
          left: 16,
          right: 80,
          bottom: 100,
          child: _buildContentInfo(),
        ),

        // CTA Button
        if (widget.reel.redirectType.isNotEmpty)
          Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: _buildCTAButton(),
          ),
      ],
    );
  }

  Widget _buildThumbnail() {
    if (widget.reel.thumbnailUrl.isEmpty) {
      return const ColoredBox(
        color: AppColors.primaryOpacity30,
        child: Center(
          child: Icon(
            Icons.play_circle_outline,
            color: Colors.white,
            size: 80,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: widget.reel.thumbnailUrl,
      fit: BoxFit.cover,
      memCacheWidth: 720, // Limit memory cache size for better performance
      placeholder: (context, url) => const ColoredBox(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      ),
      errorWidget: (context, url, error) => const ColoredBox(
        color: AppColors.primaryOpacity30,
        child: Center(
          child: Icon(
            Icons.play_circle_outline,
            color: Colors.white,
            size: 80,
          ),
        ),
      ),
    );
  }

  Widget _buildSideActions() {
    return Column(
      children: [
        // Owner Avatar
        _buildOwnerAvatar(),
        const SizedBox(height: 24),

        // Like Button
        _buildActionButton(
          icon: Icons.favorite,
          label: _formattedLikes,
          isActive: widget.isLiked,
          activeColor: Colors.red,
          onTap: widget.onLike,
        ),
        const SizedBox(height: 20),

        // Views
        _buildActionButton(
          icon: Icons.visibility,
          label: _formattedViews,
          onTap: () {},
        ),
        const SizedBox(height: 20),

        // Share Button
        _buildActionButton(
          icon: Icons.share,
          label: 'مشاركة',
          onTap: widget.onShare,
        ),
      ],
    );
  }

  Widget _buildOwnerAvatar() {
    return GestureDetector(
      onTap: () {
        // Navigate to owner profile
      },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              border: Border.fromBorderSide(
                BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            child: ClipOval(
              child: widget.reel.owner.avatarUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: widget.reel.owner.avatarUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: 100, // Small avatar, limit memory
                      placeholder: (context, url) => const ColoredBox(
                        color: AppColors.primaryOpacity30,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => const ColoredBox(
                        color: AppColors.primaryOpacity30,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    )
                  : ColoredBox(
                      color: AppColors.primaryOpacity30,
                      child: Center(
                        child: Text(
                          widget.reel.owner.name.isNotEmpty
                              ? widget.reel.owner.name[0].toUpperCase()
                              : 'L',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    Color activeColor = Colors.white,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.whiteOpacity15,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? activeColor : Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: cairoFontFamily,
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Owner Name
        Row(
          children: [
            Text(
              '@${widget.reel.owner.name}',
              style: TextStyle(
                fontFamily: cairoFontFamily,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            if (widget.reel.owner.name.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'متابعة',
                  style: TextStyle(
                    fontFamily: cairoFontFamily,
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Title
        Text(
          widget.reel.title,
          style: TextStyle(
            fontFamily: cairoFontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),

        // Description
        if (widget.reel.description.isNotEmpty)
          Text(
            widget.reel.description,
            style: TextStyle(
              fontFamily: cairoFontFamily,
              fontSize: 13,
              color: AppColors.whiteOpacity80,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

        const SizedBox(height: 8),

        // Created at
        Row(
          children: [
            const Icon(
              Icons.access_time,
              color: AppColors.whiteOpacity60,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              widget.reel.createdAt,
              style: TextStyle(
                fontFamily: cairoFontFamily,
                fontSize: 12,
                color: AppColors.whiteOpacity60,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCTAButton() {
    String buttonText = 'اشترك الآن';
    IconData buttonIcon = Icons.school;

    if (widget.reel.redirectType == 'course') {
      buttonText = 'شاهد الكورس';
      buttonIcon = Icons.play_circle_filled;
    }

    return ElevatedButton(
      onPressed: widget.onRedirect,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 8,
        shadowColor: AppColors.primaryOpacity50,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            buttonIcon,
            color: Colors.white,
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            buttonText,
            style: TextStyle(
              fontFamily: cairoFontFamily,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// Extracted gradient widgets for const optimization and RepaintBoundary
class _BottomGradient extends StatelessWidget {
  const _BottomGradient();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppColors.blackOpacity90,
            AppColors.blackOpacity60,
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _TopGradient extends StatelessWidget {
  const _TopGradient();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.blackOpacity60,
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}




