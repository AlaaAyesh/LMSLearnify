import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnify_lms/features/authentication/presentation/pages/forgot_password/widgets/forgot_password_app_bar.dart';
import 'package:learnify_lms/features/authentication/presentation/pages/forgot_password/widgets/forgot_password_email_field.dart';
import 'package:learnify_lms/features/authentication/presentation/pages/forgot_password/widgets/forgot_password_subtitle.dart';
import 'package:learnify_lms/features/authentication/presentation/pages/forgot_password/widgets/forgot_password_title.dart';
import 'package:learnify_lms/features/authentication/presentation/pages/login/widgets/login_background.dart';
import 'package:learnify_lms/features/authentication/presentation/widgets/primary_button.dart';
import 'package:learnify_lms/core/utils/responsive.dart';

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
                padding: Responsive.padding(
                  context,
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: Responsive.height(context, 80)),

                      const ForgotPasswordTitle(),

                      SizedBox(height: Responsive.spacing(context, 40)),

                      const ForgotPasswordSubtitle(),

                      SizedBox(height: Responsive.spacing(context, 8)),

                      ForgotPasswordEmailField(
                        controller: emailController,
                      ),

                      SizedBox(height: Responsive.spacing(context, 200)),

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
        const SnackBar(
          content: Text('تم إرسال رمز التحقق إلى بريدك الإلكتروني'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OtpVerificationPage(email: state.email),
        ),
      );
    }
  }
}