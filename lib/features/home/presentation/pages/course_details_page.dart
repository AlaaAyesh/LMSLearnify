import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../lessons/presentation/pages/lesson_player_page.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/lesson.dart';

class CourseDetailsPage extends StatefulWidget {
  final Course course;

  const CourseDetailsPage({
    super.key,
    required this.course,
  });

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  // Track viewed lessons locally
  final Set<int> _viewedLessonIds = {};

  @override
  void initState() {
    super.initState();
    // Initialize with lessons already marked as viewed from API
    for (final chapter in widget.course.chapters) {
      for (final lesson in chapter.lessons) {
        if (lesson.viewed) {
          _viewedLessonIds.add(lesson.id);
        }
      }
    }
  }

  bool _isLessonViewed(int lessonId) {
    return _viewedLessonIds.contains(lessonId);
  }

  void _markLessonAsViewed(int lessonId) {
    if (lessonId > 0) {
      setState(() {
        _viewedLessonIds.add(lessonId);
      });
    }
  }

  Course get course => widget.course;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(title: course.nameAr),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Thumbnail/Video
            _buildCourseThumbnail(context),
            
            // Course Info Card
            _buildCourseInfoCard(),
            
            const SizedBox(height: 24),
            
            // Free Course Banner + Lessons Title
            _buildLessonsTitleSection(context),
            
            const SizedBox(height: 16),
            
            // Lessons Grid
            _buildLessonsGrid(context),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
      // Enroll/Access Button
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildCourseThumbnail(BuildContext context) {
    return GestureDetector(
      onTap: () => _playIntroVideo(context),
      child: Container(
        height: 200,
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: _buildThumbnailImage(),
              ),
            ),
            // Play button
            Positioned.fill(
              child: Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),
            // Soon badge
            if (course.soon)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'قريباً',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailImage() {
    final thumbnailUrl = course.effectiveThumbnail;
    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: thumbnailUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    final gradientColors = [
      [const Color(0xFFFFE082), const Color(0xFFFFB300)],
      [const Color(0xFF81D4FA), const Color(0xFF29B6F6)],
      [const Color(0xFFA5D6A7), const Color(0xFF66BB6A)],
      [const Color(0xFFCE93D8), const Color(0xFFAB47BC)],
      [const Color(0xFFFFAB91), const Color(0xFFFF7043)],
    ];
    final colors = gradientColors[course.id % gradientColors.length];
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.school_outlined,
          size: 60,
          color: Colors.white.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildCourseInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            course.about ?? 'مقدمة ممتعة وشاملة لتعلم، مع التركيز على الأساسيات بطريقة تفاعلية ومبتكرة.',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: Colors.white,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoChip(Icons.workspace_premium_outlined, 'شهادة'),
              _buildInfoChip(Icons.people_outline, course.specialty?.nameAr ?? '4-13 سنة'),
              _buildInfoChip(Icons.access_time_rounded, _getSimpleDuration()),
            ],
          ),
        ],
      ),
    );
  }

  String _getSimpleDuration() {
    int totalMinutes = 0;
    for (final chapter in course.chapters) {
      for (final lesson in chapter.lessons) {
        if (lesson.duration != null) {
          final parts = lesson.duration!.split(':');
          if (parts.length >= 2) {
            final hours = int.tryParse(parts[0]) ?? 0;
            final minutes = int.tryParse(parts[1]) ?? 0;
            totalMinutes += hours * 60 + minutes;
          }
        }
      }
    }
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0) {
      return minutes > 0 ? '$hours:${minutes.toString().padLeft(2, '0')} ساعة' : '$hours ساعات';
    }
    return '$minutes دقيقة';
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),
        Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
      ],
    );
  }

  bool get _isFreeCourse {
    return course.price == null || 
           course.price!.isEmpty || 
           course.price == '0' || 
           course.price == '0.00';
  }

  Widget _buildLessonsTitleSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Code icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.code,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Title
          const Text(
            'دروس الدورة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          // Free course banner (only show if free and user doesn't have access)
          if (_isFreeCourse && !course.hasAccess)
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/login'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'الكورس مجاني سجل دخولك للمشاهدة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'من هنا',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLessonsGrid(BuildContext context) {
    // Flatten all lessons from all chapters
    final allLessons = <_LessonWithChapter>[];
    for (final chapter in course.chapters) {
      for (final lesson in chapter.lessons) {
        allLessons.add(_LessonWithChapter(lesson: lesson, chapter: chapter));
      }
    }

    if (allLessons.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.menu_book_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'لا يوجد دروس متاحة حالياً',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: allLessons.length,
        itemBuilder: (context, index) {
          final item = allLessons[index];
          final isFirstLesson = index == 0; // First lesson always available for preview
          return _LessonCard(
            lesson: item.lesson,
            isAvailable: isFirstLesson,
            hasAccess: course.hasAccess,
            isViewed: _isLessonViewed(item.lesson.id),
            onTap: () => _onLessonTap(context, item.lesson, item.chapter),
          );
        },
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    String buttonText;
    if (course.soon) {
      buttonText = 'قريباً';
    } else if (course.hasAccess) {
      buttonText = 'ابدأ التعلم';
    } else if (_isFreeCourse) {
      buttonText = 'سجل للمشاهدة مجاناً';
    } else {
      buttonText = 'اشترك الآن';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Price
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (course.hasDiscount && !_isFreeCourse)
                    Text(
                      '${course.priceBeforeDiscount} جم',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Text(
                    _isFreeCourse ? 'مجاني' : '${course.price} جم',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _isFreeCourse ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Action Button
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: course.soon ? null : () => _onEnrollPressed(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: course.hasAccess ? AppColors.success : AppColors.primary,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _playIntroVideo(BuildContext context) {
    if (course.introBunnyUrl != null && course.introBunnyUrl!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LessonPlayerPage(
            lessonId: 0,
            lesson: Lesson(
              id: 0,
              nameAr: 'مقدمة الدورة - ${course.nameAr}',
              nameEn: 'Course Introduction',
              description: course.about,
              bunnyUrl: course.introBunnyUrl,
              videoDuration: course.introVideoDuration,
            ),
            course: course,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فيديو المقدمة غير متاح حالياً'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  void _onLessonTap(BuildContext context, Lesson lesson, Chapter chapter) async {
    // If user has access (subscribed), allow all lessons
    if (course.hasAccess) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LessonPlayerPage(
            lessonId: lesson.id,
            lesson: lesson,
            course: course,
            chapter: chapter,
          ),
        ),
      );
      // Mark as viewed when returning from lesson player
      _markLessonAsViewed(lesson.id);
      return;
    }

    // For non-subscribers, only allow first lesson preview
    final isFirstLesson = course.chapters.isNotEmpty && 
        course.chapters.first.lessons.isNotEmpty &&
        course.chapters.first.lessons.first.id == lesson.id;
    
    if (!isFirstLesson) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب الاشتراك أولاً للوصول إلى هذا الدرس'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonPlayerPage(
          lessonId: lesson.id,
          lesson: lesson,
          course: course,
          chapter: chapter,
        ),
      ),
    );
    // Mark as viewed when returning from lesson player
    _markLessonAsViewed(lesson.id);
  }

  void _onEnrollPressed(BuildContext context) async {
    if (course.hasAccess) {
      // User has access - start learning
      if (course.chapters.isNotEmpty && course.chapters.first.lessons.isNotEmpty) {
        final firstChapter = course.chapters.first;
        final firstLesson = firstChapter.lessons.first;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LessonPlayerPage(
              lessonId: firstLesson.id,
              lesson: firstLesson,
              course: course,
              chapter: firstChapter,
            ),
          ),
        );
        // Mark first lesson as viewed
        _markLessonAsViewed(firstLesson.id);
      }
    } else if (_isFreeCourse) {
      // Free course - redirect to login
      Navigator.pushNamed(context, '/login');
    } else {
      // Paid course - redirect to subscriptions
      Navigator.pushNamed(context, '/subscriptions');
    }
  }
}

class _LessonWithChapter {
  final Lesson lesson;
  final Chapter chapter;

  _LessonWithChapter({required this.lesson, required this.chapter});
}

class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  final bool isAvailable;
  final bool hasAccess; // User is subscribed
  final bool isViewed; // Lesson has been viewed
  final VoidCallback onTap;

  const _LessonCard({
    required this.lesson,
    required this.isAvailable,
    required this.hasAccess,
    required this.isViewed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // If user has access (subscribed), all lessons are available
    final bool canAccess = hasAccess || isAvailable;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: _buildLessonThumbnail(),
                    ),
                  ),
                  // Lock overlay for unavailable lessons (only for non-subscribers)
                  if (!canAccess)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Badge logic:
                  // - Watched & completed: "تم المشاهدة" (red) - ONLY when actually watched
                  // - Accessible but not watched: "متاح" (green)
                  // - Locked: no badge (has lock overlay instead)
                  if (canAccess)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isViewed 
                              ? const Color(0xFFFF6B6B) // Red for watched
                              : AppColors.success, // Green for available
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isViewed ? 'تم المشاهدة' : 'متاح',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  // No badge for locked lessons - they show lock overlay
                ],
              ),
            ),
            // Lesson Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      lesson.nameAr,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: (hasAccess || isAvailable) ? AppColors.textPrimary : Colors.grey[500],
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (lesson.duration != null || lesson.videoDuration != null)
                      Text(
                        _formatDuration(lesson.videoDuration ?? lesson.duration!),
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonThumbnail() {
    // Try to get thumbnail from lesson's bunny_uri
    if (lesson.bunnyUri != null && 
        lesson.bunnyUri!.isNotEmpty && 
        lesson.bunnyUri!.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: lesson.bunnyUri!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildLessonPlaceholder(),
        errorWidget: (context, url, error) => _buildLessonPlaceholder(),
      );
    }
    return _buildLessonPlaceholder();
  }

  Widget _buildLessonPlaceholder() {
    final colors = [
      [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
      [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
      [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
      [const Color(0xFFFCE4EC), const Color(0xFFF8BBD9)],
      [const Color(0xFFF3E5F5), const Color(0xFFE1BEE7)],
    ];
    final colorPair = colors[lesson.id % colors.length];
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colorPair,
        ),
      ),
      child: Center(
        child: Icon(
          _getLessonIcon(),
          size: 40,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  IconData _getLessonIcon() {
    final name = lesson.nameAr.toLowerCase();
    if (name.contains('أرقام') || name.contains('رقم') || name.contains('عد')) {
      return Icons.calculate_outlined;
    }
    if (name.contains('حرف') || name.contains('أبجد') || name.contains('حروف')) {
      return Icons.abc;
    }
    if (name.contains('حيوان') || name.contains('قط') || name.contains('كلب')) {
      return Icons.pets_outlined;
    }
    if (name.contains('لون') || name.contains('ألوان')) {
      return Icons.palette_outlined;
    }
    if (name.contains('شكل') || name.contains('هندس')) {
      return Icons.category_outlined;
    }
    return Icons.play_lesson_outlined;
  }

  String _formatDuration(String duration) {
    final parts = duration.split(':');
    if (parts.length >= 2) {
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      final seconds = int.tryParse(parts.length > 2 ? parts[2] : '0') ?? 0;
      
      if (hours > 0) {
        return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      }
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return duration;
  }
}
