import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_text_styles.dart';

class LoginTitle extends StatelessWidget {
  const LoginTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'تسجيل الدخول',
      style: AppTextStyles.headlineMedium,
      textAlign: TextAlign.right,
    );
  }
}
