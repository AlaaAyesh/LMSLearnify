import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../../core/theme/app_colors.dart';

class CustomDividerWithText extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final Color dividerColor;
  final double thickness;
  final double spacing;

  const CustomDividerWithText({
    super.key,
    required this.text,
    this.textStyle,
    this.dividerColor = AppColors.greyLight,
    this.thickness = 2,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: dividerColor,
            thickness: thickness,
          ),
        ),
        Padding(
          padding: Responsive.padding(context, horizontal: spacing),
          child: Text(
            text,
            style: textStyle ??
                TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.grey,
                  fontWeight: FontWeight.w700,
                  fontSize: Responsive.fontSize(context, 12),
                ),
          ),
        ),
        Expanded(
          child: Divider(
            color: dividerColor,
            thickness: thickness,
          ),
        ),
      ],
    );
  }
}



