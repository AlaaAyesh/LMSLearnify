import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnify_lms/features/authentication/presentation/pages/forgot_password/widgets/forgot_password_app_bar.dart';
import 'package:learnify_lms/features/authentication/presentation/pages/forgot_password/widgets/forgot_password_email_field.dart';
import 'package:learnify_lms/features/authentication/presentation/pages/forgot_password/widgets/forgot_password_subtitle.dart';
import 'package:learnify_lms/features/authentication/presentation/pages/forgot_password/widgets/forgot_password_title.dart';
import 'package:learnify_lms/features/authentication/presentation/pages/login/widgets/login_background.dart';
import 'package:learnify_lms/features/authentication/presentation/widgets/primary_button.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import 'otp_verification_page.dart';

class ForgotPasswordPageView extends StatefulWidget {
  const ForgotPasswordPageView({super.key});

  @override
  State<ForgotPasswordPageView> createState() =>
      ForgotPasswordPageViewState();
}

class ForgotPasswordPageViewState
    extends State<ForgotPasswordPageView> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void onSubmit() {
    if (formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        ForgotPasswordEvent(
          email: emailController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const ForgotPasswordAppBar(),
      body: Stack(
          children: [
          const LoginBackground(),
      BlocListener<AuthBloc, AuthState>(
        listener: authListener,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 34),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 120),
                  const ForgotPasswordTitle(),
                  SizedBox(height: 16),
                  const ForgotPasswordSubtitle(),
                  SizedBox(height: 40),
                  ForgotPasswordEmailField(
                    controller: emailController,
                  ),
                  SizedBox(height: 130),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;

                      return PrimaryButton(
                        text: 'التالي',
                        isLoading: isLoading,
                        onPressed: isLoading ? null : onSubmit,
                      );
                    },
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

  void authListener(BuildContext context, AuthState state) {
    if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
        ),
      );
    } else if (state is ForgotPasswordSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال رمز التحقق إلى بريدك الإلكتروني'),
          backgroundColor: AppColors.success,
        ),
      );
      // Navigate to OTP verification page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OtpVerificationPage(email: state.email),
        ),
      );
    }
  }
}


