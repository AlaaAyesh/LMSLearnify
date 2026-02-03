import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnify_lms/features/home/presentation/pages/tablet/tablet_main_navigation_page.dart';
import 'package:learnify_lms/features/menu/presentation/pages/widgets/menu_button.dart';
import 'package:learnify_lms/features/menu/presentation/pages/widgets/menu_outline_button.dart';
import '../../../../../../core/di/injection_container.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/widgets/support_section.dart';
import '../../../../about/presentation/pages/about_page.dart';
import '../../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../../authentication/presentation/bloc/auth_event.dart';
import '../../../../authentication/presentation/bloc/auth_state.dart';
import '../../../../certificates/presentation/pages/certificates_page.dart';
import '../../../../courses/presentation/pages/all_courses_page.dart';
import '../../../../profile/presentation/pages/profile_page.dart';
import '../../../../subscriptions/presentation/pages/subscriptions_page.dart';
import '../../../../transactions/presentation/pages/transactions_page.dart';
class TabletMenuPage extends StatefulWidget {
  const TabletMenuPage({super.key});

  @override
  State<TabletMenuPage> createState() => _TabletMenuPageState();
}

class _TabletMenuPageState extends State<TabletMenuPage> {
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
    return const _TabletMenuPageContent();
  }
}

class _TabletMenuPageContent extends StatelessWidget {
  const _TabletMenuPageContent();

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isPortrait = media.orientation == Orientation.portrait;
    final isTabletPortrait =
        isPortrait && media.size.shortestSide >= 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  // Logo

                  const SizedBox(height: 40),

                  // Menu Buttons - Grid layout for tablet
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isTabletPortrait? 1: 2,
                    crossAxisSpacing: isTabletPortrait ?2:20,
                    mainAxisSpacing: isTabletPortrait ?0:16,
                    childAspectRatio: 3.5,
                    children: [
                      MenuButton(
                        text: 'عن التطبيق',
                        onTap: () {
                          context.pushWithNavTablet(const AboutPage());
                        },
                      ),
                      MenuButton(
                        text: 'الحساب',
                        onTap: () {
                          context.pushWithNavTablet(const ProfilePage());
                        },
                      ),
                      MenuButton(
                        text: 'اختر باقتك',
                        onTap: () {
                          context.pushWithNavTablet(const SubscriptionsPage());
                        },
                      ),
                      MenuButton(
                        text: ' كورساتي',
                        onTap: () {
                          context.pushWithNavTablet(const AllCoursesPage());
                        },
                      ),
                      MenuButton(
                        text: 'شهاداتي',
                        onTap: () {
                          context.pushWithNavTablet(const CertificatesPage());
                        },
                      ),
                      MenuButton(
                        text: 'اشتراكاتي',
                        onTap: () {
                          context.pushWithNavTablet(const TransactionsPage());
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // CREATE ACCOUNT / LOGOUT
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthAuthenticated) {
                        return SizedBox(
                          width: double.infinity,
                          child: MenuOutlineButton(
                            text: 'تسجيل الخروج',
                            onTap: () {
                              _showLogoutDialog(context);
                            },
                          ),
                        );
                      } else {
                        return SizedBox(
                          width: double.infinity,
                          child: MenuOutlineButton(
                            text: 'إنشاء حساب جديد',
                            onTap: () {
                              Navigator.of(context, rootNavigator: true)
                                  .pushNamed('/login');
                            },
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 32),

                  // SUPPORT
                  const SupportSection(),

                  const SizedBox(height: 32),
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
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'تسجيل الخروج',
          style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w800,
              color: AppColors.soonText),
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
              backgroundColor: AppColors.soonText,
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
