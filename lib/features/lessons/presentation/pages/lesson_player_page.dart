import 'dart:async';
import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/bunny_video_player.dart';
import '../../../authentication/data/datasources/auth_local_datasource.dart';
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
  final Function(double)? onProgressUpdate;

  const LessonPlayerPage({
    super.key,
    required this.lessonId,
    this.lesson,
    this.course,
    this.chapter,
    this.onProgressUpdate,
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
        onProgressUpdate: onProgressUpdate,
      ),
    );
  }
}

class _LessonPlayerPageContent extends StatefulWidget {
  final int lessonId;
  final Lesson? initialLesson;
  final Course? course;
  final Chapter? chapter;
  final Function(double)? onProgressUpdate;

  const _LessonPlayerPageContent({
    required this.lessonId,
    this.initialLesson,
    this.course,
    this.chapter,
    this.onProgressUpdate,
  });

  @override
  State<_LessonPlayerPageContent> createState() => _LessonPlayerPageContentState();
}

class _LessonPlayerPageContentState extends State<_LessonPlayerPageContent> {
  bool _hasMarkedAsViewed = false;
  bool _showLessonsList = true; // Open by default
  WebViewController? _videoController;
  String? _currentVideoUrl;
  
  // Video progress tracking
  DateTime? _videoStartTime;
  Timer? _progressTimer;
  double _currentProgress = 0.0;
  int? _videoDurationSeconds;
  
  // Authentication state
  bool? _isAuthenticated;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    
    // Allow all orientations for video playback (user can rotate manually)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    // Don't auto-rotate to landscape - let user control fullscreen via video player button
  }

  Future<void> _checkAuthentication() async {
    try {
      final authLocalDataSource = sl<AuthLocalDataSource>();
      final token = await authLocalDataSource.getAccessToken();
      setState(() {
        _isAuthenticated = token != null && token.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _isAuthenticated = false;
      });
    }
  }


  @override
  void dispose() {
    _progressTimer?.cancel();
    
    // Lesson should already be marked as viewed when video loaded
    // But as a fallback, mark it if it wasn't marked yet
    if (widget.lessonId > 0 && !_hasMarkedAsViewed) {
      print('LessonPlayerPage: Marking lesson ${widget.lessonId} as viewed on dispose (fallback)');
      if (mounted) {
        context.read<LessonBloc>().add(MarkLessonViewedEvent(lessonId: widget.lessonId));
      }
      // Update parent callback
      if (widget.onProgressUpdate != null) {
        widget.onProgressUpdate!(1.0); // Set to 100% to indicate viewed
      }
    }
    
    // Restore portrait orientation when leaving
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  int? _parseDurationToSeconds(String? duration) {
    if (duration == null || duration.isEmpty) return null;
    try {
      // Parse format like "05:30" or "1:05:30"
      final parts = duration.split(':');
      if (parts.length == 2) {
        final minutes = int.parse(parts[0]);
        final seconds = int.parse(parts[1]);
        return minutes * 60 + seconds;
      } else if (parts.length == 3) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final seconds = int.parse(parts[2]);
        return hours * 3600 + minutes * 60 + seconds;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  void _startProgressTracking(Lesson lesson) {
    if (widget.lessonId <= 0) {
      print('LessonPlayerPage: Skipping progress tracking for invalid lesson ID: ${widget.lessonId}');
      return;
    }
    
    // Prevent multiple timers
    if (_progressTimer != null && _progressTimer!.isActive) {
      print('LessonPlayerPage: Progress tracking already started for lesson ${widget.lessonId}');
      return;
    }
    
    _videoDurationSeconds = _parseDurationToSeconds(lesson.videoDuration ?? lesson.duration);
    if (_videoDurationSeconds == null || _videoDurationSeconds! <= 0) {
      print('LessonPlayerPage: Cannot start progress tracking - invalid duration for lesson ${widget.lessonId}');
      return;
    }
    
    print('LessonPlayerPage: Starting progress tracking for lesson ${widget.lessonId} (duration: $_videoDurationSeconds seconds)');
    
    _videoStartTime = DateTime.now();
    _currentProgress = 0.0;
    _hasMarkedAsViewed = false; // Reset when starting new tracking
    
    // Update progress every second
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_videoStartTime == null || _videoDurationSeconds == null) {
        timer.cancel();
        return;
      }
      
      final elapsed = DateTime.now().difference(_videoStartTime!).inSeconds;
      final newProgress = (elapsed / _videoDurationSeconds!).clamp(0.0, 1.0);
      
      if (mounted) {
        setState(() {
          _currentProgress = newProgress;
        });
        
        // Update parent with progress every second
        if (widget.onProgressUpdate != null) {
          widget.onProgressUpdate!(newProgress);
          print('LessonPlayerPage: Progress update - lesson ${widget.lessonId}, progress: ${(newProgress * 100).toStringAsFixed(1)}%');
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _onVideoLoaded() {
    // Mark as viewed immediately when video loads
    if (widget.lessonId > 0 && !_hasMarkedAsViewed) {
      _hasMarkedAsViewed = true;
      print('LessonPlayerPage: Marking lesson ${widget.lessonId} as viewed (video loaded)');
      if (mounted) {
        // Mark via API
        context.read<LessonBloc>().add(MarkLessonViewedEvent(lessonId: widget.lessonId));
        // Also notify parent to update UI
        if (widget.onProgressUpdate != null) {
          widget.onProgressUpdate!(1.0); // Set progress to 100% to indicate viewed
        }
      }
    }
  }

  WebViewController _getVideoController(String videoUrl) {
    // Return existing controller if URL hasn't changed
    if (_videoController != null && _currentVideoUrl == videoUrl) {
      return _videoController!;
    }
    
    _currentVideoUrl = videoUrl;
    
    String embedUrl = videoUrl.replaceFirst('/play/', '/embed/');
    if (!embedUrl.contains('?')) {
      embedUrl = '$embedUrl?autoplay=true&responsive=true&aspectRatio=16:9';
    } else {
      embedUrl = '$embedUrl&autoplay=true&responsive=true&aspectRatio=16:9';
    }

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
      allow="accelerometer;gyroscope;autoplay;encrypted-media;picture-in-picture;fullscreen"
      allowfullscreen="true">
    </iframe>
  </div>
</body>
</html>
''';

    _videoController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..loadHtmlString(html);
    
    return _videoController!;
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
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          // );
        }
        if (state is LessonLoaded) {
          // Start tracking progress when lesson is loaded
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _startProgressTracking(state.lesson);
          });
        }
      },
      builder: (context, state) {
        if (state is LessonLoading) return _buildLoadingScreen();
        if (state is LessonLoaded) return _buildPlayerPage(state.lesson);
        if (state is LessonError) {
          // Check if we can use initialLesson for free courses
          // If authentication check is still pending, wait a bit and rebuild
          if (_isAuthenticated == null) {
            // Wait for auth check to complete
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                setState(() {});
              }
            });
            return _buildLoadingScreen();
          }
          
          if (_canUseInitialLessonForFreeCourse(state.message)) {
            return _buildPlayerPage(widget.initialLesson!);
          }
          return _buildErrorScreen(state.message);
        }
        return _buildLoadingScreen();
      },
    );
  }

  /// Check if we can use initialLesson for free courses when API returns access denied
  bool _canUseInitialLessonForFreeCourse(String errorMessage) {
    // Check if error is access denied related
    final isAccessDenied = errorMessage.toLowerCase().contains('access denied') ||
        errorMessage.toLowerCase().contains('permission') ||
        errorMessage.toLowerCase().contains('unauthorized') ||
        errorMessage.toLowerCase().contains('ليس لديك صلاحية');

    if (!isAccessDenied) return false;

    // Check if course is free
    if (widget.course == null) return false;
    final isFreeCourse = widget.course!.price == null ||
        widget.course!.price!.isEmpty ||
        widget.course!.price == '0' ||
        widget.course!.price == '0.00';

    if (!isFreeCourse) return false;

    // Check if initialLesson is available
    if (widget.initialLesson == null || 
        (widget.initialLesson!.bunnyUrl == null || widget.initialLesson!.bunnyUrl!.isEmpty)) {
      return false;
    }

    // Check if user is authenticated (use cached value)
    return _isAuthenticated == true;
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, _currentProgress),
        ),
      ),
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.spacing(context, 24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Login Icon with Gradient Background
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: EdgeInsets.all(Responsive.spacing(context, 24)),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        size: Responsive.iconSize(context, 72),
                        color: AppColors.primary,
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: Responsive.spacing(context, 32)),

              // Main Title
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child:Text(
                  'عذرًا',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontFamily: 'Cairo',
                    fontSize: Responsive.fontSize(context, 26),
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                    shadows: [
                      Shadow(
                        color: AppColors.white.withOpacity(0.35),
                        offset: const Offset(2, 2),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),

              ),

              SizedBox(height: Responsive.spacing(context, 12)),

              // Message
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(Responsive.spacing(context, 16)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontFamily: 'Cairo',
                      fontSize: Responsive.fontSize(context, 16),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              SizedBox(height: Responsive.spacing(context, 40)),

              // Retry Button with Animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.lessonId > 0
                        ? () {
                      context.read<LessonBloc>().add(
                        LoadLessonEvent(lessonId: widget.lessonId),
                      );
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: Responsive.spacing(context, 16),
                        horizontal: Responsive.spacing(context, 32),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      shadowColor: AppColors.primary.withOpacity(0.4),
                    ).copyWith(
                      elevation: MaterialStateProperty.resolveWith<double>(
                            (states) {
                          if (states.contains(MaterialState.pressed)) {
                            return 0;
                          }
                          return 8;
                        },
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.refresh_rounded, size: 22),
                        SizedBox(width: Responsive.spacing(context, 8)),
                        Text(
                          'إعادة المحاولة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: Responsive.fontSize(context, 16),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: Responsive.spacing(context, 16)),

              // Back to Home Option
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1400),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'العودة للخلف',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontFamily: 'Cairo',
                      fontSize: Responsive.fontSize(context, 14),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildPlayerPage(Lesson lesson) {
    final videoUrl = lesson.bunnyUrl;

    if (videoUrl == null || videoUrl.isEmpty) {
      return _buildNoVideoScreen(lesson);
    }
    
    // Start progress tracking if not already started
    if (_videoStartTime == null && widget.lessonId > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startProgressTracking(lesson);
      });
    }

    // Always show video inline - user can use fullscreen button in video player
    return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Video Player Section
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    children: [
                      BunnyVideoPlayer(
                        videoUrl: videoUrl,
                        onVideoLoaded: () {
                          _onVideoLoaded();
                          // Start progress tracking when video loads
                          if (widget.lessonId > 0) {
                            _startProgressTracking(lesson);
                          }
                        },
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
                            icon: Icon(Icons.arrow_back, color: Colors.white, size: Responsive.iconSize(context, 20)),
                            onPressed: () {
                              // Check progress before navigating back
                              if (widget.lessonId > 0 && _videoStartTime != null && _videoDurationSeconds != null && _videoDurationSeconds! > 0) {
                                final elapsed = DateTime.now().difference(_videoStartTime!).inSeconds;
                                final finalProgress = (elapsed / _videoDurationSeconds!).clamp(0.0, 1.0);
                                
                                print('LessonPlayerPage: Back button pressed - final progress: ${(finalProgress * 100).toStringAsFixed(1)}%');
                                
                                // Lesson should already be marked as viewed when video loaded
                                // But as a fallback, mark it if it wasn't marked yet
                                if (!_hasMarkedAsViewed) {
                                  print('LessonPlayerPage: Marking lesson ${widget.lessonId} as viewed on back (fallback)');
                                  _hasMarkedAsViewed = true;
                                  context.read<LessonBloc>().add(MarkLessonViewedEvent(lessonId: widget.lessonId));
                                }
                                
                                // Update parent callback
                                if (widget.onProgressUpdate != null) {
                                  widget.onProgressUpdate!(finalProgress);
                                }
                                
                                Navigator.pop(context, finalProgress);
                              } else {
                                Navigator.pop(context, _currentProgress);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
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
                        
                        SizedBox(height: Responsive.spacing(context, 24)),
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
      padding: Responsive.padding(context, all: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lesson Title
          Text(
            lesson.nameAr,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: Responsive.fontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 8)),
          // Lesson Meta Info
          Row(
            children: [
              if (lesson.videoDuration != null) ...[
                Container(
                  padding: Responsive.padding(context, horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(Responsive.radius(context, 4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time, size: Responsive.iconSize(context, 14), color: AppColors.primary),
                      SizedBox(width: Responsive.width(context, 4)),
                      Text(
                        lesson.videoDuration!,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: Responsive.fontSize(context, 12),
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: Responsive.width(context, 8)),
              ],
              if (lesson.viewed) ...[
                Container(
                  padding: Responsive.padding(context, horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(Responsive.radius(context, 4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: Responsive.iconSize(context, 14), color: AppColors.success),
                      SizedBox(width: Responsive.width(context, 4)),
                      Text(
                        'تمت المشاهدة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: Responsive.fontSize(context, 12),
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
      margin: Responsive.margin(context, horizontal: 16),
      padding: Responsive.padding(context, all: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
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
                  padding: Responsive.padding(context, all: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(Responsive.radius(context, 8)),
                  ),
                  child: Icon(Icons.school, size: Responsive.iconSize(context, 20), color: AppColors.primary),
                ),
                SizedBox(width: Responsive.width(context, 12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الدورة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: Responsive.fontSize(context, 11),
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        widget.course!.nameAr,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: Responsive.fontSize(context, 14),
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
              Padding(
                padding: Responsive.padding(context, vertical: 8),
                child: Divider(height: Responsive.height(context, 1)),
              ),
            ],
            Row(
              children: [
                Container(
                  padding: Responsive.padding(context, all: 8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(Responsive.radius(context, 8)),
                  ),
                  child: Icon(Icons.folder_outlined, size: Responsive.iconSize(context, 20), color: AppColors.warning),
                ),
                SizedBox(width: Responsive.width(context, 12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الفصل',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: Responsive.fontSize(context, 11),
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        widget.chapter!.nameAr,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: Responsive.fontSize(context, 14),
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
                  padding: Responsive.padding(context, horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
                  ),
                  child: Text(
                    '${widget.chapter!.lessons.length} دروس',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: Responsive.fontSize(context, 11),
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
            padding: Responsive.padding(context, all: 16),
            child: Row(
              children: [
                Icon(Icons.playlist_play, color: AppColors.primary, size: Responsive.iconSize(context, 24)),
                SizedBox(width: Responsive.width(context, 8)),
                Expanded(
                  child: Text(
                    'دروس الفصل',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: Responsive.fontSize(context, 16),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  _showLessonsList ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                  size: Responsive.iconSize(context, 24),
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
      margin: Responsive.margin(context, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: lessons.length,
        separatorBuilder: (_, __) => Divider(height: Responsive.height(context, 1), color: Colors.grey[200]),
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          final isCurrentLesson = lesson.id == currentLesson.id;

          return ListTile(
            onTap: isCurrentLesson
                ? null
                : () {
                    Navigator.of(context, rootNavigator: true).pushReplacement(
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
              width: Responsive.width(context, 32),
              height: Responsive.height(context, 32),
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
                    ? Icon(Icons.play_arrow, color: Colors.white, size: Responsive.iconSize(context, 18))
                    : lesson.viewed
                        ? Icon(Icons.check, color: AppColors.success, size: Responsive.iconSize(context, 16))
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: Responsive.fontSize(context, 12),
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
                fontSize: Responsive.fontSize(context, 14),
                fontWeight: isCurrentLesson ? FontWeight.bold : FontWeight.w500,
                color: isCurrentLesson ? AppColors.primary : AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: lesson.duration != null
                ? Text(
                    lesson.duration!,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: Responsive.fontSize(context, 12),
                      color: AppColors.textSecondary,
                    ),
                  )
                : null,
            trailing: isCurrentLesson
                ? Container(
                    padding: Responsive.padding(context, horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(Responsive.radius(context, 4)),
                    ),
                    child: Text(
                      'الآن',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: Responsive.fontSize(context, 11),
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Icon(Icons.chevron_left, color: AppColors.textSecondary, size: Responsive.iconSize(context, 20)),
          );
        },
      ),
    );
  }

  Widget _buildDescriptionSection(Lesson lesson) {
    return Padding(
      padding: Responsive.padding(context, all: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: Responsive.iconSize(context, 20)),
              SizedBox(width: Responsive.width(context, 8)),
              Text(
                'وصف الدرس',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: Responsive.fontSize(context, 16),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, 8)),
          Container(
            padding: Responsive.padding(context, all: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(Responsive.radius(context, 8)),
            ),
            child: Text(
              lesson.description!,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: Responsive.fontSize(context, 14),
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
          onPressed: () => Navigator.pop(context, _currentProgress),
        ),
        title: Text(
          lesson.nameAr,
          style: TextStyle(
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
            Icon(Icons.video_library_outlined, size: Responsive.iconSize(context, 80), color: Colors.grey[400]),
            SizedBox(height: Responsive.spacing(context, 16)),
            Text(
              'الفيديو غير متاح حالياً',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: Responsive.fontSize(context, 18),
                color: AppColors.textSecondary,
              ),
            ),
            if (lesson.videoStatus != null) ...[
              SizedBox(height: Responsive.spacing(context, 8)),
              Text(
                'الحالة: ${lesson.videoStatus}',
                style: TextStyle(fontFamily: 'Cairo', fontSize: Responsive.fontSize(context, 14), color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}



