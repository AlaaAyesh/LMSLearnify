import 'package:flutter/material.dart';
import '../../../../../../core/utils/responsive.dart';
import '../../../../../../core/theme/app_text_styles.dart';

class LoginTitle extends StatelessWidget {
  const LoginTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'تسجيل الدخول',
      style: AppTextStyles.headlineMedium.copyWith(
        fontWeight: FontWeight.w900,
        fontSize: Responsive.fontSize(context, 18),
      ),
      textAlign: TextAlign.right,
    );
  }
}


