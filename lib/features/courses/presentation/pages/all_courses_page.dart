import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_background.dart';
import '../../../../core/routing/app_router.dart';
import '../../../home/domain/entities/course.dart';
import '../../../home/presentation/pages/course_details_page.dart';
import '../bloc/courses_bloc.dart';
import '../bloc/courses_event.dart';
import '../bloc/courses_state.dart';
import '../widgets/course_circle_item.dart';

class AllCoursesPage extends StatelessWidget {
  final int? categoryId;
  final int? specialtyId;
  final String? title;

  const AllCoursesPage({
    super.key,
    this.categoryId,
    this.specialtyId,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CoursesBloc>()
        // Load user's owned courses from myCourses endpoint
        ..add(const LoadMyCoursesEvent()),
      child: _AllCoursesPageContent(
        title: title ?? ' كورساتي',
        categoryId: categoryId,
        specialtyId: specialtyId,
      ),
    );
  }
}

class _AllCoursesPageContent extends StatelessWidget {
  final String title;
  final int? categoryId;
  final int? specialtyId;

  const _AllCoursesPageContent({
    required this.title,
    this.categoryId,
    this.specialtyId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(title: title),
      body: Stack(
        children: [
          const CustomBackground(),
          BlocConsumer<CoursesBloc, CoursesState>(
            listener: (context, state) {
              if (state is CoursesError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is CoursesLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              }

              if (state is CoursesEmpty) {
                return _buildEmptyState(context);
              }

              if (state is CoursesLoaded) {
                return _buildCoursesList(context, state);
              }

              if (state is CoursesError) {
                return _buildErrorState(context, state.message);
              }

              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesList(BuildContext context, CoursesLoaded state) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200 &&
            !state.isLoadingMore &&
            state.hasMorePages) {
          context.read<CoursesBloc>().add(const LoadMoreCoursesEvent());
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          // Refresh user's courses list
          context.read<CoursesBloc>().add(const LoadMyCoursesEvent());
        },
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // Circular course items in a grid
            SliverPadding(
              padding: Responsive.padding(context, all: 16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: Responsive.width(context, 8),
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final course = state.courses[index];
                    return CourseCircleItem(
                      course: course,
                      onTap: () => _navigateToCourseDetails(context, course),
                    );
                  },
                  childCount: state.courses.length,
                ),
              ),
            ),
            if (state.isLoadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: Responsive.padding(context, all: 16),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: Responsive.width(context, 2),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: Responsive.iconSize(context, 80),
            color: Colors.grey[400],
          ),
          SizedBox(height: Responsive.spacing(context, 16)),
          Text(
            'لا توجد كورسات متاحة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: Responsive.fontSize(context, 18),
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 8)),
          Text(
            'سيتم إضافة كورسات جديدة قريباً',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: Responsive.fontSize(context, 14),
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 24)),
          ElevatedButton.icon(
            onPressed: () {
              context.read<CoursesBloc>().add(const LoadMyCoursesEvent());
            },
            // icon: Icon(Icons.refresh, size: Responsive.iconSize(context, 20)),
            label: const Text('تحديث'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: Responsive.padding(context, horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    // Check if error is due to unauthorized access
    final isAuthError = message.contains('يجب تسجيل الدخول أولاً') || 
                        message.contains('تسجيل الدخول') ||
                        message.toLowerCase().contains('unauthorized');

    if (isAuthError) {
      // Show same design as certificates page for unauthorized users
      return Center(
        child: Padding(
          padding: Responsive.padding(
            context,
            horizontal: 24,
            vertical: 16,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: Responsive.iconSize(context, 80),
                  color: AppColors.primary,
                ),
                SizedBox(height: Responsive.spacing(context, 24)),
                Text(
                  'تسجيل الدخول مطلوب',
                  style: AppTextStyles.displayMedium.copyWith(
                    fontSize: Responsive.fontSize(context, 24),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Responsive.spacing(context, 12)),
                Text(
                  'للوصول إلى الكورسات، يرجى تسجيل الدخول أو إنشاء حساب جديد',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: Responsive.fontSize(context, 16),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Responsive.spacing(context, 28)),
                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: Responsive.height(context, 56),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        // Go directly to login using the root navigator
                        final result = await Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushNamed(
                          AppRouter.login,
                          arguments: {'returnTo': 'courses'},
                        );

                        if (result == true && context.mounted) {
                          // After successful login, reload the courses page
                          context.read<CoursesBloc>().add(const LoadMyCoursesEvent());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: Text(
                        'تسجيل الدخول',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: Responsive.fontSize(context, 18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, 24)),
                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: Responsive.height(context, 56),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: OutlinedButton(
                      onPressed: () async {
                        // Go directly to register using the root navigator
                        final result = await Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushNamed(
                          AppRouter.register,
                          arguments: {'returnTo': 'courses'},
                        );

                        if (result == true && context.mounted) {
                          // After successful registration, reload the courses page
                          context.read<CoursesBloc>().add(const LoadMyCoursesEvent());
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        side: const BorderSide(color: AppColors.primary),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: Text(
                        'إنشاء حساب جديد',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: Responsive.fontSize(context, 18),
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
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

    // Default error state for other errors
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: Responsive.iconSize(context, 80),
            color: Colors.red[400],
          ),
          SizedBox(height: Responsive.spacing(context, 16)),
          Text(
            'حدث خطأ',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: Responsive.fontSize(context, 18),
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 8)),
          Padding(
            padding: Responsive.padding(context, horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: Responsive.fontSize(context, 14),
                color: Colors.grey[500],
              ),
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 24)),
          ElevatedButton.icon(
            onPressed: () {
              context.read<CoursesBloc>().add(const LoadMyCoursesEvent());
            },
            icon: Icon(Icons.refresh, size: Responsive.iconSize(context, 20)),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: Responsive.padding(context, horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCourseDetails(BuildContext context, Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseDetailsPage(course: course),
      ),
    );
  }
}





