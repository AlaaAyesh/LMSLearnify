import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CompleteProfilePage(
                email: state.email,
                name: state.name,
                providerId: state.providerId,
              ),
            ),
          );
        } else if (state is AuthAuthenticated) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else if (state is AuthError) {
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
              context.read<AuthBloc>().add(
                    const SocialLoginEvent(provider: 'apple'),
                  );
            },
          ),
          const SizedBox(width: 24),
          SocialButton(
            asset: 'assets/icons/google.svg',
            onTap: () {
              // Use native Google Sign-In
              context.read<AuthBloc>().add(NativeGoogleSignInEvent());
            },
          ),
        ],
      ),
    );
  }
}
