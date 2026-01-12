import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import '../../../../../../core/utils/responsive.dart';
import '../../../../../../core/theme/app_colors.dart';

class DividerText extends StatelessWidget {
  const DividerText({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.greyLight)),
        Padding(
          padding: Responsive.padding(context, horizontal: 16),
          child: Text(
            'أو الدخول بواسطة',
            style: TextStyle(
              fontFamily: cairoFontFamily,
              fontSize: Responsive.fontSize(context, 13),
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.greyLight)),
      ],
    );
  }
}



