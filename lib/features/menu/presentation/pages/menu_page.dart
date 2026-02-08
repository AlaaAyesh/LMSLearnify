import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnify_lms/features/menu/presentation/pages/widgets/menu_button.dart';
import 'package:learnify_lms/features/menu/presentation/pages/widgets/menu_outline_button.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/premium_subscription_popup.dart';
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
import '../../../transactions/presentation/pages/transactions_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(CheckAuthStatusEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current is AuthUnauthenticated,
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
            AppRouter.splash,
            (route) => false,
          );
        }
      },
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
        child: SingleChildScrollView(
          padding: Responsive.padding(context, horizontal: 24, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Column(
                children: [
                  Builder(builder: (context) {
                    final logoHeight =
                        Responsive.height(context, 160).clamp(120.0, 220.0);
                    return Image.asset(
                      'assets/images/app_logo.png',
                      height: logoHeight,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: logoHeight,
                          alignment: Alignment.center,
                          child: Text(
                            'Learnify',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: Responsive.fontSize(context, 30),
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      },
                    );
                  }),

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
                    onTap: () {
                      print('🔵 Subscriptions button tapped');
                      context.pushWithNav(const SubscriptionsPage());
                    },
                  ),

                  MenuButton(
                    text: ' كورساتي',
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

                  MenuButton(
                    text: 'اشتراكاتي',
                    onTap: () {
                      print('🔵 My Transactions button tapped');
                      context.pushWithNav(const TransactionsPage());
                    },
                  ),

                  SizedBox(height: Responsive.spacing(context, 10)),

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
                          text: 'تسجيل الدخول',
                          onTap: () {
                            print('🔵 Login button tapped');
                            Navigator.of(context, rootNavigator: true)
                                .pushNamed('/login');
                          },
                        );
                      }
                    },
                  ),

                  SizedBox(height: Responsive.spacing(context, 24)),

                  const SupportSection(),

                  SizedBox(height: Responsive.spacing(context, 24)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: PremiumOvalPopup(
          showCloseButton: true,
          onClose: () => Navigator.pop(dialogContext),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'تسجيل الخروج',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: Responsive.fontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: Responsive.spacing(context, 12)),
              Text(
                'هل أنت متأكد من تسجيل الخروج؟',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: Responsive.fontSize(context, 15),
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Responsive.spacing(context, 24)),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: Responsive.spacing(context, 12)),
                        side: const BorderSide(color: AppColors.greyLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Responsive.radius(context, 28)),
                        ),
                      ),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: Responsive.fontSize(context, 16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: Responsive.spacing(context, 12)),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: Responsive.spacing(context, 12)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Responsive.radius(context, 28)),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        context.read<AuthBloc>().add(LogoutEvent());
                      },
                      child: Text(
                        'تسجيل الخروج',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: Responsive.fontSize(context, 16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
