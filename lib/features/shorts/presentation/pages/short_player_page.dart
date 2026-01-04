import 'package:flutter/material.dart';
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
      const SnackBar(
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
            child: const Center(
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

        // Top Tags
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: _buildTags(),
        ),

        // Left Side Actions (Like, Share)
        Positioned(
          left: 16,
          bottom: 120,
          child: _buildSideActions(),
        ),

        // Bottom Info
        Positioned(
          right: 16,
          left: 80,
          bottom: 40,
          child: _buildBottomInfo(context),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Row(
      children: video.tags.map((tag) {
        return Container(
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: tag == 'برمجة' 
                ? AppColors.primary 
                : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: tag == 'برمجة' ? Colors.white : Colors.white,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSideActions() {
    return Column(
      children: [
        // Like Button
        GestureDetector(
          onTap: onLike,
          child: Column(
            children: [
              Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.white,
                size: 32,
              ),
              const SizedBox(height: 4),
              Text(
                video.formattedLikes,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Share Button
        GestureDetector(
          onTap: onShare,
          child: Column(
            children: const [
              Icon(
                Icons.reply,
                color: Colors.white,
                size: 32,
              ),
              SizedBox(height: 4),
              Text(
                'مشاركة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Channel Info
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(
                      video.channelName,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chat_bubble,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  video.description,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Subscribe Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // TODO: Implement subscribe
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم الاشتراك بنجاح'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'اشترك من هنا',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}


