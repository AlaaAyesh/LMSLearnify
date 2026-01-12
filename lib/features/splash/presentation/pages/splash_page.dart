import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/storage/hive_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
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
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _checkFirstTime();
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

  Future<void> _checkFirstTime() async {
    final hiveService = sl<HiveService>();
    final isFirstTime = await hiveService.getData(AppConstants.keyIsFirstTime);
    
    if (!mounted) return;
    
    setState(() {
      _isFirstTime = isFirstTime == null || isFirstTime == true;
    });
    
    // Wait for auth status check to complete
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    
    // Listen to auth state to determine navigation
    final authBloc = context.read<AuthBloc>();
    
    // Wait for auth state to be determined (not initial)
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    
    final authState = authBloc.state;
    
    if (_isFirstTime) {
      // First time: Show welcome screen for 2 seconds, then go to Home
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      
      // Mark as not first time
      await hiveService.saveData(AppConstants.keyIsFirstTime, false);
      
      // Go directly to Home (auth state doesn't matter for first time)
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // Not first time: Check auth status and navigate accordingly
      if (authState is AuthAuthenticated) {
        // User is authenticated, go to home
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // User is not authenticated, but still go to home (guest mode or login from there)
        Navigator.of(context).pushReplacementNamed('/home');
      }
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

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Auth state changes are handled in _checkFirstTime
        // This listener ensures we react to auth state changes
      },
      child: Scaffold(
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
      ),
    );
  }
}



