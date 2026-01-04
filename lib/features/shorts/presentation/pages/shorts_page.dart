import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/short_video.dart';
import '../widgets/shorts_grid.dart';
import 'short_player_page.dart';

class ShortsPage extends StatefulWidget {
  const ShortsPage({super.key});

  @override
  State<ShortsPage> createState() => _ShortsPageState();
}

class _ShortsPageState extends State<ShortsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Sample data - Replace with actual API data
  final List<ShortVideo> _myVideos = [
    ShortVideo(
      id: 1,
      title: 'تعلم كيفية نطق الحروف',
      description: 'درس ممتع لتعلم نطق الحروف العربية',
      thumbnailUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400',
      videoUrl: '',
      channelName: 'ليرنفاي',
      channelAvatarUrl: '',
      viewsCount: 1500000,
      likesCount: 19600,
      tags: ['برمجة', 'رسم', 'انجلش', 'عام'],
      createdAt: DateTime.now(),
    ),
    ShortVideo(
      id: 2,
      title: 'تعلم البرمجة للأطفال',
      description: 'مقدمة في البرمجة للمبتدئين',
      thumbnailUrl: 'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=400',
      videoUrl: '',
      channelName: 'ليرنفاي',
      channelAvatarUrl: '',
      viewsCount: 1500000,
      likesCount: 12000,
      tags: ['برمجة'],
      createdAt: DateTime.now(),
    ),
    ShortVideo(
      id: 3,
      title: 'رسم للمبتدئين',
      description: 'تعلم أساسيات الرسم',
      thumbnailUrl: 'https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?w=400',
      videoUrl: '',
      channelName: 'ليرنفاي',
      channelAvatarUrl: '',
      viewsCount: 1500000,
      likesCount: 8500,
      tags: ['رسم'],
      createdAt: DateTime.now(),
    ),
    ShortVideo(
      id: 4,
      title: 'تعلم الإنجليزية',
      description: 'كلمات إنجليزية جديدة',
      thumbnailUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400',
      videoUrl: '',
      channelName: 'ليرنفاي',
      channelAvatarUrl: '',
      viewsCount: 1500000,
      likesCount: 15000,
      tags: ['انجلش'],
      createdAt: DateTime.now(),
    ),
    ShortVideo(
      id: 5,
      title: 'مغامرة في الصحراء',
      description: 'رحلة استكشافية ممتعة',
      thumbnailUrl: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=400',
      videoUrl: '',
      channelName: 'ليرنفاي',
      channelAvatarUrl: '',
      viewsCount: 1500000,
      likesCount: 22000,
      tags: ['عام'],
      createdAt: DateTime.now(),
    ),
    ShortVideo(
      id: 6,
      title: 'الطبيعة الخلابة',
      description: 'مناظر طبيعية رائعة',
      thumbnailUrl: 'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=400',
      videoUrl: '',
      channelName: 'ليرنفاي',
      channelAvatarUrl: '',
      viewsCount: 1500000,
      likesCount: 18000,
      tags: ['عام'],
      createdAt: DateTime.now(),
    ),
    ShortVideo(
      id: 7,
      title: 'ألوان الحياة',
      description: 'تعلم الألوان بطريقة ممتعة',
      thumbnailUrl: 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=400',
      videoUrl: '',
      channelName: 'ليرنفاي',
      channelAvatarUrl: '',
      viewsCount: 800000,
      likesCount: 9500,
      tags: ['رسم'],
      createdAt: DateTime.now(),
    ),
    ShortVideo(
      id: 8,
      title: 'نباتات جميلة',
      description: 'تعرف على النباتات',
      thumbnailUrl: 'https://images.unsplash.com/photo-1459411552884-841db9b3cc2a?w=400',
      videoUrl: '',
      channelName: 'ليرنفاي',
      channelAvatarUrl: '',
      viewsCount: 650000,
      likesCount: 7200,
      tags: ['عام'],
      createdAt: DateTime.now(),
    ),
    ShortVideo(
      id: 9,
      title: 'عالم الحيوانات',
      description: 'تعرف على الحيوانات الأليفة',
      thumbnailUrl: 'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=400',
      videoUrl: '',
      channelName: 'ليرنفاي',
      channelAvatarUrl: '',
      viewsCount: 2100000,
      likesCount: 25000,
      tags: ['عام'],
      createdAt: DateTime.now(),
    ),
  ];

  final List<ShortVideo> _likedVideos = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Add some liked videos
    _likedVideos.addAll(_myVideos.take(3));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Logo
            _buildHeader(),
            const SizedBox(height: 24),
            // Tabs
            _buildTabs(),
            const SizedBox(height: 16),
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ShortsGrid(
                    videos: _myVideos,
                    onVideoTap: _onVideoTap,
                  ),
                  ShortsGrid(
                    videos: _likedVideos,
                    onVideoTap: _onVideoTap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo Circle
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary,
              width: 3,
            ),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/app_logo.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.primary.withOpacity(0.1),
                  child: Center(
                    child: Text(
                      'L',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Title
        const Text(
          'Learnify',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        // Subtitle with emojis
        const Text(
          'I love a colorful life 🧡🧡🧡',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 60),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primary,
        indicatorWeight: 2,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.play_arrow_outlined, size: 20),
                SizedBox(width: 6),
                Text('My Videos'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.favorite_border, size: 20),
                SizedBox(width: 6),
                Text('Liked'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onVideoTap(ShortVideo video, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShortPlayerPage(
          videos: _tabController.index == 0 ? _myVideos : _likedVideos,
          initialIndex: index,
        ),
      ),
    );
  }
}


