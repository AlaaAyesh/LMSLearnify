import 'package:flutter/material.dart';

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
          ),
        ),
        const Text('👋', style: TextStyle(fontSize: 28)),
      ],
    );
  }
}


