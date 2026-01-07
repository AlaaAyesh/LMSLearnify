import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';

import '../../../../../../core/theme/app_colors.dart';

class RegisterHeader extends StatelessWidget {
  final String title;
  final String highlight;

  const RegisterHeader({
    super.key,
    this.title = 'مستقبل ابنك يبدأ',
    this.highlight = 'هنا',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: cairoFontFamily,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              highlight,
              style: TextStyle(
                fontFamily: cairoFontFamily,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 6),
            const Text('👋', style: TextStyle(fontSize: 28)),
          ],
        ),
      ],
    );
  }
}



