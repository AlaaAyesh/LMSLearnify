import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../core/theme/app_colors.dart';
class ApplyButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ApplyButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Responsive.height(context, 44),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          padding: Responsive.padding(context, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Responsive.radius(context, 10)),
          ),
        ),
        child: Text(
          'تطبيق',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: Responsive.fontSize(context, 14),
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}



