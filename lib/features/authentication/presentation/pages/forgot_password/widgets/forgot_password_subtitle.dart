import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/utils/responsive.dart';

class ForgotPasswordSubtitle extends StatelessWidget {
  const ForgotPasswordSubtitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'من فضلك إدخل البريد الإلكتروني المسجل مسبقاً لدينا',
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: Responsive.fontSize(context, 14),
        fontWeight: FontWeight.w700,
        color: AppColors.black,
      ),

    );
  }
}


