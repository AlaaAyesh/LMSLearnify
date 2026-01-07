import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';

import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/short_video.dart';

class ShortPlayerPage extends StatefulWidget {
  final List<ShortVideo> videos;
  final int initialIndex;

  const ShortPlayerPage({
    super.key,
    required this.videos,
    this.initialIndex = 0,
  });

  @override
  State<ShortPlayerPage> createState() => _ShortPlayerPageState();
}

class _ShortPlayerPageState extends State<ShortPlayerPage> {
  late PageController _pageController;
  late int _currentIndex;
  final Map<int, bool> _likedVideos = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    
    // Initialize liked status
    for (var video in widget.videos) {
      _likedVideos[video.id] = video.isLiked;
    }
    
    // Set status bar to light content for dark background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Reset status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.videos.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (context, index) {
          return _ShortVideoPlayer(
            video: widget.videos[index],
            isLiked: _likedVideos[widget.videos[index].id] ?? false,
            onLike: () => _toggleLike(widget.videos[index]),
            onShare: () => _shareVideo(widget.videos[index]),
            onBack: () => Navigator.pop(context),
          );
        },
      ),
    );
  }

  void _toggleLike(ShortVideo video) {
    setState(() {
      _likedVideos[video.id] = !(_likedVideos[video.id] ?? false);
    });
  }

  void _shareVideo(ShortVideo video) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('مشاركة الفيديو'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

class _ShortVideoPlayer extends StatelessWidget {
  final ShortVideo video;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onShare;
  final VoidCallback onBack;

  const _ShortVideoPlayer({
    required this.video,
    required this.isLiked,
    required this.onLike,
    required this.onShare,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video/Image Background
        CachedNetworkImage(
          imageUrl: video.thumbnailUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: AppColors.primary,
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: AppColors.primary,
            child: const Icon(
              Icons.play_circle_outline,
              color: Colors.white,
              size: 80,
            ),
          ),
        ),

        // Gradient overlay at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 300,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Left Side Actions (Like, Share)
        Positioned(
          left: 16,
          bottom: 140,
          child: _buildSideActions(),
        ),

        // Right Side - Channel Info
        Positioned(
          right: 16,
          bottom: 140,
          child: _buildChannelInfo(),
        ),

        // Bottom Subscribe Button
        Positioned(
          left: 24,
          right: 24,
          bottom: 40,
          child: _buildSubscribeButton(context),
        ),
      ],
    );
  }

  Widget _buildSideActions() {
    return Column(
      children: [
        // Like Button with count
        GestureDetector(
          onTap: onLike,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite,
                  color: isLiked ? Colors.red : Colors.white,
                  size: 28,
                ),
              ),
              SizedBox(height: 6),
              Text(
                _formatCount(video.likesCount),
                style: TextStyle(
                  fontFamily: cairoFontFamily,
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
        // Share Button
        GestureDetector(
          onTap: onShare,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(3.14159), // Mirror the icon
                  child: const Icon(
                    Icons.reply,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              SizedBox(height: 6),
              Text(
                'مشاركة',
                style: TextStyle(
                  fontFamily: cairoFontFamily,
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChannelInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Channel name with icon
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              video.channelName,
              style: TextStyle(
                fontFamily: cairoFontFamily,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.remove,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        // Description/Title
        SizedBox(
          width: 200,
          child: Text(
            video.description,
            style: TextStyle(
              fontFamily: cairoFontFamily,
              fontSize: 13,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildSubscribeButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم الاشتراك بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 4,
      ),
      child: Text(
        'اشترك من هنا',
        style: TextStyle(
          fontFamily: cairoFontFamily,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}



