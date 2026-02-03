import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/utils/responsive.dart';
import 'package:learnify_lms/features/authentication/presentation/pages/login/widgets/create_account_button.dart';
import 'package:learnify_lms/features/authentication/presentation/pages/login/widgets/divider_text.dart';
import 'package:learnify_lms/features/authentication/presentation/pages/login/widgets/header.dart';
import 'package:learnify_lms/features/authentication/presentation/pages/login/widgets/login_background.dart';
import 'package:learnify_lms/features/authentication/presentation/pages/login/widgets/login_title.dart';
import 'package:learnify_lms/features/authentication/presentation/pages/login/widgets/optionsRow.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/storage/secure_storage_service.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import '../../widgets/custom_divider_with_text.dart';
import '../../widgets/emailField.dart';
import '../../widgets/passwordField.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/social_login_buttons.dart';

class LoginPageView extends StatefulWidget {
  const LoginPageView({super.key});

  @override
  State<LoginPageView> createState() => LoginPageViewState();
}

class LoginPageViewState extends State<LoginPageView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  static const String _kRememberMeKey = 'auth_remember_me';
  static const String _kRememberedEmailKey = 'auth_remembered_email';

  @override
  void initState() {
    super.initState();
    _loadRememberedLogin();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadRememberedLogin() async {
    try {
      final prefs = sl<SharedPreferences>();
      final secureStorage = sl<SecureStorageService>();
      final remember = prefs.getBool(_kRememberMeKey) ?? false;
      final rememberedEmail = prefs.getString(_kRememberedEmailKey) ?? '';
      final rememberedPassword = await secureStorage.getRememberedPassword();

      if (!mounted) return;
      setState(() {
        _rememberMe = remember;
        if (remember && rememberedEmail.isNotEmpty) {
          _emailController.text = rememberedEmail;
        }
        if (remember && (rememberedPassword ?? '').isNotEmpty) {
          _passwordController.text = rememberedPassword!;
        }
      });
    } catch (_) {
      // ignore - don't block login if prefs fails
    }
  }

  Future<void> _setRememberMe(bool value) async {
    setState(() => _rememberMe = value);
    try {
      final prefs = sl<SharedPreferences>();
      final secureStorage = sl<SecureStorageService>();
      await prefs.setBool(_kRememberMeKey, value);
      if (!value) {
        await prefs.remove(_kRememberedEmailKey);
        await secureStorage.clearRememberedPassword();
        _passwordController.clear();
      }
    } catch (_) {
      // ignore
    }
  }

  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginEvent(
              email: _emailController.text.trim(),
              // Avoid treating trailing spaces as part of the password
              password: _passwordController.text.trimRight(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return _buildTabletLayout(context);
    } else {
      return _buildPhoneLayout(context);
    }
  }

  /// الهاتف (التصميم الحالي كما هو)
  Widget _buildPhoneLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          const LoginBackground(),
          BlocListener<AuthBloc, AuthState>(
            listener: _authListener,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: Responsive.padding(context, all: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: Responsive.spacing(context, 40)),
                      const Header(),
                      SizedBox(height: Responsive.spacing(context, 50)),
                      const LoginTitle(),
                      SizedBox(height: Responsive.spacing(context, 18)),
                      EmailField(controller: _emailController),
                      SizedBox(height: Responsive.spacing(context, 25)),
                      PasswordField(
                        controller: _passwordController,
                        obscure: _obscurePassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      SizedBox(height: Responsive.spacing(context, 40)),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;

                          return PrimaryButton(
                            text: 'تسجيل الدخول',
                            isLoading: isLoading,
                            onPressed: isLoading ? null : _onLoginPressed,
                          );
                        },
                      ),
                      OptionsRow(
                        rememberMe: _rememberMe,
                        onRememberChanged: _setRememberMe,
                      ),
                      SizedBox(height: Responsive.spacing(context, 24)),
                      const CustomDividerWithText(text: "أو الدخول بواسطة"),
                      SizedBox(height: Responsive.spacing(context, 24)),
                      const SocialLoginButtons(),
                      SizedBox(height: Responsive.spacing(context, 40)),
                      const CreateAccountButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// تصميم خاص بالتابلت: تقسيم الشاشة إلى جزء معلومات وجزء فورم
  Widget _buildTabletLayout(BuildContext context) {
    final isPortrait = Responsive.isPortrait(context);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        // إغلاق الكيبورد عند الضغط خارج الحقول
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        resizeToAvoidBottomInset: false,
        body: BlocListener<AuthBloc, AuthState>(
          listener: _authListener,
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isPortrait ? 600 : 1000,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blackOpacity30,
                        blurRadius: 26,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: isPortrait
                        ? _buildPortraitTabletLayout(context)
                        : _buildLandscapeTabletLayout(context),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// تصميم التابلت في الوضع الأفقي (Row)
  Widget _buildLandscapeTabletLayout(BuildContext context) {
    return Row(
      children: [
        // الفورم (يمين في التابلت)
        Expanded(
          flex: 6,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                32,
                32,
                32,
                MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const LoginTitle(),
                    const SizedBox(height: 12),
                    Text(
                      'ادخل بيانات حسابك للوصول إلى محتواك التعليمي المميز.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: Responsive.fontSize(context, 15),
                            height: 1.4,
                          ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: EmailField(controller: _emailController),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: PasswordField(
                        controller: _passwordController,
                        obscure: _obscurePassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OptionsRow(
                        rememberMe: _rememberMe,
                        onRememberChanged: _setRememberMe,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;

                          return PrimaryButton(
                            text: 'تسجيل الدخول',
                            isLoading: isLoading,
                            onPressed: isLoading ? null : _onLoginPressed,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(
                      width: double.infinity,
                      child: CustomDividerWithText(
                        text: "أو الدخول بواسطة",
                      ),
                    ),
                    const SizedBox(height: 16),
                    const SocialLoginButtons(),
                    const SizedBox(height: 20),
                    Center(child: const CreateAccountButton()),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
        // بانل الترحيب الصفراء (يسار في التابلت)
        Expanded(
          flex: 4,
          child: MediaQuery(
            data: MediaQuery.of(context).removeViewInsets(removeBottom: true),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  height: constraints.maxHeight,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryCard,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(120),
                        bottomLeft: Radius.circular(120),
                        bottomRight: Radius.circular(28),
                        topRight: Radius.circular(28)),
                  ),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Stack(
                      children: [
                        // Decorative circles
                        Positioned(
                          top: 40,
                          right: 20,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(0.1),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 80,
                          left: 30,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(0.15),
                            ),
                          ),
                        ),
                        // Content - ثابت لا يتأثر بالكيبورد
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 24,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Header(),
                                SvgPicture.asset(
                                  'assets/icons/sun1.svg',
                                  width: Responsive.width(context, 25),
                                ),
                                Text(
                                  'سجل دخولك للوصول إلى محتواك التعليمي المميز.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize:
                                            Responsive.fontSize(context, 15),
                                        height: 1.4,
                                      ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// تصميم التابلت في الوضع الرأسي (Column)
  Widget _buildPortraitTabletLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // بانل الترحيب الصفراء (أعلى في الوضع الرأسي)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            decoration: const BoxDecoration(
              color: AppColors.primaryCard,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 30,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.15),
                      ),
                    ),
                  ),
                  // Content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Header(),
                      const SizedBox(height: 16),
                      SvgPicture.asset(
                        'assets/icons/sun1.svg',
                        width: Responsive.width(context, 30),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'سجل دخولك للوصول إلى محتواك التعليمي المميز.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: Responsive.fontSize(context, 15),
                              height: 1.4,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // الفورم (أسفل في الوضع الرأسي)
          LayoutBuilder(
            builder: (context, constraints) {
              return StreamBuilder<Object>(
                stream: null,
                builder: (context, snapshot) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      32,
                      32,
                      32,
                      MediaQuery.of(context).viewInsets.bottom + 32,
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              const LoginTitle(),
                              const SizedBox(height: 12),
                              Text(
                                'ادخل بيانات حسابك للوصول إلى محتواك التعليمي المميز.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: Responsive.fontSize(context, 15),
                                      height: 1.4,
                                    ),
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: EmailField(controller: _emailController),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: PasswordField(
                                  controller: _passwordController,
                                  obscure: _obscurePassword,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: double.infinity,
                                child: OptionsRow(
                                  rememberMe: _rememberMe,
                                  onRememberChanged: _setRememberMe,
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) {
                                    final isLoading = state is AuthLoading;
                  
                                    return PrimaryButton(
                                      text: 'تسجيل الدخول',
                                      isLoading: isLoading,
                                      onPressed: isLoading ? null : _onLoginPressed,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              const SizedBox(
                                width: double.infinity,
                                child: CustomDividerWithText(
                                  text: "أو الدخول بواسطة",
                                ),
                              ),
                              const SizedBox(height: 16),
                              Center(child: const SocialLoginButtons()),
                              const SizedBox(height: 20),
                              Center(child: const CreateAccountButton()),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                    ),
                  );
                }
              );
            },
          ),
        ],
      ),
    );
  }

  void _authListener(BuildContext context, AuthState state) {
    if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
        ),
      );
    } else if (state is AuthAuthenticated) {
      // Persist remembered email only after successful login
      try {
        final prefs = sl<SharedPreferences>();
        final secureStorage = sl<SecureStorageService>();
        prefs.setBool(_kRememberMeKey, _rememberMe);
        if (_rememberMe) {
          prefs.setString(_kRememberedEmailKey, _emailController.text.trim());
          // Store the normalized password (no trailing spaces)
          unawaited(
            secureStorage
                .saveRememberedPassword(_passwordController.text.trimRight()),
          );
        } else {
          prefs.remove(_kRememberedEmailKey);
          unawaited(secureStorage.clearRememberedPassword());
        }
      } catch (_) {
        // ignore
      }

      // Check if we came from a specific page that needs return
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final returnTo = args?['returnTo'] as String?;

      if (returnTo == 'subscriptions' ||
          returnTo == 'profile' ||
          returnTo == 'certificates') {
        // Return true to indicate successful login
        Navigator.of(context).pop(true);
      } else if (returnTo == 'course' || returnTo == 'payment') {
        // Return to the calling page (course details or payment flow)
        Navigator.of(context).pop(true);
        // The calling page will handle refreshing/continuing the flow
      } else {
        // Navigate to home - server handles verification
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
        );
      }
    }
  }
}
