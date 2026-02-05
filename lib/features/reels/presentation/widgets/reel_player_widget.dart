import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/reel.dart';
import '../../../home/presentation/pages/main_navigation_page.dart';

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
  final VoidCallback? onLogoTap;

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
    this.onLogoTap,
  });

  @override
  State<ReelPlayerWidget> createState() => _ReelPlayerWidgetState();
}

class _ReelPlayerWidgetState extends State<ReelPlayerWidget>
    with WidgetsBindingObserver {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _showThumbnail = true;
  bool _isInitialized = false;
  bool _isPaused = false;
  bool _showLikeHeart = false;
  bool _wasActiveBeforeBackground = false;
  TabIndexNotifier? _tabNotifier;
  Timer? _tabCheckTimer;

  Timer? _viewTimer;
  bool _hasRecordedView = false;
  static const _viewDuration = Duration(seconds: 3);

  DateTime? _lastTapTime;
  static const _doubleTapDuration = Duration(milliseconds: 300);

  bool get _isShortsTabActive {
    if (_tabNotifier != null) {
      return _tabNotifier!.value == 1;
    }
    return widget.isActive;
  }


  bool get _isOnPausePage {
    if (!mounted) return false;

    try {
      final route = ModalRoute.of(context);
      if (route == null) return false;

      final routeName = route.settings.name;
      if (routeName != null) {
        const pauseRoutes = [
          '/profile',
          '/subscriptions',
          '/certificates',
          '/courses',
          '/about'
        ];
        if (pauseRoutes.contains(routeName)) {
          return true;
        }
      }

      if (_isShortsTabActive) {
        final navigator = Navigator.of(context, rootNavigator: false);
        if (navigator.canPop()) {
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  bool get _shouldPlay {
    if (_isOnPausePage) return false;
    return widget.isActive && _isShortsTabActive;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _tabCheckTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _checkAndStopIfNeeded();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = TabIndexProvider.of(context);
    if (notifier != null && _tabNotifier != notifier) {
      _tabNotifier?.removeListener(_onTabChanged);
      _tabNotifier = notifier;
      _tabNotifier!.addListener(_onTabChanged);
    }

    if (_shouldPlay && widget.reel.bunnyUrl.isNotEmpty && !_isInitialized) {
      _initializePlayer();
      _startViewTimer();
    }
  }

  void _onTabChanged() {
    _checkAndStopIfNeeded();
  }

  void _checkAndStopIfNeeded() {
    if (!mounted) return;

    if (!_shouldPlay && !_isPaused && _controller != null) {
      _stopVideo();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _wasActiveBeforeBackground = _shouldPlay && !_isPaused;
      if (_controller != null && !_isPaused) {
        _stopVideo();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_wasActiveBeforeBackground && _shouldPlay && _isPaused) {
        _playVideo();
      }
    }
  }

  @override
  void didUpdateWidget(ReelPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final wasActive = oldWidget.isActive;
    final nowActive = widget.isActive;

    if (wasActive != nowActive || !_shouldPlay) {
      if (_shouldPlay) {
        if (!_isInitialized && widget.reel.bunnyUrl.isNotEmpty) {
          _initializePlayer();
        } else if (_controller != null && _isPaused) {
          _playVideo();
        }
        _startViewTimer();
      } else {
        _stopVideo();
        _cancelViewTimer();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabNotifier?.removeListener(_onTabChanged);
    _tabCheckTimer?.cancel();
    _cancelViewTimer();
    if (_controller != null) {
      _controller!.runJavaScript('''
        var iframe = document.getElementById('bunny-player');
        if (iframe) { iframe.src = "about:blank"; }
      ''');
    }
    _controller = null;
    super.dispose();
  }

  void _startViewTimer() {
    if (_hasRecordedView) return;
    _cancelViewTimer();

    _viewTimer = Timer(_viewDuration, () {
      if (mounted && _shouldPlay && !_hasRecordedView) {
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

    if (Platform.isAndroid &&
        _controller!.platform is AndroidWebViewController) {
      final androidController =
          _controller!.platform as AndroidWebViewController;
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
    if (_controller == null || !_shouldPlay)
      return;
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

  void _stopVideo() {
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
      behavior: HitTestBehavior.deferToChild,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AbsorbPointer(
            child: widget.reel.bunnyUrl.isNotEmpty &&
                    _controller != null &&
                    !_showThumbnail
                ? WebViewWidget(controller: _controller!)
                : _buildThumbnail(context),
          ),

          if (_isPaused)
            IgnorePointer(
              child: Center(
                child: Container(
                  padding: Responsive.padding(context, all: 20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: Responsive.iconSize(context, 50),
                  ),
                ),
              ),
            ),

          if (_showLikeHeart)
            IgnorePointer(
              child: Center(
                child: Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: Responsive.iconSize(context, 100),
                ),
              ),
            ),

          if (_isLoading && widget.reel.bunnyUrl.isNotEmpty && _shouldPlay)
            IgnorePointer(
              child: Center(
                child: CircularProgressIndicator(
                  color: const Color(0xFFFFC107),
                  strokeWidth: Responsive.width(context, 2),
                ),
              ),
            ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: Responsive.height(context, 250),
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

          Positioned(
            left: Responsive.width(context, 16),
            right: Responsive.width(context, 16),
            bottom: bottomPadding + Responsive.height(context, 40),
            child: Builder(
              builder: (context) {
                final isTablet = Responsive.isTablet(context);

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: widget.onLogoTap,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildAvatar(context),
                              SizedBox(width: Responsive.width(context, 8)),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.reel.owner.name.isNotEmpty
                                        ? widget.reel.owner.name
                                        : 'ليرنفاي',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          Responsive.fontSize(context, 16),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                      height: Responsive.spacing(context, 6)),
                                  IgnorePointer(
                                    child: Text(
                                      widget.reel.description.isNotEmpty
                                          ? widget.reel.description
                                          : 'تعلم كيفية نطق الحروف',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize:
                                            Responsive.fontSize(context, 13),
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: Responsive.spacing(context, 14)),
                        GestureDetector(
                          onTap: widget.onRedirect,
                          child: Container(
                            padding: Responsive.padding(context,
                                horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFC107),
                              borderRadius: BorderRadius.circular(
                                  Responsive.radius(context, 16)),
                            ),
                            child: Text(
                              'اشترك من هنا',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: Responsive.fontSize(context, 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: widget.onLike,
                          child: Icon(
                            Icons.favorite,
                            color: widget.isLiked ? Colors.red : Colors.white,
                            size: Responsive.iconSize(context, 38),
                          ),
                        ),
                        SizedBox(height: Responsive.spacing(context, 4)),
                        IgnorePointer(
                          child: Text(
                            _formatCount(widget.likeCount),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Responsive.fontSize(context, 13),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: Responsive.spacing(context, isTablet?5:20)),
                        GestureDetector(
                          onTap: widget.onShare,
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(3.14159),
                            child: Icon(
                              Icons.reply,
                              color: Colors.white,
                              size: Responsive.iconSize(context, 32),
                            ),
                          ),
                        ),
                        SizedBox(height: Responsive.spacing(context, 4)),
                        IgnorePointer(
                          child: Text(
                            'مشاركة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Responsive.fontSize(context, 11),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    if (widget.reel.thumbnailUrl.isEmpty) {
      return Container(
        color: const Color(0xFF1A1A1A),
        child: Center(
          child: Icon(
            Icons.play_circle_outline,
            color: Colors.white24,
            size: Responsive.iconSize(context, 80),
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: widget.reel.thumbnailUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: const Color(0xFF1A1A1A),
        child: Center(
          child: CircularProgressIndicator(
            color: const Color(0xFFFFC107),
            strokeWidth: Responsive.width(context, 2),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: const Color(0xFF1A1A1A),
        child: Center(
          child: Icon(
            Icons.play_circle_outline,
            color: Colors.white24,
            size: Responsive.iconSize(context, 80),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final media = MediaQuery.of(context);
    final isPortrait = media.orientation == Orientation.portrait;
    final isTabletPortrait =
        isPortrait && media.size.shortestSide >= 600;
    final isTablet = Responsive.isTablet(context);

    final size = isTablet
        ? (isTabletPortrait
        ? Responsive.width(context, 36)
        : Responsive.width(context, 24))
        : Responsive.width(context, 36);

    Widget defaultAvatar() {
      return ClipOval(
        child: Container(
          width: size,
          height: size,
          color: Colors.white,
          child: Image.asset(
            'assets/images/app_logo.png',
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    if (widget.reel.owner.avatarUrl.isEmpty) {
      return defaultAvatar();
    }

    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: Colors.white,
        child: CachedNetworkImage(
          imageUrl: widget.reel.owner.avatarUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => defaultAvatar(),
          errorWidget: (context, url, error) => defaultAvatar(),
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
