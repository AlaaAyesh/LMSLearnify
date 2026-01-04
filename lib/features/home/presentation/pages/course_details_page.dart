import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../lessons/presentation/pages/lesson_player_page.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/lesson.dart';

class CourseDetailsPage extends StatelessWidget {
  final Course course;

  const CourseDetailsPage({
    super.key,
    required this.course,
  });

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
            
            // What You'll Learn
            if (course.whatYouWillLearn != null && course.whatYouWillLearn!.isNotEmpty)
              _buildWhatYouLearnSection(),
            
            // Course Content (Chapters & Lessons)
            _buildCourseContent(context),
            
            const SizedBox(height: 24),
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
      child: Stack(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildThumbnailImage(),
            ),
          ),
          // Play button
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
          // Soon badge
          if (course.soon)
            Positioned(
              top: 24,
              right: 24,
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
    );
  }

  Widget _buildThumbnailImage() {
    final thumbnailUrl = course.effectiveThumbnail;
    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: thumbnailUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.primary.withOpacity(0.1),
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    // Use gradient based on course ID
    final gradientColors = [
      [const Color(0xFFFFD54F), const Color(0xFFFFB300)],
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
          size: 80,
          color: Colors.white.withOpacity(0.5),
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course.about ?? 'مقدمة ممتعة وشاملة للتعلم، مع التركيز على الأساسيات بطريقة تفاعلية ومبتكرة.',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: Colors.white,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(Icons.workspace_premium_outlined, 'شهادة'),
              _buildInfoItem(Icons.people_outline, course.specialty?.nameAr ?? '4-13 سنة'),
              _buildInfoItem(Icons.access_time, course.totalDuration),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(Icons.menu_book_outlined, '${course.chapters.length} فصول'),
              _buildInfoItem(Icons.play_lesson_outlined, '${course.totalLessons} درس'),
              if (course.reviewsAvg != null)
                _buildInfoItem(Icons.star_outline, course.reviewsAvg!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWhatYouLearnSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ماذا ستتعلم',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              course.whatYouWillLearn!,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseContent(BuildContext context) {
    if (course.chapters.isEmpty) {
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
                'لا يوجد محتوى متاح حالياً',
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'محتوى الدورة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // Chapters with expandable lessons
          ...course.chapters.asMap().entries.map((entry) {
            final index = entry.key;
            final chapter = entry.value;
            return _ChapterExpansionTile(
              chapter: chapter,
              chapterIndex: index + 1,
              onLessonTap: (lesson) => _onLessonTap(context, lesson),
              hasAccess: course.hasAccess,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
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
                  if (course.hasDiscount)
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
                    course.price != null && course.price!.isNotEmpty && course.price != '0'
                        ? '${course.price} جم'
                        : 'مجاني',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: course.price == null || course.price!.isEmpty || course.price == '0'
                          ? AppColors.success
                          : AppColors.primary,
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
                  course.soon 
                      ? 'قريباً' 
                      : course.hasAccess 
                          ? 'ابدأ التعلم' 
                          : 'اشترك الآن',
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
      // Create a temporary lesson object for the intro video
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LessonPlayerPage(
            lessonId: 0, // Intro video doesn't have a real lesson ID
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

  void _onLessonTap(BuildContext context, Lesson lesson) {
    if (!course.hasAccess && !course.soon) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب الاشتراك أولاً للوصول إلى الدروس'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Find the chapter containing this lesson
    Chapter? lessonChapter;
    for (final chapter in course.chapters) {
      if (chapter.lessons.any((l) => l.id == lesson.id)) {
        lessonChapter = chapter;
        break;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonPlayerPage(
          lessonId: lesson.id,
          lesson: lesson,
          course: course,
          chapter: lessonChapter,
        ),
      ),
    );
  }

  void _onEnrollPressed(BuildContext context) {
    if (course.hasAccess) {
      // Start learning - go to first lesson
      if (course.chapters.isNotEmpty && course.chapters.first.lessons.isNotEmpty) {
        final firstChapter = course.chapters.first;
        final firstLesson = firstChapter.lessons.first;
        Navigator.push(
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
      }
    } else {
      // Navigate to subscription page
      Navigator.pushNamed(context, '/subscriptions');
    }
  }
}

class _ChapterExpansionTile extends StatefulWidget {
  final Chapter chapter;
  final int chapterIndex;
  final Function(Lesson) onLessonTap;
  final bool hasAccess;

  const _ChapterExpansionTile({
    required this.chapter,
    required this.chapterIndex,
    required this.onLessonTap,
    required this.hasAccess,
  });

  @override
  State<_ChapterExpansionTile> createState() => _ChapterExpansionTileState();
}

class _ChapterExpansionTileState extends State<_ChapterExpansionTile> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // Auto-expand first chapter
    _isExpanded = widget.chapterIndex == 1;
  }

  @override
  Widget build(BuildContext context) {
    final viewedCount = widget.chapter.lessons.where((l) => l.viewed).length;
    final totalCount = widget.chapter.lessons.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Chapter Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Chapter Number
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.chapterIndex}',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Chapter Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.chapter.nameAr,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$totalCount دروس • $viewedCount مكتمل',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Expand Icon
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          // Lessons List
          if (_isExpanded)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: widget.chapter.lessons.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.grey[100],
                indent: 64,
              ),
              itemBuilder: (context, index) {
                final lesson = widget.chapter.lessons[index];
                return _LessonListItem(
                  lesson: lesson,
                  lessonIndex: index + 1,
                  onTap: () => widget.onLessonTap(lesson),
                  isLocked: !widget.hasAccess,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _LessonListItem extends StatelessWidget {
  final Lesson lesson;
  final int lessonIndex;
  final VoidCallback onTap;
  final bool isLocked;

  const _LessonListItem({
    required this.lesson,
    required this.lessonIndex,
    required this.onTap,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Lesson Status Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: lesson.viewed
                    ? AppColors.success.withOpacity(0.1)
                    : isLocked
                        ? Colors.grey[100]
                        : AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  lesson.viewed
                      ? Icons.check
                      : isLocked
                          ? Icons.lock_outline
                          : Icons.play_arrow,
                  size: 16,
                  color: lesson.viewed
                      ? AppColors.success
                      : isLocked
                          ? Colors.grey[400]
                          : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Lesson Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.nameAr,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isLocked ? Colors.grey[500] : AppColors.textPrimary,
                    ),
                  ),
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
            // Play Icon
            Icon(
              Icons.play_circle_outline,
              color: isLocked ? Colors.grey[300] : AppColors.primary,
              size: 24,
            ),
          ],
        ),
      ),
    );
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
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
    return duration;
  }
}
