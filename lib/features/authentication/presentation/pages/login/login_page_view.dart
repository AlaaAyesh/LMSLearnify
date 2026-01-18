import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            secureStorage.saveRememberedPassword(_passwordController.text.trimRight()),
          );
        } else {
          prefs.remove(_kRememberedEmailKey);
          unawaited(secureStorage.clearRememberedPassword());
        }
      } catch (_) {
        // ignore
      }

      // Check if we came from a specific page that needs return
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final returnTo = args?['returnTo'] as String?;

      if (returnTo == 'subscriptions' || returnTo == 'profile' || returnTo == 'certificates') {
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



