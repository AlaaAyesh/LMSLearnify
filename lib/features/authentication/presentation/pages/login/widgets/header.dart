import 'package:flutter/material.dart';
import '../../../../../../core/utils/responsive.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'أهلاً بك يا بطل ',
          style: AppTextStyles.displayMedium.copyWith(
            color: AppColors.textPrimary,
            fontSize: Responsive.fontSize(context, AppTextStyles.displayMedium.fontSize ?? 28),
          ),
        ),
        Text('👋', style: TextStyle(fontSize: Responsive.fontSize(context, 28))),
      ],
    );
  }
}


