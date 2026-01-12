import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import '../../../../../../core/utils/responsive.dart';
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
            fontSize: Responsive.fontSize(context, 28),
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: Responsive.spacing(context, 4)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              highlight,
              style: TextStyle(
                fontFamily: cairoFontFamily,
                fontSize: Responsive.fontSize(context, 28),
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: Responsive.width(context, 6)),
            Text('👋', style: TextStyle(fontSize: Responsive.fontSize(context, 28))),
          ],
        ),
      ],
    );
  }
}



