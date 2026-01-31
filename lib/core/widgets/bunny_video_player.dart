import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BunnyVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final VoidCallback? onVideoLoaded;

  const BunnyVideoPlayer({
    super.key,
    required this.videoUrl,
    this.onVideoLoaded,
  });

  @override
  State<BunnyVideoPlayer> createState() => _BunnyVideoPlayerState();
}

class _BunnyVideoPlayerState extends State<BunnyVideoPlayer> {
  late final WebViewController controller;
  bool _isLoading = true;

  String _getEmbedUrl(String url) {
    // Convert play URL to embed URL for better responsiveness
    // From: https://iframe.mediadelivery.net/play/332604/video-id
    // To: https://iframe.mediadelivery.net/embed/332604/video-id
    String embedUrl = url.replaceFirst('/play/', '/embed/');
    
    // Add parameters to make video fill width and remove black bars
    if (!embedUrl.contains('?')) {
      embedUrl = '$embedUrl?autoplay=true&responsive=true&aspectRatio=16:9';
    } else {
      embedUrl = '$embedUrl&autoplay=true&responsive=true&aspectRatio=16:9';
    }
    return embedUrl;
  }

  @override
  void initState() {
    super.initState();

    final embedUrl = _getEmbedUrl(widget.videoUrl);

    // Create responsive HTML wrapper
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
      margin: 0;
      padding: 0;
    }
    .video-wrapper {
      position: relative;
      width: 100%;
      height: 100%;
      overflow: hidden;
    }
    iframe {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      border: 0;
      min-width: 100%;
      min-height: 100%;
    }
  </style>
</head>
<body>
  <div class="video-wrapper">
    <iframe 
      src="$embedUrl"
      loading="lazy"
      style="border:0;position:absolute;top:50%;left:0;width:100%;height:100%;transform:translateY(-50%);"
      allow="accelerometer;gyroscope;autoplay;encrypted-media;picture-in-picture;fullscreen"
      allowfullscreen="true">
    </iframe>
  </div>
</body>
</html>
''';

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              widget.onVideoLoaded?.call();
            }
          },
        ),
      )
      ..loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            WebViewWidget(controller: controller),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
          ],
      ),
    );
  }
}



