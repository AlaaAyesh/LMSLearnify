import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_text_styles.dart';

class ForgotPasswordTitle extends StatelessWidget {
  const ForgotPasswordTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'نسيت كلمة المرور؟',
      style: AppTextStyles.displayMedium,
      textAlign: TextAlign.center,
    );
  }
}


