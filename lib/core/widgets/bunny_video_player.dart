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
    
    // Add parameters
    if (!embedUrl.contains('?')) {
      embedUrl = '$embedUrl?autoplay=true&responsive=true';
    } else {
      embedUrl = '$embedUrl&autoplay=true&responsive=true';
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
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
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
      ),
    );
  }
}



