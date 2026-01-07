import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';


import '../../../../core/di/injection_container.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/animated_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _navigate();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final secureStorage = sl<SecureStorageService>();

    final token = await secureStorage.getAccessToken();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // User has token - go to home (server will handle verification check)
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Column(
            children: [
              // First quarter - empty space
              SizedBox(height: (screenHeight - topPadding) * 0.15),

              // Logo and text
              const AnimatedLogo(),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: RichText(
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'مستقبل ابنك يبدأ\n',
                        style: TextStyle(
                          fontFamily: cairoFontFamily,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF000000),
                          height: 1.5,
                        ),
                      ),
                      TextSpan(
                        text: 'هنا 👋',
                        style: TextStyle(
                          fontFamily: cairoFontFamily,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFFFFF),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Remaining space
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}



