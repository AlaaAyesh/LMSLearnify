import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:better_player/better_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/reel.dart';
import '../player/reel_constants.dart';
import '../player/reel_controller_pool.dart';

class ReelPlayerWidget extends StatefulWidget {
  final Reel reel;
  final bool isLiked;
  final int viewCount;
  final int likeCount;
  final bool isActive;
  final BetterPlayerController? controller;
  final bool enablePreload;
  final bool shouldPreload;
  final String? nextBunnyUrl;

  final VoidCallback onLike;
  final VoidCallback onShare;
  final VoidCallback onRedirect;
  final VoidCallback? onSubscribeClick;
  final VoidCallback onViewed;
  final VoidCallback? onLogoTap;

  const ReelPlayerWidget({
    super.key,
    required this.reel,
    required this.isLiked,
    required this.viewCount,
    required this.likeCount,
    required this.isActive,
    this.controller,
    this.enablePreload = true,
    this.shouldPreload = false,
    this.nextBunnyUrl,
    required this.onLike,
    required this.onShare,
    required this.onRedirect,
    this.onSubscribeClick,
    required this.onViewed,
    this.onLogoTap,
  });

  @override
  State<ReelPlayerWidget> createState() => _ReelPlayerWidgetState();
}

class _ReelPlayerWidgetState extends State<ReelPlayerWidget>
    with WidgetsBindingObserver {
  BetterPlayerController? _controller;
  WebViewController? _webController;
  bool _isLoading = true;
  bool _showThumbnailOverlay = true;
  bool _isWebInitialized = false;
  bool _isUserPaused = false;
  bool _webIsShowingPausedFrame = false;
  bool _isVisibleEnough = false;
  bool _showLikeHeart = false;
  bool _wasPlayingBeforeBackground = false;

  Timer? _viewTimer;
  bool _hasRecordedView = false;
  static const _viewDuration = Duration(seconds: 3);

  DateTime? _lastTapTime;
  static const _doubleTapDuration = Duration(milliseconds: 300);

  late final ValueNotifier<int> _progressSecondsNotifier;
  Timer? _progressTimer;

  bool get _shouldPlayNow => widget.isActive && _isVisibleEnough && !_isUserPaused;

  int get _durationSeconds =>
      widget.reel.durationSeconds > 0
          ? widget.reel.durationSeconds
          : ReelConstants.defaultDurationSeconds;

  @override
  void initState() {
    super.initState();
    _progressSecondsNotifier = ValueNotifier<int>(0);
    WidgetsBinding.instance.addObserver(this);
    _controller = widget.controller;
    final shouldInit = widget.reel.bunnyUrl.isNotEmpty &&
        (widget.isActive || widget.shouldPreload);
    if (_controller != null) {
      _setupCurrent();
    } else if (shouldInit && !_isDirectStreamUrl(widget.reel.bunnyUrl)) {
      _initializeWebPlayer();
    }
  }

  static bool _isDirectStreamUrl(String url) =>
      ReelControllerPool.isDirectStreamUrl(url);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _wasPlayingBeforeBackground = _shouldPlayNow;
      _pauseVideo();
    } else if (state == AppLifecycleState.resumed) {
      if (_wasPlayingBeforeBackground && _shouldPlayNow) {
        _playVideo();
      }
    }
  }

  @override
  void didUpdateWidget(ReelPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller = widget.controller;
      _isUserPaused = false;
      _hasRecordedView = false;
      if (_controller != null) {
        _setupCurrent();
      } else if (widget.reel.bunnyUrl.isNotEmpty && widget.isActive && !_isDirectStreamUrl(widget.reel.bunnyUrl)) {
        _initializeWebPlayer();
      }
    }
    if (oldWidget.reel.id != widget.reel.id ||
        oldWidget.reel.bunnyUrl != widget.reel.bunnyUrl) {
      _isUserPaused = false;
      _hasRecordedView = false;
      _progressSecondsNotifier.value = 0;
      _progressTimer?.cancel();
      if (_controller != null) {
        _setupCurrent();
      } else if (widget.reel.bunnyUrl.isNotEmpty && (widget.isActive || widget.shouldPreload) && !_isWebInitialized && !_isDirectStreamUrl(widget.reel.bunnyUrl)) {
        _initializeWebPlayer();
      }
    }

    final shouldInit = widget.reel.bunnyUrl.isNotEmpty &&
        (widget.isActive || widget.shouldPreload) &&
        !_isWebInitialized &&
        !_isDirectStreamUrl(widget.reel.bunnyUrl);
    if (shouldInit && _controller == null) {
      _initializeWebPlayer();
    }

    if (!widget.isActive) {
      _pauseVideo();
      _cancelViewTimer();
      _progressTimer?.cancel();
    } else {
      _syncPlaybackState();
    }
    _startOrStopProgressTimer();

    if (widget.enablePreload && widget.nextBunnyUrl != oldWidget.nextBunnyUrl) {
      _preloadNext();
    }
  }

  void _startOrStopProgressTimer() {
    _progressTimer?.cancel();
    final useNative = _controller != null;
    final useWeb = _webController != null;
    if (_shouldPlayNow && (useWeb || useNative)) {
      _progressTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        if (!_shouldPlayNow) return;
        final next = _progressSecondsNotifier.value >= _durationSeconds
            ? 0
            : _progressSecondsNotifier.value + 1;
        _progressSecondsNotifier.value = next;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelViewTimer();
    _progressTimer?.cancel();
    _progressSecondsNotifier.dispose();
    if (_webController != null) {
      _webController!.runJavaScript('''
        var iframe = document.getElementById('bunny-player');
        if (iframe) { iframe.src = "about:blank"; }
      ''');
      _webController = null;
    }
    super.dispose();
  }

  Future<void> _setupCurrent() async {
    if (_controller == null) return;
    if (widget.reel.bunnyUrl.isEmpty) return;

    setState(() => _isLoading = true);
    await reelControllerPool.setDataSource(
      _controller!,
      url: widget.reel.bunnyUrl,
      tryHlsFirst: true,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);
    if (widget.enablePreload) {
      unawaited(_preloadNext());
    }
    _syncPlaybackState();
  }

  String _getEmbedUrl(String url, {bool autoplay = true, int startSeconds = 0}) {
    String embedUrl = url.replaceFirst('/play/', '/embed/');
    final safeStart = startSeconds < 0 ? 0 : startSeconds;
    final params =
        'autoplay=$autoplay&loop=true&muted=false&preload=true&responsive=true&controls=false&t=$safeStart';
    if (!embedUrl.contains('?')) {
      embedUrl = '$embedUrl?$params';
    } else {
      embedUrl = '$embedUrl&$params';
    }
    return embedUrl;
  }

  void _initializeWebPlayer() {
    if (_isWebInitialized || widget.reel.bunnyUrl.isEmpty) return;
    _isWebInitialized = true;
    final autoplay = widget.isActive;
    _webIsShowingPausedFrame = !autoplay;
    final embedUrl = _getEmbedUrl(
      widget.reel.bunnyUrl,
      autoplay: autoplay,
      startSeconds: 0,
    );
    final html = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { width: 100%; height: 100%; background: #000; overflow: hidden; }
    .video-container { position: relative; width: 100%; height: 100%; overflow: hidden; }
    iframe {
      position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);
      width: 100%; height: calc(100% + 100px); border: 0; object-fit: cover; margin-bottom: -50px;
    }
    .controls-cover { position: absolute; bottom: 0; left: 0; right: 0; height: 60px; background: #000; z-index: 9999; }
  </style>
</head>
<body>
  <div class="video-container">
    <iframe id="bunny-player" src="$embedUrl" loading="eager"
      allow="accelerometer; gyroscope; autoplay; encrypted-media; picture-in-picture; fullscreen"
      allowfullscreen="true" playsinline webkit-playsinline>
    </iframe>
    <div class="controls-cover"></div>
  </div>
</body>
</html>
''';
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
              Future.delayed(const Duration(milliseconds: 800), () {
                if (mounted) setState(() => _showThumbnailOverlay = false);
              });
            }
          },
        ),
      );
    final platform = _webController!.platform;
    if (platform is AndroidWebViewController) {
      platform.setMediaPlaybackRequiresUserGesture(false);
    }
    _webController!.loadHtmlString(html);
    if (mounted) setState(() {});
  }

  void _playVideoWeb() {
    if (_webController == null) return;
    if (!_webIsShowingPausedFrame) return;

    var start = _progressSecondsNotifier.value < 0 ? 0 : _progressSecondsNotifier.value;
    if (_durationSeconds > 0 && start >= _durationSeconds) {
      start = (_durationSeconds - 1).clamp(0, _durationSeconds);
    }

    final playUrl = _getEmbedUrl(
      widget.reel.bunnyUrl,
      autoplay: true,
      startSeconds: start,
    );
    _webController!.runJavaScript('''
      var iframe = document.getElementById('bunny-player');
      if (iframe) { iframe.src = "$playUrl"; }
    ''');
    _webIsShowingPausedFrame = false;
  }

  void _pauseVideoWeb() {
    if (_webController == null) return;

    var start = _progressSecondsNotifier.value < 0 ? 0 : _progressSecondsNotifier.value;
    if (_durationSeconds > 0 && start >= _durationSeconds) {
      start = (_durationSeconds - 1).clamp(0, _durationSeconds);
    }

    final pausedUrl = _getEmbedUrl(
      widget.reel.bunnyUrl,
      autoplay: false,
      startSeconds: start,
    );

    _webController!.runJavaScript('''
      var iframe = document.getElementById('bunny-player');
      if (iframe) { iframe.src = "$pausedUrl"; }
    ''');
    _webIsShowingPausedFrame = true;
  }

  Future<void> _preloadNext() async {
    final nextUrl = widget.nextBunnyUrl;
    if (nextUrl == null || nextUrl.isEmpty) return;
    final nextController = reelControllerPool.controllerAt(2);

    await reelControllerPool.setDataSource(
      nextController,
      url: nextUrl,
      tryHlsFirst: true,
    );
    await reelControllerPool.warmUp(nextController);
  }

  void _startViewTimer() {
    if (_hasRecordedView) return;
    _cancelViewTimer();

    _viewTimer = Timer(_viewDuration, () {
      if (mounted && _shouldPlayNow && !_hasRecordedView) {
        _hasRecordedView = true;
        widget.onViewed();
      }
    });
  }

  void _cancelViewTimer() {
    _viewTimer?.cancel();
    _viewTimer = null;
  }

  void _playVideo() {
    if (!_shouldPlayNow) return;
    if (_controller != null) {
      _controller!.play();
      _startViewTimer();
    } else if (_webController != null) {
      _playVideoWeb();
      _startViewTimer();
    }
    _startOrStopProgressTimer();
  }

  void _pauseVideo() {
    if (_controller != null) {
      try {
        _controller!.pause();
      } catch (_) {}
    } else if (_webController != null) {
      _pauseVideoWeb();
    }
    _progressTimer?.cancel();
  }

  void _togglePlayPause() {
    _isUserPaused = !_isUserPaused;
    _syncPlaybackState();
  }

  void _syncPlaybackState() {
    if (!mounted) return;
    if (_shouldPlayNow) {
      _playVideo();
    } else {
      _pauseVideo();
      _cancelViewTimer();
    }
    setState(() {});
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

    final showPausedOverlay = _isUserPaused || (!_shouldPlayNow && widget.isActive);

    return VisibilityDetector(
      key: ValueKey('reel_visibility_${widget.reel.id}'),
      onVisibilityChanged: (info) {
        final nowVisible = info.visibleFraction > 0.6;
        if (nowVisible == _isVisibleEnough) return;
        _isVisibleEnough = nowVisible;
        _syncPlaybackState();
      },
      child: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_controller != null && widget.reel.bunnyUrl.isNotEmpty)
              BetterPlayer(controller: _controller!)
            else if (_webController != null && widget.reel.bunnyUrl.isNotEmpty && !_showThumbnailOverlay)
              AbsorbPointer(child: WebViewWidget(controller: _webController!))
            else
              _buildThumbnail(context),

            if (showPausedOverlay)
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

          if (_isLoading && widget.reel.bunnyUrl.isNotEmpty && widget.isActive)
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
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: Responsive.height(context, 2)),
                  ValueListenableBuilder<int>(
                    valueListenable: _progressSecondsNotifier,
                    builder: (context, seconds, _) {
                      final progress = _durationSeconds > 0
                          ? (seconds / _durationSeconds).clamp(0.0, 1.0)
                          : 0.0;
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return Row(
                            children: [
                              Container(
                                width: constraints.maxWidth * progress,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFC107),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  if (_isUserPaused && _durationSeconds > 0) ...[
                    SizedBox(height: Responsive.height(context, 6)),
                    ValueListenableBuilder<int>(
                      valueListenable: _progressSecondsNotifier,
                      builder: (context, seconds, _) {
                        return Padding(
                          padding: EdgeInsets.only(
                            top: Responsive.height(context, 6),
                            left: Responsive.width(context, 16),
                            right: Responsive.width(context, 16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(seconds),
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: Responsive.fontSize(context, 12),
                                ),
                              ),
                              Text(
                                '${_formatDuration((_durationSeconds - seconds).clamp(0, _durationSeconds))} متبقي',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: Responsive.fontSize(context, 12),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),

          Positioned(
            left: Responsive.width(context, 16),
            right: Responsive.width(context, 16),
            bottom: bottomPadding + Responsive.height(context, 40),
            child: IgnorePointer(
              ignoring: false,
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
                          onTap: () {
                            debugPrint('ReelPlayerWidget: Subscribe button tapped');
                            if (widget.onSubscribeClick != null) {
                              debugPrint('ReelPlayerWidget: Calling onSubscribeClick');
                              widget.onSubscribeClick!();
                            } else {
                              debugPrint('ReelPlayerWidget: onSubscribeClick is null, calling onRedirect');
                              widget.onRedirect();
                            }
                          },
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
          ),
          ],
        ),
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

    final size = MediaQuery.sizeOf(context);
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final cacheW = (size.width * dpr).round().clamp(540, 1080);
    final cacheH = (size.height * dpr).round().clamp(960, 1920);
    return CachedNetworkImage(
      imageUrl: widget.reel.thumbnailUrl,
      fit: BoxFit.cover,
      memCacheWidth: cacheW,
      memCacheHeight: cacheH,
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

    final cacheSize = (size * MediaQuery.of(context).devicePixelRatio).round().clamp(72, 256);
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: Colors.white,
        child: CachedNetworkImage(
          imageUrl: widget.reel.owner.avatarUrl,
          fit: BoxFit.cover,
          memCacheWidth: cacheSize,
          memCacheHeight: cacheSize,
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

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
