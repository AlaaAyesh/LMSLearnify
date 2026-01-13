import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import '../../../../../../core/utils/responsive.dart';
import '../../../../../../core/theme/app_colors.dart';

class HaveAccountRow extends StatelessWidget {
  const HaveAccountRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'هل لديك حساب؟ ',
          style: TextStyle(
            fontFamily: cairoFontFamily,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: Responsive.fontSize(context, 14),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            ' اضغط من هنا',
            style: TextStyle(
              fontFamily: cairoFontFamily,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
              fontSize: Responsive.fontSize(context, 14),
            ),
          ),
        ),
      ],
    );
  }
}



