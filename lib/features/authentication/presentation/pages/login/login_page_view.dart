import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/responsive.dart';
import 'package:learnify_lms/features/authentication/presentation/pages/login/widgets/create_account_button.dart';
import 'package:learnify_lms/features/authentication/presentation/pages/login/widgets/divider_text.dart';
import 'package:learnify_lms/features/authentication/presentation/pages/login/widgets/header.dart';
import 'package:learnify_lms/features/authentication/presentation/pages/login/widgets/login_background.dart';
import 'package:learnify_lms/features/authentication/presentation/pages/login/widgets/login_title.dart';
import 'package:learnify_lms/features/authentication/presentation/pages/login/widgets/optionsRow.dart';

import '../../../../../core/theme/app_colors.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  void _onGuestLoginPressed() {
    // إضافة حدث تسجيل الدخول كضيف إلى الـ Bloc
    context.read<AuthBloc>().add(GuestLoginEvent());
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
                        onRememberChanged: (v) =>
                            setState(() => _rememberMe = v),
                      ),
                      SizedBox(height: Responsive.spacing(context, 24)),
                      const CustomDividerWithText(text: "أو الدخول بواسطة"),
                      SizedBox(height: Responsive.spacing(context, 24)),
                      const SocialLoginButtons(),
                      SizedBox(height: Responsive.spacing(context, 40)),
                      const CreateAccountButton(),

                      // 🆕 زر الدخول كضيف
                      SizedBox(height: Responsive.spacing(context, 16)),
                      TextButton.icon(
                        onPressed: _onGuestLoginPressed,
                        icon: Icon(
                          Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                          size: Responsive.iconSize(context, 18),
                        ),
                        label: Text(
                          'تصفح كضيف',
                          style: TextStyle(
                            fontFamily: cairoFontFamily,
                            color: AppColors.textSecondary,
                            fontSize: Responsive.fontSize(context, 16),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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
      // Check if we came from subscriptions page (or another page that needs return)
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final returnTo = args?['returnTo'] as String?;

      if (returnTo == 'subscriptions') {
        // Return true to indicate successful login
        Navigator.of(context).pop(true);
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



