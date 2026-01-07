import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';


import '../../../../../core/theme/app_colors.dart';
class ApplyButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ApplyButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'تطبيق',
          style: TextStyle(
            fontFamily: cairoFontFamily,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}



