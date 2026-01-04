import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnify_lms/features/menu/presentation/pages/widgets/menu_button.dart';
import 'package:learnify_lms/features/menu/presentation/pages/widgets/menu_outline_button.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/support_section.dart';
import '../../../about/presentation/pages/about_page.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../../certificates/presentation/pages/certificates_page.dart';
import '../../../courses/presentation/pages/all_courses_page.dart';
import '../../../home/presentation/pages/main_navigation_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../subscriptions/presentation/pages/subscriptions_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>()..add(CheckAuthStatusEvent()),
      child: const _MenuPageContent(),
    );
  }
}

class _MenuPageContent extends StatelessWidget {
  const _MenuPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              // Navigate to login and clear all routes using root navigator
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              });
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                /// LOGO
                Image.asset(
                  'assets/images/app_logo.png',
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      alignment: Alignment.center,
                      child: const Text(
                        'Learnify',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                /// MENU BUTTONS
                MenuButton(
                  text: 'عن التطبيق',
                  onTap: () {
                    print('🔵 About button tapped');
                    context.pushWithNav(const AboutPage());
                  },
                ),

                MenuButton(
                  text: 'الحساب',
                  onTap: () {
                    print('🔵 Profile button tapped');
                    context.pushWithNav(const ProfilePage());
                  },
                ),

                MenuButton(
                  text: 'اختر باقتك',
                  badge: 'عروض',
                  onTap: () {
                    print('🔵 Subscriptions button tapped');
                    context.pushWithNav(const SubscriptionsPage());
                  },
                ),

                MenuButton(
                  text: 'جميع الكورسات',
                  onTap: () {
                    print('🔵 All courses button tapped');
                    context.pushWithNav(const AllCoursesPage());
                  },
                ),

                MenuButton(
                  text: 'شهاداتي',
                  onTap: () {
                    print('🔵 Certificates button tapped');
                    context.pushWithNav(const CertificatesPage());
                  },
                ),

                const SizedBox(height: 10),

                /// CREATE ACCOUNT / LOGOUT
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticated) {
                      return MenuOutlineButton(
                        text: 'تسجيل الخروج',
                        onTap: () {
                          print('🔵 Logout button tapped');
                          _showLogoutDialog(context);
                        },
                      );
                    } else {
                      return MenuOutlineButton(
                        text: 'إنشاء حساب جديد',
                        onTap: () {
                          print('🔵 Register button tapped');
                          Navigator.pushNamed(context, '/register');
                        },
                      );
                    }
                  },
                ),

                const SizedBox(height: 24),

                /// SUPPORT
                const SupportSection(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'تسجيل الخروج',
          style: TextStyle(fontFamily: 'Cairo'),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'هل أنت متأكد من تسجيل الخروج؟',
          style: TextStyle(fontFamily: 'Cairo'),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(LogoutEvent());
            },
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );
  }
}