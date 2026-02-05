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
import '../../../../core/widgets/bunny_video_player.dart';
import '../../../authentication/data/datasources/auth_local_datasource.dart';
import '../../../lessons/presentation/pages/lesson_player_page.dart';
import '../../../subscriptions/data/models/payment_model.dart';
import '../../../subscriptions/presentation/bloc/subscription_bloc.dart';
import '../../../subscriptions/presentation/bloc/subscription_event.dart';
import '../../../subscriptions/presentation/bloc/subscription_state.dart';
import '../../../certificates/presentation/bloc/certificate_bloc.dart';
import '../../../certificates/presentation/bloc/certificate_event.dart';
import '../../../certificates/presentation/bloc/certificate_state.dart';
import '../../../reels/presentation/pages/reels_feed_page.dart';
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

class _CourseDetailsPageState extends State<CourseDetailsPage> with RouteAware {
  final Set<int> _viewedLessonIds = {};
  final Map<int, double> _lessonProgress = {};
  final TextEditingController _phoneController = TextEditingController();
  bool _isPaymentLoading = false;
  SubscriptionBloc? _subscriptionBloc;
  CertificateBloc? _certificateBloc;
  bool _isAuthenticated = false;
  bool _isCheckingAuth = true;
  bool _hasAttemptedCertificateGeneration = false;
  bool _hasCheckedInitialCertificate = false;
  bool _isVideoLoaded = false;
  bool _hasAccess = false;

  @override
  void initState() {
    super.initState();
    for (final chapter in widget.course.chapters) {
      for (final lesson in chapter.lessons) {
        if (lesson.viewed) {
          _viewedLessonIds.add(lesson.id);
        }
      }
    }
    _isVideoLoaded = false;
    _hasAccess = widget.course.hasAccess;
    _checkAuthentication();
  }
  
  @override
  void didUpdateWidget(CourseDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.course.introBunnyUrl != widget.course.introBunnyUrl) {
      _isVideoLoaded = false;
    }
    if (oldWidget.course.hasAccess != widget.course.hasAccess) {
      setState(() {
        _hasAccess = widget.course.hasAccess;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _phoneController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _checkAuthentication();
    setState(() {
      _hasAccess = widget.course.hasAccess;
    });
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
    final isInViewedList = _viewedLessonIds.contains(lessonId);
    print('CourseDetailsPage: _isLessonViewed - lessonId: $lessonId, inViewedList: $isInViewedList');
    return isInViewedList;
  }

  void _markLessonAsViewed(int lessonId) {
    if (lessonId > 0) {
      setState(() {
        _viewedLessonIds.add(lessonId);
      });
      _checkAndGenerateCertificate();
    }
  }

  void _updateLessonProgress(int lessonId, double progress) {
    if (lessonId > 0) {
      print('CourseDetailsPage: _updateLessonProgress - lessonId: $lessonId, progress: ${(progress * 100).toStringAsFixed(1)}%');

      setState(() {
        _lessonProgress[lessonId] = progress;
        if (progress >= 1.0 && !_viewedLessonIds.contains(lessonId)) {
          _viewedLessonIds.add(lessonId);
          print('CourseDetailsPage: Added lesson $lessonId to viewed list (progress: 100%)');
          _checkAndGenerateCertificate();
        }
      });
    }
  }

  bool _areAllLessonsViewed() {
    final allLessonIds = <int>{};
    for (final chapter in course.chapters) {
      for (final lesson in chapter.lessons) {
        if (lesson.id > 0) {
          allLessonIds.add(lesson.id);
        }
      }
    }

    return allLessonIds.isNotEmpty && allLessonIds.every((id) => _viewedLessonIds.contains(id));
  }

  void _checkAndGenerateCertificate() {
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

    print('CourseDetailsPage: All lessons viewed and no certificate yet, generating certificate...');
    _hasAttemptedCertificateGeneration = true;
    _certificateBloc?.add(GenerateCertificateEvent(courseId: course.id));
  }

  Course get course => widget.course;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<SubscriptionBloc>()),
        BlocProvider(create: (context) => sl<CertificateBloc>()),
      ],
      child: Builder(
        builder: (blocContext) {
          _subscriptionBloc = blocContext.read<SubscriptionBloc>();
          _certificateBloc = blocContext.read<CertificateBloc>();

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
                _hasAttemptedCertificateGeneration = false;
              }
            },
            child: BlocListener<SubscriptionBloc, SubscriptionState>(
              listener: (context, state) {
                if (state is PaymentProcessing) {
                  setState(() => _isPaymentLoading = true);
                } else if (state is PaymentInitiated) {
                  print('CourseDetailsPage: PaymentInitiated - updating _hasAccess to true');
                  setState(() {
                    _isPaymentLoading = false;
                    _hasAccess = true;
                  });
                  print('CourseDetailsPage: _hasAccess is now: $_hasAccess');
                  _showPaymentSuccessDialog(state.message);
                } else if (state is PaymentCompleted) {
                  print('CourseDetailsPage: PaymentCompleted - updating _hasAccess to true');
                  setState(() {
                    _isPaymentLoading = false;
                    _hasAccess = true;
                  });
                  print('CourseDetailsPage: _hasAccess is now: $_hasAccess');
                  _showPaymentSuccessDialog(state.message);
                } else if (state is PaymentCheckoutReady) {
                  setState(() => _isPaymentLoading = false);
                } else if (state is IapVerificationSuccess) {
                  print('CourseDetailsPage: IapVerificationSuccess - updating _hasAccess to true');
                  setState(() {
                    _isPaymentLoading = false;
                    _hasAccess = true;
                  });
                  print('CourseDetailsPage: _hasAccess is now: $_hasAccess');
                  _showPaymentSuccessDialog('تم تفعيل اشتراكك بنجاح');
                } else if (state is PaymentFailed) {
                  setState(() => _isPaymentLoading = false);

                  final errorMessage = state.message.toLowerCase();
                  print('CourseDetailsPage: PaymentFailed - error message: $errorMessage');
                  if (errorMessage.contains('already own') || 
                      errorMessage.contains('تملك') ||
                      errorMessage.contains('يمتلك')) {
                    print('CourseDetailsPage: User already owns course - updating _hasAccess to true');
                    setState(() {
                      _hasAccess = true;
                    });
                    print('CourseDetailsPage: _hasAccess is now: $_hasAccess');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('أنت تمتلك هذا الكورس بالفعل!'),
                        backgroundColor: AppColors.success,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else if (state is IapVerificationFailure) {
                  setState(() => _isPaymentLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is SubscriptionLoading ||
                    state is SubscriptionsLoaded ||
                    state is SubscriptionError ||
                    state is SubscriptionInitial) {
                  // في أي حالة عامة أخرى نضمن إيقاف الـ loading
                  if (_isPaymentLoading) {
                    setState(() => _isPaymentLoading = false);
                  }
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
                          _buildCourseThumbnail(context),

                          _buildCourseInfoCard(),

                          SizedBox(height: Responsive.spacing(context, 24)),

                          _buildLessonsTitleSection(context),

                          SizedBox(height: Responsive.spacing(context, 16)),

                          _buildLessonsGrid(context),

                          SizedBox(height: Responsive.spacing(context, 100)),
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
    final bool isTablet = Responsive.isTablet(context);
    final double thumbRadius =
        isTablet ? 26.0 : Responsive.radius(context, 20);

    if (course.introBunnyUrl != null && course.introBunnyUrl!.isNotEmpty) {
      return Container(
        height: Responsive.height(context, 200),
        width: double.infinity,
        margin: Responsive.margin(context, all: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(thumbRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: Responsive.width(context, 10),
              offset: Offset(0, Responsive.height(context, 4)),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(thumbRadius),
          child: GestureDetector(
            onTap: () => _playIntroVideo(context),
            child: Stack(
              children: [
                if (!_isVideoLoaded)
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: _buildThumbnailImage(),
                  ),
                Positioned.fill(
                  child: Opacity(
                    opacity: _isVideoLoaded ? 1.0 : 0.0,
                    child: BunnyVideoPlayer(
                      videoUrl: course.introBunnyUrl!,
                      onVideoLoaded: () {
                        if (mounted) {
                          setState(() {
                            _isVideoLoaded = true;
                          });
                        }
                      },
                    ),
                  ),
                ),
                if (!_isVideoLoaded)
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: Responsive.width(context, 64),
                        height: Responsive.width(context, 64),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: Responsive.width(context, 16),
                              offset: Offset(0, Responsive.height(context, 6)),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: Responsive.iconSize(context, 36),
                        ),
                      ),
                    ),
                  ),
                if (course.soon)
                  Positioned(
                    top: Responsive.height(context, 12),
                    right: Responsive.width(context, 12),
                    child: Container(
                      padding: Responsive.padding(context, horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(Responsive.radius(context, 8)),
                      ),
                      child: Text(
                        'قريباً',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: Responsive.fontSize(context, 12),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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

    return GestureDetector(
      onTap: () => _playIntroVideo(context),

      child: Container(
        height: Responsive.height(context, 200),
        width: double.infinity,
        margin: Responsive.margin(context, all: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(thumbRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: Responsive.width(context, 10),
              offset: Offset(0, Responsive.height(context, 4)),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(thumbRadius),
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: _buildThumbnailImage(),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Container(
                  width: Responsive.width(context, 64),
                  height: Responsive.width(context, 64),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: Responsive.width(context, 16),
                        offset: Offset(0, Responsive.height(context, 6)),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: Responsive.iconSize(context, 36),
                  ),
                ),
              ),
            ),
            if (course.soon)
              Positioned(
                top: Responsive.height(context, 12),
                right: Responsive.width(context, 12),
                child: Container(
                  padding: Responsive.padding(context, horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(Responsive.radius(context, 8)),
                  ),
                  child: Text(
                    'قريباً',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: Responsive.fontSize(context, 12),
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
          size: Responsive.iconSize(context, 60),
          color: Colors.white.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildCourseInfoCard() {
    List<String> learnItems = [];
    if (course.whatYouWillLearn != null && course.whatYouWillLearn!.isNotEmpty) {
      learnItems = course.whatYouWillLearn!
          .split('/')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    final bool isTablet = Responsive.isTablet(context);
    final double infoRadius =
        isTablet ? 26.0 : Responsive.radius(context, 20);

    return Container(
      margin:  isTablet ? Responsive.margin(context, horizontal: 10): Responsive.margin(context, horizontal: 16),
      padding: Responsive.padding(context, all: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryCard,
        borderRadius: BorderRadius.circular(infoRadius),
      ),
      child: Column(
        children: [
          Text(
            course.about ??
                'مقدمة ممتعة وشاملة لتعلم، مع التركيز على الأساسيات بطريقة تفاعلية ومبتكرة.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: Responsive.fontSize(context, 14),
              color: Colors.black,
              height: 1.6,
            ),
            textAlign: TextAlign.start,
          ),

          if (learnItems.isNotEmpty) ...[
            SizedBox(height: Responsive.spacing(context, 20)),
            _buildWhatYouWillLearnList(learnItems),
          ],
          
          SizedBox(height: Responsive.spacing(context, 20)),
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
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: Responsive.fontSize(context, 16),
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: Responsive.spacing(context, 12)),
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
                Container(
                  margin: Responsive.margin(context, left: 8, top: 6),
                  width: Responsive.width(context, 6),
                  height: Responsive.width(context, 6),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: Responsive.fontSize(context, 14),
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
          size: Responsive.iconSize(context, 14),
        ),
        SizedBox(width: Responsive.width(context, 4)),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: Responsive.fontSize(context, 12),
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  bool get _isFreeCourse {
    if (course.price == null || course.price!.isEmpty) {
      return true;
    }
    final price = course.price!.trim();
    return price == '0' ||
        price == '0.0' ||
        price == '0.00' ||
        price == '0.000' ||
        double.tryParse(price) == 0.0;
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
          Text(
            'دروس الدورة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: Responsive.fontSize(context, 14),
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),

          SizedBox(width: context.rs(6)),

          const Spacer(),

          if (_isFreeCourse)
            if (!_isAuthenticated)
              GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true).pushNamed(
                    AppRouter.login,
                    arguments: {'returnTo': 'course', 'courseId': course.id},
                  );
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
            )
            else if (!_hasAccess)
              ElevatedButton(
                onPressed: _isPaymentLoading
                    ? null
                    : () => _onEnrollFreeCourse(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEDE4FF),
                  disabledBackgroundColor: Colors.grey[300],
                  padding: Responsive.padding(context, horizontal: 20, vertical: 12),
                  elevation: 2,
                  shadowColor: AppColors.primary.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Responsive.radius(context, 22)),
                  ),
                ),
                child: _isPaymentLoading
                    ? SizedBox(
                  height: Responsive.height(context, 16),
                  width: Responsive.width(context, 16),
                  child: CircularProgressIndicator(
                    strokeWidth: Responsive.width(context, 2),
                    color: AppColors.primary,
                  ),
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'انضم مجانًا',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: Responsive.fontSize(context, 14),
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(width: Responsive.width(context, 8)),
                    Icon(
                      Icons.lock_open_rounded,
                      size: Responsive.iconSize(context, 18),
                      color: AppColors.black,
                    ),

                  ],
                ),
              ),        ],
      ),
    );
  }

  Widget _buildLessonsGrid(BuildContext context) {
    final hasAnyLessons = course.chapters.any((chapter) => chapter.lessons.isNotEmpty);
    
    if (!hasAnyLessons) {
      return Padding(
        padding: Responsive.padding(context, all: 24),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.menu_book_outlined,
                size: Responsive.iconSize(context, 48),
                color: Colors.grey[400],
              ),
              SizedBox(height: Responsive.spacing(context, 12)),
              Text(
                'لا يوجد دروس متاحة حالياً',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: Responsive.fontSize(context, 16),
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    Lesson? firstLessonInCourse;
    if (course.chapters.isNotEmpty && course.chapters.first.lessons.isNotEmpty) {
      firstLessonInCourse = course.chapters.first.lessons.first;
    }

    return Padding(
      padding: Responsive.padding(context, horizontal: 16),
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
            isFreeCourse: _isFreeCourse,
            isAuthenticated: _isAuthenticated,
            hasAccess: _hasAccess,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    String buttonText;
    if (course.soon) {
      buttonText = 'قريباً';
    } else if (_hasAccess) {
      buttonText = 'ابدأ التعلم';
    } else if (_isFreeCourse) {
      buttonText = 'سجل للمشاهدة مجاناً';
    } else {
      buttonText = 'اشترك الآن';
    }

    return Container(
      padding: Responsive.padding(context, all: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: Responsive.width(context, 10),
            offset: Offset(0, -Responsive.height(context, 4)),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (course.hasDiscount && !_isFreeCourse)
                    Text(
                      '${course.priceBeforeDiscount} جم',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: Responsive.fontSize(context, 12),
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Text(
                    _isFreeCourse ? 'مجاني' : '${course.price} جم',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: Responsive.fontSize(context, 20),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: (course.soon || _isPaymentLoading)
                    ? null
                    : () => _onEnrollPressed(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: Responsive.padding(context, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
                  ),
                ),
                child: _isPaymentLoading
                    ? SizedBox(
                  height: Responsive.height(context, 20),
                  width: Responsive.width(context, 20),
                  child: CircularProgressIndicator(
                    strokeWidth: Responsive.width(context, 2),
                    color: Colors.white,
                  ),
                )
                    : Text(
                  buttonText,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: Responsive.fontSize(context, 16),
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
    _markLessonAsViewed(lesson.id);

    final hasFullAccess = _isFreeCourse
        ? (_hasAccess || _isAuthenticated)
        : _hasAccess;
    
    if (hasFullAccess) {
      final result = await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => LessonPlayerPage(
            lessonId: lesson.id,
            lesson: lesson,
            course: course,
            chapter: chapter,
            onProgressUpdate: (progress) {
              _updateLessonProgress(lesson.id, progress);
            },
          ),
        ),
      );

      if (result != null && result is double) {
        _updateLessonProgress(lesson.id, result);
      }

      if (mounted) {
        setState(() {});
      }
      return;
    }

    if (!_isFreeCourse && !_hasAccess) {
      await _handleLockedLessonTap(context);
      return;
    }

    final isFirstLesson = _isFreeCourse &&
        course.chapters.isNotEmpty &&
        course.chapters.first.lessons.isNotEmpty &&
        course.chapters.first.lessons.first.id == lesson.id;

    if (!hasFullAccess && !isFirstLesson) {
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
            _updateLessonProgress(lesson.id, progress);
          },
        ),
      ),
    );

    if (result != null && result is double) {
      _updateLessonProgress(lesson.id, result);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleLockedLessonTap(BuildContext context) async {
    final authLocalDataSource = sl<AuthLocalDataSource>();
    final token = await authLocalDataSource.getAccessToken();

    final isAuthenticated = token != null && token.isNotEmpty;

    if (_isFreeCourse) {
      if (!isAuthenticated) {
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
                if (result == true && mounted) {
                  await _checkAuthentication();
                  if (mounted) {
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تسجيل الدخول! الكورس متاح الآن'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                }
              },
            ),
          ),
        );
      }
    } else {
      if (!isAuthenticated) {
        final result = await Navigator.pushNamed(
          context,
          '/login',
          arguments: {'returnTo': 'payment', 'courseId': course.id},
        );

        if (result == true && mounted) {
          _showPhoneInputDialog();
        }
      } else {
        _showPhoneInputDialog();
      }
    }
  }

  void _onEnrollFreeCourse(BuildContext context) async {
    if (!_isAuthenticated) {
      final result = await Navigator.pushNamed(
        context,
        '/login',
        arguments: {'returnTo': 'course', 'courseId': course.id},
      );
      if (result == true && mounted) {
        await _checkAuthentication();
        if (mounted) {
          setState(() {});
        }
      }
      return;
    }

    _showPhoneInputDialog();
  }

  void _onEnrollPressed(BuildContext context) async {
    final hasFullAccess = _isFreeCourse
        ? (_hasAccess || _isAuthenticated)
        : _hasAccess;
    
    if (hasFullAccess) {
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
        if (result != null && result is double) {
          _updateLessonProgress(firstLesson.id, result);
        }
      }
    } else if (_isFreeCourse) {
      final result = await Navigator.pushNamed(
        context,
        '/login',
        arguments: {'returnTo': 'course', 'courseId': course.id},
      );
      if (result == true && mounted) {
        await _checkAuthentication();
        if (mounted) {
          setState(() {});
        }
      }
    } else {
      _showPhoneInputDialog();
    }
  }

  void _showPhoneInputDialog() {
    final isFree = _isFreeCourse;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.isTablet(context) ? 500 : double.infinity,
            maxHeight: Responsive.isTablet(context) ? 600 : double.infinity,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                  padding: Responsive.padding(
                    context,
                    all: Responsive.isTablet(context) ? 20 : 24,
                  ),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  gradient: isFree
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryCard,
                            AppColors.primary.withOpacity(0.2),
                          ],
                        )
                      : null,
                  color: isFree ? null : AppColors.primaryCard,
                ),
                child: Column(
                  children: [
                    if (isFree)
                      Container(
                        padding: Responsive.padding(context, all: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.school_outlined,
                          size: Responsive.iconSize(context, Responsive.isTablet(context) ? 32 : 40),
                          color: AppColors.primary,
                        ),
                      )
                    else
                      Container(
                        padding: Responsive.padding(context, all: Responsive.isTablet(context) ? 10 : 12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shopping_cart_outlined,
                          size: Responsive.iconSize(context, Responsive.isTablet(context) ? 32 : 40),
                          color: AppColors.primary,
                        ),
                      ),
                    SizedBox(height: Responsive.spacing(context, Responsive.isTablet(context) ? 12 : 16)),
                    Text(
                      isFree ? 'انضمام مجاني' : 'شراء الكورس',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: Responsive.fontSize(context, Responsive.isTablet(context) ? 18 : 20),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              Flexible(
                child: SingleChildScrollView(
                  padding: Responsive.padding(
                    context,
                    all: Responsive.isTablet(context) ? 20 : 24,
                  ),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      course.nameAr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                          fontSize: Responsive.fontSize(context, Responsive.isTablet(context) ? 16 : 18),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                      SizedBox(height: Responsive.spacing(context, Responsive.isTablet(context) ? 12 : 16)),

                    if (isFree)
                      Container(
                        padding: Responsive.padding(
                          context,
                          horizontal: Responsive.isTablet(context) ? 16 : 20,
                          vertical: Responsive.isTablet(context) ? 8 : 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: Responsive.iconSize(context, Responsive.isTablet(context) ? 18 : 20),
                              color: AppColors.primary,
                            ),
                            SizedBox(width: Responsive.width(context, 8)),
                            Text(
                              'مجاني تماماً',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: Responsive.fontSize(context, Responsive.isTablet(context) ? 14 : 16),
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: Responsive.padding(
                          context,
                          horizontal: Responsive.isTablet(context) ? 16 : 20,
                          vertical: Responsive.isTablet(context) ? 10 : 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryCard,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.attach_money,
                              size: Responsive.iconSize(context, Responsive.isTablet(context) ? 18 : 20),
                              color: AppColors.primary,
                            ),
                            SizedBox(width: Responsive.width(context, 8)),
                            Text(
                              '${course.price} جم',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: Responsive.fontSize(context, Responsive.isTablet(context) ? 16 : 18),
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: Responsive.spacing(context, Responsive.isTablet(context) ? 16 : 20)),

                    Text(
                      isFree
                          ? 'انضم الآن وابدأ التعلم مجاناً!'
                          : 'اكمل عملية الشراء للوصول إلى محتوى الكورس',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: Responsive.fontSize(context, Responsive.isTablet(context) ? 13 : 14),
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: Responsive.spacing(context, Responsive.isTablet(context) ? 20 : 24)),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              padding: Responsive.padding(
                                context,
                                vertical: Responsive.isTablet(context) ? 12 : 14,
                              ),
                              side: BorderSide(
                                color: AppColors.greyLight,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'إلغاء',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: Responsive.fontSize(context, Responsive.isTablet(context) ? 14 : 16),
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: Responsive.width(context, 12)),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _processCoursePurchase('');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: Responsive.padding(
                                context,
                                vertical: Responsive.isTablet(context) ? 12 : 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isFree)
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: Responsive.iconSize(context, Responsive.isTablet(context) ? 18 : 20),
                                    color: Colors.white,
                                  )
                                else
                                  Icon(
                                    Icons.shopping_cart,
                                    size: Responsive.iconSize(context, Responsive.isTablet(context) ? 18 : 20),
                                    color: Colors.white,
                                  ),
                                SizedBox(width: Responsive.width(context, 8)),
                                Text(
                                  isFree ? 'انضم الآن' : 'شراء',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: Responsive.fontSize(context, Responsive.isTablet(context) ? 14 : 16),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
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
          ),
        ),
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
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 64,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'تم الانضمام بنجاح!',
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
                color: AppColors.primary,
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
    if (!_hasAccess) {
      setState(() {
        _hasAccess = true;
      });
    }

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

class _ChapterSection extends StatelessWidget {
  final Chapter chapter;
  final int chapterIndex;
  final Course course;
  final Lesson? firstLessonInCourse;
  final bool Function(int lessonId) isLessonViewed;
  final void Function(Lesson lesson) onLessonTap;
  final bool isFreeCourse;
  final bool isAuthenticated;
  final bool hasAccess;

  const _ChapterSection({
    required this.chapter,
    required this.chapterIndex,
    required this.course,
    required this.firstLessonInCourse,
    required this.isLessonViewed,
    required this.onLessonTap,
    required this.isFreeCourse,
    required this.isAuthenticated,
    required this.hasAccess,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTablet = Responsive.isTablet(context);
    final bool isLandscape = Responsive.isLandscape(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: 16,
            top: chapterIndex > 0 ? 24 : 8,
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
        LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = constraints.maxWidth;

            int crossAxisCount;
            if (isTablet) {
              crossAxisCount = isLandscape ? 3 : 2;
            } else {
              crossAxisCount = isLandscape ? 3 : 2;
            }

            final double spacing =
                (maxWidth * 0.03).clamp(10.0, 18.0).toDouble();

            final double childAspectRatio;
            if (isTablet) {
              childAspectRatio = isLandscape ? 1.0 : 0.9;
            } else {
              childAspectRatio = isLandscape ? 0.95 : 0.8;
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: chapter.lessons.length,
              itemBuilder: (context, index) {
                final lesson = chapter.lessons[index];

                final isViewed = isLessonViewed(lesson.id);

                final isAvailable = hasAccess;

                return _LessonCard(
                  key: ValueKey('lesson_${lesson.id}_viewed_$isViewed'),
                  lesson: lesson,
                  isAvailable: isAvailable,
                  hasAccess: hasAccess,
                  isViewed: isViewed,
                  onTap: () => onLessonTap(lesson),
                );
              },
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
  final bool hasAccess;
  final bool isViewed;
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
    final bool isTablet = Responsive.isTablet(context);
    final bool canAccess = hasAccess && isAvailable;
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
              borderRadius: BorderRadius.circular(isTablet ? 20 : 22),
              boxShadow: [
                BoxShadow(
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
                    if (canAccess)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(
                                0xFF9B59D0),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            isViewed ? 'تم المشاهدة' : 'متاح',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding:  Responsive.padding(context, horizontal: 8,vertical: 8),
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            lesson.nameAr,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize:
                                  isTablet ? Responsive.fontSize(context, 12) : 14,
                              fontWeight: FontWeight.w600,
                              color: (hasAccess || isAvailable)
                                  ? AppColors.textPrimary
                                  : Colors.grey[500],
                              height: 1.2,
                            ),
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (lesson.duration != null || lesson.videoDuration != null)
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              _formatDuration(
                                lesson.videoDuration ?? lesson.duration!,
                              ),
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: isTablet ? 11.5 : 11,
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
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildLessonThumbnail() {
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
