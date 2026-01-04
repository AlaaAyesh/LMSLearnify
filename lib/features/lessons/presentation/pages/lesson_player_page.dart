import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bunny_video_player.dart';
import '../../../home/domain/entities/chapter.dart';
import '../../../home/domain/entities/course.dart';
import '../../../home/domain/entities/lesson.dart';
import '../bloc/lesson_bloc.dart';
import '../bloc/lesson_event.dart';
import '../bloc/lesson_state.dart';

class LessonPlayerPage extends StatelessWidget {
  final int lessonId;
  final Lesson? lesson;
  final Course? course;
  final Chapter? chapter;

  const LessonPlayerPage({
    super.key,
    required this.lessonId,
    this.lesson,
    this.course,
    this.chapter,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = sl<LessonBloc>();
        if (lessonId > 0) {
          bloc.add(LoadLessonEvent(lessonId: lessonId));
        }
        return bloc;
      },
      child: _LessonPlayerPageContent(
        lessonId: lessonId,
        initialLesson: lesson,
        course: course,
        chapter: chapter,
      ),
    );
  }
}

class _LessonPlayerPageContent extends StatefulWidget {
  final int lessonId;
  final Lesson? initialLesson;
  final Course? course;
  final Chapter? chapter;

  const _LessonPlayerPageContent({
    required this.lessonId,
    this.initialLesson,
    this.course,
    this.chapter,
  });

  @override
  State<_LessonPlayerPageContent> createState() => _LessonPlayerPageContentState();
}

class _LessonPlayerPageContentState extends State<_LessonPlayerPageContent> {
  bool _hasMarkedAsViewed = false;
  bool _showLessonsList = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  void _onVideoLoaded() {
    if (!_hasMarkedAsViewed && widget.lessonId > 0) {
      _hasMarkedAsViewed = true;
      context.read<LessonBloc>().add(MarkLessonViewedEvent(lessonId: widget.lessonId));
    }
  }

  @override
  Widget build(BuildContext context) {
    // For intro videos (lessonId <= 0), use initial lesson directly
    if (widget.lessonId <= 0 && widget.initialLesson?.bunnyUrl != null) {
      return _buildPlayerPage(widget.initialLesson!);
    }

    return BlocConsumer<LessonBloc, LessonState>(
      listener: (context, state) {
        if (state is LessonError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is LessonLoading) return _buildLoadingScreen();
        if (state is LessonLoaded) return _buildPlayerPage(state.lesson);
        if (state is LessonError) return _buildErrorScreen(state.message);
        return _buildLoadingScreen();
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontFamily: 'Cairo', fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (widget.lessonId > 0) {
                  context.read<LessonBloc>().add(LoadLessonEvent(lessonId: widget.lessonId));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerPage(Lesson lesson) {
    final videoUrl = lesson.bunnyUrl;

    if (videoUrl == null || videoUrl.isEmpty) {
      return _buildNoVideoScreen(lesson);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Video Player Section
            Stack(
              children: [
                BunnyVideoPlayer(
                  videoUrl: videoUrl,
                  onVideoLoaded: _onVideoLoaded,
                ),
                // Back button overlay
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
            // Content Section
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Lesson Info Card
                    _buildLessonInfoCard(lesson),
                    
                    // Course & Chapter Info
                    if (widget.course != null || widget.chapter != null)
                      _buildCourseChapterInfo(),
                    
                    // Chapter Lessons List
                    if (widget.chapter != null && widget.chapter!.lessons.isNotEmpty)
                      _buildChapterLessons(lesson),
                    
                    // Description Section
                    if (lesson.description != null && lesson.description!.isNotEmpty)
                      _buildDescriptionSection(lesson),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonInfoCard(Lesson lesson) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lesson Title
          Text(
            lesson.nameAr,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          // Lesson Meta Info
          Row(
            children: [
              if (lesson.videoDuration != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        lesson.videoDuration!,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (lesson.viewed) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 14, color: AppColors.success),
                      SizedBox(width: 4),
                      Text(
                        'تمت المشاهدة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseChapterInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Info
          if (widget.course != null) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.school, size: 20, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الدورة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        widget.course!.nameAr,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          // Chapter Info
          if (widget.chapter != null) ...[
            if (widget.course != null) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1),
              ),
            ],
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.folder_outlined, size: 20, color: AppColors.warning),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الفصل',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        widget.chapter!.nameAr,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Lessons count badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.chapter!.lessons.length} دروس',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChapterLessons(Lesson currentLesson) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with toggle
        InkWell(
          onTap: () => setState(() => _showLessonsList = !_showLessonsList),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.playlist_play, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'دروس الفصل',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  _showLessonsList ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        // Lessons List
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _buildLessonsList(currentLesson),
          crossFadeState: _showLessonsList ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  Widget _buildLessonsList(Lesson currentLesson) {
    final lessons = widget.chapter!.lessons;
    final currentIndex = lessons.indexWhere((l) => l.id == currentLesson.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: lessons.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          final isCurrentLesson = lesson.id == currentLesson.id;

          return ListTile(
            onTap: isCurrentLesson
                ? null
                : () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LessonPlayerPage(
                          lessonId: lesson.id,
                          lesson: lesson,
                          course: widget.course,
                          chapter: widget.chapter,
                        ),
                      ),
                    );
                  },
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCurrentLesson
                    ? AppColors.primary
                    : lesson.viewed
                        ? AppColors.success.withOpacity(0.1)
                        : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isCurrentLesson
                    ? const Icon(Icons.play_arrow, color: Colors.white, size: 18)
                    : lesson.viewed
                        ? const Icon(Icons.check, color: AppColors.success, size: 16)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
              ),
            ),
            title: Text(
              lesson.nameAr,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: isCurrentLesson ? FontWeight.bold : FontWeight.w500,
                color: isCurrentLesson ? AppColors.primary : AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: lesson.duration != null
                ? Text(
                    lesson.duration!,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  )
                : null,
            trailing: isCurrentLesson
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'الآن',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : const Icon(Icons.chevron_left, color: AppColors.textSecondary, size: 20),
          );
        },
      ),
    );
  }

  Widget _buildDescriptionSection(Lesson lesson) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'وصف الدرس',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              lesson.description!,
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

  Widget _buildNoVideoScreen(Lesson lesson) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          lesson.nameAr,
          style: const TextStyle(
            color: AppColors.primary,
            fontFamily: 'Cairo',
            fontSize: 16,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'الفيديو غير متاح حالياً',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            if (lesson.videoStatus != null) ...[
              const SizedBox(height: 8),
              Text(
                'الحالة: ${lesson.videoStatus}',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
