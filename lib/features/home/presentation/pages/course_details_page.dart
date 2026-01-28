import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnify_lms/features/home/presentation/pages/main_navigation_page.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_background.dart';
import '../../../authentication/data/datasources/auth_local_datasource.dart';
import '../../../lessons/presentation/pages/lesson_player_page.dart';
import '../../../subscriptions/data/models/payment_model.dart';
import '../../../subscriptions/presentation/bloc/subscription_bloc.dart';
import '../../../subscriptions/presentation/bloc/subscription_event.dart';
import '../../../subscriptions/presentation/bloc/subscription_state.dart';
import '../../../certificates/presentation/bloc/certificate_bloc.dart';
import '../../../certificates/presentation/bloc/certificate_event.dart';
import '../../../certificates/presentation/bloc/certificate_state.dart';
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
  // Track viewed lessons locally (only lessons watched >90%)
  final Set<int> _viewedLessonIds = {};
  // Track lesson progress percentages (0.0 to 1.0)
  final Map<int, double> _lessonProgress = {};
  final TextEditingController _phoneController = TextEditingController();
  bool _isPaymentLoading = false;
  SubscriptionBloc? _subscriptionBloc;
  CertificateBloc? _certificateBloc;
  bool _isAuthenticated = false;
  bool _isCheckingAuth = true;
  bool _hasAttemptedCertificateGeneration = false; // Prevent multiple calls
  bool _hasCheckedInitialCertificate = false; // Track initial check

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
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final authLocalDataSource = sl<AuthLocalDataSource>();
    final token = await authLocalDataSource.getAccessToken();
    setState(() {
      _isAuthenticated = token != null && token.isNotEmpty;
      _isCheckingAuth = false;
    });
  }

  bool _isLessonViewed(int lessonId) {
    // Consider viewed if in viewed list (marked when video opens)
    final isInViewedList = _viewedLessonIds.contains(lessonId);
    print('CourseDetailsPage: _isLessonViewed - lessonId: $lessonId, inViewedList: $isInViewedList');
    return isInViewedList;
  }

  void _markLessonAsViewed(int lessonId) {
    if (lessonId > 0) {
      setState(() {
        _viewedLessonIds.add(lessonId);
      });
      // Check if all lessons are viewed and generate certificate if needed
      _checkAndGenerateCertificate();
    }
  }

  void _updateLessonProgress(int lessonId, double progress) {
    if (lessonId > 0) {
      print('CourseDetailsPage: _updateLessonProgress - lessonId: $lessonId, progress: ${(progress * 100).toStringAsFixed(1)}%');
      
      setState(() {
        _lessonProgress[lessonId] = progress;
        // If progress is 100% (1.0), it means lesson was marked as viewed
        if (progress >= 1.0 && !_viewedLessonIds.contains(lessonId)) {
          _viewedLessonIds.add(lessonId);
          print('CourseDetailsPage: Added lesson $lessonId to viewed list (progress: 100%)');
          // Check if all lessons are viewed and generate certificate if needed
          _checkAndGenerateCertificate();
        }
      });
    }
  }

  /// Check if all lessons in the course are viewed
  bool _areAllLessonsViewed() {
    // Get all lesson IDs from the course
    final allLessonIds = <int>{};
    for (final chapter in course.chapters) {
      for (final lesson in chapter.lessons) {
        if (lesson.id > 0) { // Only count valid lesson IDs
          allLessonIds.add(lesson.id);
        }
      }
    }
    
    // Check if all lessons are in the viewed list
    return allLessonIds.isNotEmpty && allLessonIds.every((id) => _viewedLessonIds.contains(id));
  }

  /// Check if certificate should be generated and call the API
  void _checkAndGenerateCertificate() {
    // Only generate if:
    // 1. User hasn't attempted generation before (prevent multiple calls)
    // 2. User doesn't already have a certificate (userHasCertificate is false)
    // 3. All lessons are viewed
    if (_hasAttemptedCertificateGeneration) {
      print('CourseDetailsPage: Certificate generation already attempted, skipping');
      return;
    }

    if (course.userHasCertificate) {
      print('CourseDetailsPage: User already has certificate, skipping generation');
      return;
    }

    if (!_areAllLessonsViewed()) {
      print('CourseDetailsPage: Not all lessons are viewed yet, skipping certificate generation');
      return;
    }

    // All conditions met - generate certificate
    print('CourseDetailsPage: All lessons viewed and no certificate yet, generating certificate...');
    _hasAttemptedCertificateGeneration = true;
    _certificateBloc?.add(GenerateCertificateEvent(courseId: course.id));
  }

  Course get course => widget.course;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<SubscriptionBloc>()),
        BlocProvider(create: (context) => sl<CertificateBloc>()),
      ],
      child: Builder(
        builder: (blocContext) {
          // Capture bloc references for use in dialogs
          _subscriptionBloc = blocContext.read<SubscriptionBloc>();
          _certificateBloc = blocContext.read<CertificateBloc>();
          
          // Check certificate generation on first build (if all lessons already viewed)
          if (!_hasCheckedInitialCertificate) {
            _hasCheckedInitialCertificate = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _checkAndGenerateCertificate();
              }
            });
          }

          return BlocListener<CertificateBloc, CertificateState>(
            listener: (context, state) {
              if (state is CertificateGenerated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إنشاء الشهادة بنجاح!'),
                    backgroundColor: AppColors.success,
                    duration: Duration(seconds: 3),
                  ),
                );
              } else if (state is CertificateError) {
                // Reset flag on error so user can retry
                _hasAttemptedCertificateGeneration = false;
                // Error message removed - silently handle the error
              }
            },
            child: BlocListener<SubscriptionBloc, SubscriptionState>(
              listener: (context, state) {
                if (state is PaymentProcessing) {
                  setState(() => _isPaymentLoading = true);
                } else if (state is PaymentInitiated) {
                  setState(() => _isPaymentLoading = false);
                  _showPaymentSuccessDialog(state.message);
                } else if (state is PaymentFailed) {
                  setState(() => _isPaymentLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            child: Scaffold(
              backgroundColor: AppColors.white,
              appBar: CustomAppBar(title: course.nameAr),
              body: Stack(
                  children:[
                    const CustomBackground(),

                    SingleChildScrollView(
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
                  ]),
            ),
            ),
          );
        },
      ),
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    // Parse what_you_will_learn by splitting on "/"
    List<String> learnItems = [];
    if (course.whatYouWillLearn != null && course.whatYouWillLearn!.isNotEmpty) {
      learnItems = course.whatYouWillLearn!
          .split('/')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            course.about ??
                'مقدمة ممتعة وشاملة لتعلم، مع التركيز على الأساسيات بطريقة تفاعلية ومبتكرة.',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: Colors.black,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          
          // What You Will Learn Section
          if (learnItems.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildWhatYouWillLearnList(learnItems),
          ],
          
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoChip(Icons.workspace_premium_outlined, 'شهادة'),
              _buildInfoChip(
                  Icons.people_outline, course.specialty?.nameAr ?? '4-13 سنة'),
              _buildInfoChip(Icons.access_time_rounded, _getSimpleDuration()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhatYouWillLearnList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ما سوف تتعلمه',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < items.length - 1 ? 8 : 0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                // Bullet point
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 6),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                // Text
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: Colors.black,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
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
      return minutes > 0
          ? '$hours:${minutes.toString().padLeft(2, '0')} ساعة'
          : '$hours ساعات';
    }
    return '$minutes دقيقة';
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.black,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
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
      padding: Responsive.padding(
        context,
        horizontal: 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title
          Text(
            'دروس الدورة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: Responsive.fontSize(context, 20),
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),

          SizedBox(width: context.rs(8)),

          const Spacer(),

          // Free course banner
          if (_isFreeCourse && !course.hasAccess)
            GestureDetector(
                onTap: () {
                  if (!_isAuthenticated) {
                    Navigator.of(context, rootNavigator: true).pushNamed(
                      AppRouter.login,
                      arguments: {'returnTo': 'subscriptions'},
                    );
                  } else {
                    // يرجع لصفحة الاشتراكات + الـ bottom nav ظاهر
                    context.mainNavigation?.switchToTab(2);
                  }
                },
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: context.isTablet
                      ? context.rw(260)
                      : context.rw(210),
                ),
                padding: Responsive.padding(
                  context,
                  horizontal: 24,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE4FF),
                  borderRadius: BorderRadius.circular(
                    Responsive.radius(context, 22),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الكورس مجاني سجل دخولك',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: Responsive.fontSize(context, 12),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: context.rs(4)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'للمشاهدة ',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: Responsive.fontSize(context, 12),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'من هنا',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: Responsive.fontSize(context, 14),
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
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
    // Check if there are any lessons at all
    final hasAnyLessons = course.chapters.any((chapter) => chapter.lessons.isNotEmpty);
    
    if (!hasAnyLessons) {
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

    // Find the first lesson in the entire course (for preview)
    Lesson? firstLessonInCourse;
    if (course.chapters.isNotEmpty && course.chapters.first.lessons.isNotEmpty) {
      firstLessonInCourse = course.chapters.first.lessons.first;
    }

    // Build chapters with their lessons
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: course.chapters.asMap().entries.map((entry) {
          final chapterIndex = entry.key;
          final chapter = entry.value;
          
          if (chapter.lessons.isEmpty) {
            return const SizedBox.shrink();
          }
          
          return _ChapterSection(
            chapter: chapter,
            chapterIndex: chapterIndex,
            course: course,
            firstLessonInCourse: firstLessonInCourse,
            isLessonViewed: _isLessonViewed,
            onLessonTap: (lesson) => _onLessonTap(context, lesson, chapter),
          );
        }).toList(),
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
                      color:
                      _isFreeCourse ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Action Button
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: (course.soon || _isPaymentLoading)
                    ? null
                    : () => _onEnrollPressed(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  course.hasAccess ? AppColors.success : AppColors.primary,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isPaymentLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Text(
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
      Navigator.of(context, rootNavigator: true).push(
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

  void _onLessonTap(
      BuildContext context, Lesson lesson, Chapter chapter) async {
    // Mark lesson as viewed immediately when opening (will be confirmed when video loads)
    _markLessonAsViewed(lesson.id);
    
    // If user has access (subscribed), allow all lessons
    if (course.hasAccess) {
      final result = await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => LessonPlayerPage(
            lessonId: lesson.id,
            lesson: lesson,
            course: course,
            chapter: chapter,
            onProgressUpdate: (progress) {
              // Update progress in real-time
              _updateLessonProgress(lesson.id, progress);
            },
          ),
        ),
      );
      
      // Update progress from result if available (final progress when leaving)
      if (result != null && result is double) {
        _updateLessonProgress(lesson.id, result);
      }
      
      // Force UI update to refresh badges
      if (mounted) {
        setState(() {});
      }
      return;
    }

    // For non-subscribers, only allow first lesson preview
    final isFirstLesson = course.chapters.isNotEmpty &&
        course.chapters.first.lessons.isNotEmpty &&
        course.chapters.first.lessons.first.id == lesson.id;

    if (!isFirstLesson) {
      // Locked lesson - handle based on course type and login status
      await _handleLockedLessonTap(context);
      return;
    }

    final result = await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => LessonPlayerPage(
          lessonId: lesson.id,
          lesson: lesson,
          course: course,
          chapter: chapter,
          onProgressUpdate: (progress) {
            // Update progress in real-time
            _updateLessonProgress(lesson.id, progress);
          },
        ),
      ),
    );
    
    // Update progress from result if available (final progress when leaving)
    if (result != null && result is double) {
      _updateLessonProgress(lesson.id, result);
    }
    
    // Force UI update to refresh badges
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleLockedLessonTap(BuildContext context) async {
    final authLocalDataSource = sl<AuthLocalDataSource>();
    final token = await authLocalDataSource.getAccessToken();

    final isAuthenticated = token != null && token.isNotEmpty;

    if (_isFreeCourse) {
      // Free course - show subscription message
      if (!isAuthenticated) {
        // Not logged in - show message and redirect to login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('الكورس مجاني! سجل دخولك للمشاهدة'),
            backgroundColor: AppColors.primary,
            action: SnackBarAction(
              label: 'تسجيل الدخول',
              textColor: Colors.white,
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/login',
                  arguments: {'returnTo': 'course', 'courseId': course.id},
                );
                // After login, user will find the course unlocked
                if (result == true && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تسجيل الدخول! الكورس متاح الآن'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
            ),
          ),
        );
      } else {
        // Logged in but not subscribed - show subscription message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('الكورس مجاني! اشترك من هنا للمشاهدة'),
            backgroundColor: AppColors.primary,
            action: SnackBarAction(
              label: 'الاشتراك',
              textColor: Colors.white,
              onPressed: () {
                // Navigate to subscriptions page
                Navigator.pushNamed(context, '/subscriptions');
              },
            ),
          ),
        );
      }
    } else {
      // Paid course - show subscription required message
      if (!isAuthenticated) {
        // Not logged in - go to login first
        final result = await Navigator.pushNamed(
          context,
          '/login',
          arguments: {'returnTo': 'payment', 'courseId': course.id},
        );

        if (result == true && mounted) {
          // After login, show phone dialog for payment
          _showPhoneInputDialog();
        }
      } else {
        // Logged in - go directly to payment
        _showPhoneInputDialog();
      }
    }
  }

  void _onEnrollPressed(BuildContext context) async {
    if (course.hasAccess) {
      // User has access - start learning
      if (course.chapters.isNotEmpty &&
          course.chapters.first.lessons.isNotEmpty) {
        final firstChapter = course.chapters.first;
        final firstLesson = firstChapter.lessons.first;
        final result = await Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => LessonPlayerPage(
              lessonId: firstLesson.id,
              lesson: firstLesson,
              course: course,
              chapter: firstChapter,
              onProgressUpdate: (progress) => _updateLessonProgress(firstLesson.id, progress),
            ),
          ),
        );
        // Update progress from result if available
        if (result != null && result is double) {
          _updateLessonProgress(firstLesson.id, result);
        }
      }
    } else if (_isFreeCourse) {
      // Free course - redirect to login
      Navigator.pushNamed(context, '/login');
    } else {
      // Paid course - show phone dialog for payment
      _showPhoneInputDialog();
    }
  }

  void _showPhoneInputDialog() {
    _phoneController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'شراء الكورس',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${course.nameAr}\nالسعر: ${course.price} جم',
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                hintText: '+201XXXXXXXXX',
                labelText: 'رقم الهاتف',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () {
              final phone = _phoneController.text.trim();
              if (phone.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('يرجى إدخال رقم الهاتف'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(ctx);
              _processCoursePurchase(phone);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('شراء',
                style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _processCoursePurchase(String phone) {
    _subscriptionBloc?.add(
      ProcessPaymentEvent(
        service: PaymentService.iap,
        currency: 'EGP',
        courseId: course.id,
        phone: phone,
      ),
    );
  }

  void _showPaymentSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 64,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'تم الشراء بنجاح!',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'يمكنك الآن مشاهدة جميع الدروس',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                // Update the course to show access and refresh UI
                _onPaymentSuccess();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'ابدأ المشاهدة',
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
      ),
    );
  }

  void _onPaymentSuccess() {
    // Update the course to show access (simulated - in real app would refetch from API)
    // For now, we'll just rebuild the widget with hasAccess = true
    setState(() {
      // The course object will be updated when the page is rebuilt
      // We trigger a rebuild to show the unlocked state
    });

    // Show snackbar confirming access
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تفعيل الاشتراك! جميع الدروس متاحة الآن'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 3),
      ),
    );
  }
}

class _LessonWithChapter {
  final Lesson lesson;
  final Chapter chapter;

  _LessonWithChapter({required this.lesson, required this.chapter});
}

/// Widget to display a chapter with its lessons
class _ChapterSection extends StatelessWidget {
  final Chapter chapter;
  final int chapterIndex;
  final Course course;
  final Lesson? firstLessonInCourse;
  final bool Function(int lessonId) isLessonViewed;
  final void Function(Lesson lesson) onLessonTap;

  const _ChapterSection({
    required this.chapter,
    required this.chapterIndex,
    required this.course,
    required this.firstLessonInCourse,
    required this.isLessonViewed,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chapter Title
        Padding(
          padding: EdgeInsets.only(
            bottom: 16,
            top: chapterIndex > 0 ? 24 : 8, // More space if not first chapter
          ),
          child: Text(
            ' ${chapter.nameAr}',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: Responsive.fontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.5
            ),
          ),
        ),
        // Lessons Grid for this chapter
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: chapter.lessons.length,
          itemBuilder: (context, index) {
            final lesson = chapter.lessons[index];
            
            // First lesson in the entire course is always available for preview
            final isFirstLessonInCourse = firstLessonInCourse != null && 
                firstLessonInCourse!.id == lesson.id;
            
            // If user has access, all lessons are available
            final isAvailable = course.hasAccess || isFirstLessonInCourse;
            final isViewed = isLessonViewed(lesson.id);
            
            return _LessonCard(
              key: ValueKey('lesson_${lesson.id}_viewed_$isViewed'),
              lesson: lesson,
              isAvailable: isAvailable,
              hasAccess: course.hasAccess,
              isViewed: isViewed,
              onTap: () => onLessonTap(lesson),
            );
          },
        ),
      ],
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  final bool isAvailable;
  final bool hasAccess; // User is subscribed
  final bool isViewed; // Lesson has been viewed
  final VoidCallback onTap;

  const _LessonCard({
    super.key,
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
    // Show lock if user doesn't have access (regardless of course being free or paid)
    final bool shouldShowLock = !canAccess;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: GestureDetector(
        onTap: canAccess ? onTap : null,
        child: Opacity(
          opacity: canAccess ? 1.0 : 0.7,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  // Black shadow for locked lessons, primary color for accessible ones
                  color: canAccess
                      ? AppColors.primary.withOpacity(0.25)
                      : Colors.grey.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thumbnail
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(22)),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: _buildLessonThumbnail(),
                      ),
                    ),
                    // Lock overlay for unavailable lessons (when user doesn't have access)
                    if (shouldShowLock)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(22)),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock_outline_rounded,
                                color: Colors.white,
                                size: 32,
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
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(
                                0xFF9B59D0), // Purple for available (matching image)
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            isViewed ? 'تم المشاهدة' : 'متاح',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
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
                flex: 1,
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          lesson.nameAr,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: (hasAccess || isAvailable)
                                ? AppColors.textPrimary
                                : Colors.grey[500],
                            height: 1.4,
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      if (lesson.duration != null ||
                          lesson.videoDuration != null)
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            _formatDuration(
                                lesson.videoDuration ?? lesson.duration!),
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: (hasAccess || isAvailable)
                                  ? AppColors.textPrimary
                                  : Colors.grey[500],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
          size: 42,
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
    if (name.contains('حرف') ||
        name.contains('أبجد') ||
        name.contains('حروف')) {
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
