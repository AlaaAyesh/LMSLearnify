import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';

class OptionsRow extends StatelessWidget {
  final bool rememberMe;
  final ValueChanged<bool> onRememberChanged;

  const OptionsRow({
    required this.rememberMe,
    required this.onRememberChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: rememberMe,
              onChanged: (v) => onRememberChanged(v ?? false),
              activeColor: AppColors.primary,
            ),
            const Text(
              'تذكرني',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pushNamed('/forgot-password'),
          child: const Text(
            'هل نسيت كلمة المرور؟',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
