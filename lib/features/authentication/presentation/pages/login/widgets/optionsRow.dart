import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';


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
            Text(
              'تذكرني',
              style: TextStyle(
                fontFamily: cairoFontFamily,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pushNamed('/forgot-password'),
          child: Text(
            'هل نسيت كلمة المرور؟',
            style: TextStyle(
              fontFamily: cairoFontFamily,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}



