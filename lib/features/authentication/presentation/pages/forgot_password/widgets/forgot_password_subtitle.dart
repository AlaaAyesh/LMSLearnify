import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_text_styles.dart';

class ForgotPasswordSubtitle extends StatelessWidget {
  const ForgotPasswordSubtitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'من فضلك إدخل البريد الإلكتروني المسجل مسبقاً لدينا',
      style: AppTextStyles.bodyMedium,
      textAlign: TextAlign.center,
    );
  }
}
