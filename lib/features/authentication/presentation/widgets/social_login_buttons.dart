import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/responsive.dart';
import 'package:learnify_lms/features/authentication/presentation/widgets/social_button.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../pages/register/complete_profile_page.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is SocialLoginNeedsCompletion) {
          // مستخدم جديد → يكمل البروفايل
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CompleteProfilePage(
                email: state.email,
                name: state.name,
                providerId: state.providerId,
                accessToken: state.accessToken,
                requiresRegistration: state.requiresRegistration,
              ),
            ),
          );
        }
        else if (state is AuthAuthenticated) {
          // مستخدم قديم → يروح مباشرة للهوم
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
                (route) => false,
          );
        }
        else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SocialButton(
            asset: 'assets/icons/apple.svg',
            onTap: () {
              context.read<AuthBloc>().add(NativeAppleSignInEvent());
            },
          ),
          SizedBox(width: Responsive.width(context, 24)),
          SocialButton(
            asset: 'assets/icons/google.svg',
            onTap: () {
              context.read<AuthBloc>().add(NativeGoogleSignInEvent());
            },
          ),
        ],
      ),
    );
  }
}



