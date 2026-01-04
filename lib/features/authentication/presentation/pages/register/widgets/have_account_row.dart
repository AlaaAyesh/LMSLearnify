import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';

class HaveAccountRow extends StatelessWidget {
  const HaveAccountRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'هل لديك حساب؟ ',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'اضغط من هنا',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
