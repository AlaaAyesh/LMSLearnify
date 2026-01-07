import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import '../../domain/entities/reel.dart';

class ReelPlayerWidget extends StatefulWidget {
  final Reel reel;
  final bool isLiked;
  final int viewCount;
  final int likeCount;
  final bool isActive;

  final VoidCallback onLike;
  final VoidCallback onShare;
  final VoidCallback onRedirect;
  final VoidCallback onViewed;

  const ReelPlayerWidget({
    super.key,
    required this.reel,
    required this.isLiked,
    required this.viewCount,
    required this.likeCount,
    required this.isActive,
    required this.onLike,
    required this.onShare,
    required this.onRedirect,
    required this.onViewed,
  });

  @override
  State<ReelPlayerWidget> createState() => _ReelPlayerWidgetState();
}

class _ReelPlayerWidgetState extends State<ReelPlayerWidget> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _showThumbnail = true;
  bool _isInitialized = false;
  bool _isPaused = false;
  bool _showLikeHeart = false;

  // View tracking
  Timer? _viewTimer;
  bool _hasRecordedView = false;
  static const _viewDuration = Duration(seconds: 3);

  // Double tap detection
  DateTime? _lastTapTime;
  static const _doubleTapDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    if (widget.isActive && widget.reel.bunnyUrl.isNotEmpty) {
      _initializePlayer();
      _startViewTimer();
    }
  }

  @override
  void didUpdateWidget(ReelPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        if (!_isInitialized && widget.reel.bunnyUrl.isNotEmpty) {
          _initializePlayer();
        } else if (_controller != null && _isPaused) {
          _playVideo();
        }
        _startViewTimer();
      } else {
        _pauseVideo();
        _cancelViewTimer();
      }
    }
  }

  @override
  void dispose() {
    _cancelViewTimer();
    _controller = null;
    super.dispose();
  }

  void _startViewTimer() {
    if (_hasRecordedView) return;
    _cancelViewTimer();

    _viewTimer = Timer(_viewDuration, () {
      if (mounted && widget.isActive && !_hasRecordedView) {
        _hasRecordedView = true;
        widget.onViewed();
      }
    });
  }

  void _cancelViewTimer() {
    _viewTimer?.cancel();
    _viewTimer = null;
  }

  void _initializePlayer() {
    if (_isInitialized) return;
    _isInitialized = true;

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
      width: 100%; 
      height: 100%; 
      background: #000;
      overflow: hidden;
    }
    .video-container {
      position: relative;
      width: 100%;
      height: 100%;
      overflow: hidden;
    }
    iframe {
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      width: 100%;
      height: calc(100% + 100px);
      border: 0;
      object-fit: cover;
      margin-bottom: -50px;
    }
    .controls-cover {
      position: absolute;
      bottom: 0;
      left: 0;
      right: 0;
      height: 60px;
      background: #000;
      z-index: 9999;
    }
  </style>
</head>
<body>
  <div class="video-container">
    <iframe 
      id="bunny-player"
      src="$embedUrl"
      loading="eager"
      allow="accelerometer; gyroscope; autoplay; encrypted-media; picture-in-picture; fullscreen"
      allowfullscreen="true"
      playsinline
      webkit-playsinline>
    </iframe>
    <div class="controls-cover"></div>
  </div>
</body>
</html>
''';

    late final PlatformWebViewControllerCreationParams params;
    if (Platform.isAndroid) {
      params = AndroidWebViewControllerCreationParams();
    } else if (Platform.isIOS) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            if (mounted) {
              setState(() => _isLoading = false);
              Future.delayed(const Duration(milliseconds: 800), () {
                if (mounted) {
                  setState(() => _showThumbnail = false);
                }
              });
            }
          },
        ),
      );

    if (Platform.isAndroid && _controller!.platform is AndroidWebViewController) {
      final androidController = _controller!.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
    }

    _controller!.loadHtmlString(html);

    if (mounted) setState(() {});
  }

  String _getEmbedUrl(String url) {
    String embedUrl = url.replaceFirst('/play/', '/embed/');

    final params = [
      'autoplay=true',
      'loop=true',
      'muted=false',
      'preload=true',
      'responsive=true',
      'controls=false',
      't=0',
    ].join('&');

    if (!embedUrl.contains('?')) {
      embedUrl = '$embedUrl?$params';
    } else {
      embedUrl = '$embedUrl&$params';
    }
    return embedUrl;
  }

  void _playVideo() {
    if (_controller == null) return;
    setState(() => _isPaused = false);

    final playUrl = _getEmbedUrl(widget.reel.bunnyUrl);
    _controller!.runJavaScript('''
      var iframe = document.getElementById('bunny-player');
      if (iframe) {
        iframe.src = "$playUrl";
      }
    ''');
  }

  void _pauseVideo() {
    if (_controller == null) return;
    setState(() => _isPaused = true);

    _controller!.runJavaScript('''
      var iframe = document.getElementById('bunny-player');
      if (iframe) {
        iframe.src = "about:blank";
      }
    ''');
  }

  void _togglePlayPause() {
    if (_controller == null) return;

    if (_isPaused) {
      _playVideo();
    } else {
      _pauseVideo();
    }
  }

  void _handleTap() {
    final now = DateTime.now();

    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < _doubleTapDuration) {
      _lastTapTime = null;
      widget.onLike();
      _showLikeAnimation();
    } else {
      _lastTapTime = now;
      _togglePlayPause();
    }
  }

  void _showLikeAnimation() {
    setState(() => _showLikeHeart = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _showLikeHeart = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // VIDEO PLAYER or THUMBNAIL
          AbsorbPointer(
            child: widget.reel.bunnyUrl.isNotEmpty && _controller != null && !_showThumbnail
                ? WebViewWidget(controller: _controller!)
                : _buildThumbnail(),
          ),

          // Pause icon overlay
          if (_isPaused)
            IgnorePointer(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),

          // Like heart animation
          if (_showLikeHeart)
            const IgnorePointer(
              child: Center(
                child: Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 100,
                ),
              ),
            ),

          // Loading indicator
          if (_isLoading && widget.reel.bunnyUrl.isNotEmpty && widget.isActive)
            const IgnorePointer(
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFFC107),
                  strokeWidth: 2,
                ),
              ),
            ),

          // Bottom Gradient
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 250,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0xFF1A1A1A),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // BOTTOM CONTENT
          Positioned(
            left: 16,
            right: 16,
            bottom: bottomPadding + 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // LEFT - Profile Info + Subscribe Button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IgnorePointer(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildAvatar(),
                          const SizedBox(width: 8),
                          Text(
                            widget.reel.owner.name.isNotEmpty
                                ? widget.reel.owner.name
                                : 'ليرنفاي',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    IgnorePointer(
                      child: Text(
                        widget.reel.description.isNotEmpty
                            ? widget.reel.description
                            : 'تعلم كيفية نطق الحروف',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: widget.onRedirect,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'اشترك من هنا',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // RIGHT - Actions
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: widget.onLike,
                      child: Icon(
                        Icons.favorite,
                        color: widget.isLiked ? Colors.red : Colors.white,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 4),
                    IgnorePointer(
                      child: Text(
                        _formatCount(widget.likeCount),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: widget.onShare,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(3.14159),
                        child: const Icon(
                          Icons.reply,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const IgnorePointer(
                      child: Text(
                        'مشاركة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    if (widget.reel.thumbnailUrl.isEmpty) {
      return Container(
        color: const Color(0xFF1A1A1A),
        child: const Center(
          child: Icon(
            Icons.play_circle_outline,
            color: Colors.white24,
            size: 80,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: widget.reel.thumbnailUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: const Color(0xFF1A1A1A),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFFC107),
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: const Color(0xFF1A1A1A),
        child: const Center(
          child: Icon(
            Icons.play_circle_outline,
            color: Colors.white24,
            size: 80,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final defaultAvatar = Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(6),
      child: Image.asset(
        'assets/images/app_logo.png',
        fit: BoxFit.contain,
      ),
    );

    if (widget.reel.owner.avatarUrl.isEmpty) {
      return defaultAvatar;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: widget.reel.owner.avatarUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          placeholder: (context, url) => defaultAvatar,
          errorWidget: (context, url, error) => defaultAvatar,
        ),
      ),
    );
  }

  String _formatCount(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toString();
  }
}
