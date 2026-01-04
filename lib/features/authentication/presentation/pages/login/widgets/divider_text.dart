import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';

class DividerText extends StatelessWidget {
  const DividerText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.greyLight)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'أو الدخول بواسطة',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.greyLight)),
      ],
    );
  }
}
